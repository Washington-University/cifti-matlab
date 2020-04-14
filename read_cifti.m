function outstruct = read_cifti(filename, varargin)
    %function outstruct = read_cifti(filename, ...)
    %   Read a cifti file.
    %   If wb_command is not on your PATH and you need to read cifti-1
    %   files, specify "..., 'wbcmd', '<wb_command with full path>'".
    %
    %   >> cifti = read_cifti('91282_Greyordinates.dscalar.nii');
    %   >> cifti.cdata = outdata;
    %   >> cifti.diminfo{2} = cifti_diminfo_make_scalars(size(outdata, 2));
    %   >> write_cifti(cifti, 'ciftiout.dscalar.nii');
    options = myargparse(varargin, {'wbcmd'});
    if isempty(options.wbcmd)
        options.wbcmd = 'wb_command';
    end
    [hdr, fid, cleanupObj] = read_nifti2_hdr(filename); %#ok<ASGLU>
    if isempty(hdr.extensions)
        error(['no cifti extension found in file ' filename]);
    end
    ciftiextindex = find(hdr.extensions.ecode == 32);
    if length(ciftiextindex) ~= 1
        error(['multiple cifti extensions found in file ' filename]);
    end
    %sanity check dims
    if hdr.dim(1) < 6 || any(hdr.dim(2:5) ~= 1)
        error(['wrong nifti dimensions for cifti file ' filename]);
    end
    try
        outstruct = cifti_parse_xml(hdr.extensions(ciftiextindex).edata, filename);
    catch excinfo
        if strcmp(excinfo.identifier, 'cifti:version')
            if mod(length(varargin), 2) == 1 && strcmp(varargin{end}, 'recursed') %guard against infinite recursion
                error('read_cifti internal error, cifti version conversion problem');
            end
            warning(['cifti file "' filename '" appears to not be version 2, converting using wb_command...']);
            [~, name, ext] = fileparts(filename);
            tmpfile = [tempname '.' name ext];
            cleanupObj = onCleanup(@()mydelete(tmpfile)); %make previous obj close our fid, make new cleanup obj to delete temp file
            my_system([options.wbcmd ' -file-convert -cifti-version-convert ' filename ' 2 ' tmpfile]);
            outstruct = read_cifti(tmpfile, [varargin, {'recursed'}]); %guard against infinite recursion
            return;
        end
        rethrow(excinfo);
    end
    dims_c = hdr.dim(6:(hdr.dim(1) + 1))'; %extract cifti dimensions from header
    dims_m = dims_c([2 1 3:length(dims_c)]); %for ciftiopen compatibility, first dimension for matlab code is down
    dims_xml = zeros(length(outstruct.diminfo), 1);
    for i = 1:length(outstruct.diminfo)
        dims_xml(i) = outstruct.diminfo{i}.length;
    end
    if any(dims_m ~= dims_xml)
        error(['xml dimensions disagree with nifti dimensions in cifti file ' filename]);
    end
    
    %find stored datatype
    switch hdr.datatype
        case 2
            intype = 'uint8';
            inbitpix = 8;
        case 4
            intype = 'int16';
            inbitpix = 16;
        case 8
            intype = 'int32';
            inbitpix = 32;
        case 16
            intype = 'float32';
            inbitpix = 32;
        case 64
            intype = 'float64';
            inbitpix = 64;
        case 256
            intype = 'int8';
            inbitpix = 8;
        case 512
            intype = 'uint16';
            inbitpix = 16;
        case 768
            intype = 'uint32';
            inbitpix = 32;
        case 1024
            intype = 'int64';
            inbitpix = 64;
        case 1280
            intype = 'uint64';
            inbitpix = 64;
        otherwise
            error(['unsupported datatype ' num2str(hdr.datatype) ' for cifti file ' filename]);
    end
    if hdr.bitpix ~= inbitpix
        warning(['mismatch between datatype (' num2str(hdr.datatype) ') and bitpix (' num2str(hdr.bitpix) ') in cifti file ' filename]);
    end
    %header reading does not seek to vox_offset
    if(fseek(fid, hdr.vox_offset, 'bof') ~= 0)
        error(['failed to seek to start of data in file ' filename]);
    end
    %always output as float32, maybe add a feature later
    %use 'cdata' to be compatible with old ciftiopen
    outstruct.cdata = fread_excepting(fid, hdr.dim(6:(hdr.dim(1) + 1)), [intype '=>float32'], filename);
    %apply scl_slope, scl_offset
    if ~(hdr.scl_slope == 0 || (hdr.scl_slope == 1 && hdr.scl_inter == 0))
        outstruct.cdata = outstruct.cdata .* hdr.scl_slope + hdr.scl_inter;
    end
    %permute to match ciftiopen: cifti "rows" matching matlab rows
    %hack: 3:2 produces empty array, 3:3 produces [3]
    outstruct.cdata = permute(outstruct.cdata, [2 1 3:(hdr.dim(1) - 4)]);
end
