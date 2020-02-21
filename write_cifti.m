function write_cifti(cifti, filename, keep_metadata)
    %function write_cifti(cifti, filename, keep_metadata)
    %   Write a cifti file.
    %
    %   The keep_metadata argument is optional: if false or not specified, the
    %   'Provenance' metadata is moved to 'ParentProvenance', 'Provenance' is
    %   given a generic value, and all other file-level metadata is removed.
    %
    %   >> cifti = read_cifti('91282_Greyordinates.dscalar.nii');
    %   >> cifti.cdata = outdata;
    %   >> cifti.diminfo{2} = cifti_make_scalar_diminfo(size(outdata, 2));
    %   >> write_cifti(cifti, 'ciftiout.dscalar.nii');
    if nargin < 3
        keep_metadata = false;
    end
    if length(cifti.diminfo) < 2 || length(cifti.diminfo) > 3
        error('cifti struct must have 2 or 3 maps');
    end
    if length(size(cifti.cdata)) ~= length(cifti.diminfo)
        error('number of data dimensions does not match cifti struct');
    end
    dims_m = size(cifti.cdata);
    dims_c = dims_m([2 1 3:length(dims_m)]); %ciftiopen convention, first matlab index is down
    dims_xml = zeros(1, length(cifti.diminfo));
    for i = 1:length(cifti.diminfo)
        dims_xml(i) = cifti.diminfo{i}.length;
    end
    if any(dims_m ~= dims_xml)
        error('dimension length mismatch between data and cifti struct');
    end
    %TODO: provenance?
    xmlbytes = cifti_write_xml(cifti, keep_metadata);
    header = make_nifti2_hdr();
    extension = struct('ecode', 32, 'edata', xmlbytes); %header writing function will pad the extensions with nulls
    header.extensions = extension; %don't need concatenation for only one nifti extension
    header.datatype = 16;
    header.bitpix = 32;
    header.dim(6:(6 + length(dims_c) - 1)) = dims_c;
    header.dim(1) = length(dims_c) + 4;
    [header.intent_code, header.intent_name] = cifti_intent_code(cifti, filename);
    [fid, header, cleanupObj] = write_nifti2_hdr(header, filename); %#ok<ASGLU> %header writing also computes vox_offset for us
    %the fseek probably isn't needed during writing, but to be safe
    if(fseek(fid, header.vox_offset, 'bof') ~= 0)
        error(['failed to seek to start data writing in file ' filename]);
    end
    fwrite_excepting(fid, permute(cifti.cdata, [2 1 3:length(size(cifti.cdata))]), 'float32');
end

function [code, string] = cifti_intent_code(cifti, filename)
    code = 3000;
    string = 'ConnUnknown';
    expectext = '';
    explain = '';
    numdims = length(cifti.diminfo); %this will be at least 2, we call this after checking dims (and after writing xml, so the types are all good)
    switch cifti.diminfo{1}.type %NOTE: column
        case 'dense'
            switch cifti.diminfo{2}.type
                case 'dense'
                    code = 3001; string = 'ConnDense'; expectext = '.dconn.nii'; explain = 'dense by dense';
                case 'series'
                    code = 3002; string = 'ConnDenseSeries'; expectext = '.dtseries.nii'; explain = 'series by dense'; %order by cifti convention rather than matlab?
                case 'scalars'
                    code = 3006; string = 'ConnDenseScalar'; expectext = '.dscalar.nii'; explain = 'scalars by dense';
                case 'labels'
                    code = 3007; string = 'ConnDenseLabel'; expectext = '.dlabel.nii'; explain = 'labels by dense';
                case 'parcels'
                    code = 3010; string = 'ConnDenseParcel'; expectext = '.dpconn.nii'; explain = 'parcels by dense';
            end
        case 'parcels'
            switch numdims
                case 3
                    if strcmp(cifti.diminfo{2}.type, 'parcels')
                        switch cifti.diminfo{3}.type
                            case 'series'
                                code = 3011; string = 'ConnPPSr'; expectext = '.pconnseries.nii'; explain = 'parcels by parcels by series';
                            case 'scalars'
                                code = 3012; string = 'ConnPPSc'; expectext = '.pconnscalar.nii'; explain = 'parcels by parcels by scalar';
                        end
                    end
                case 2
                    switch cifti.diminfo{2}.type
                        case 'parcels'
                            code = 3003; string = 'ConnParcels'; expectext = '.pconn.nii'; explain = 'parcels by parcels';
                        case 'series' %these two are max length to have a null terminator in the field
                            code = 3004; string = 'ConnParcelSries'; expectext = '.ptseries.nii'; explain = 'series by parcels';
                        case 'scalars'
                            code = 3008; string = 'ConnParcelScalr'; expectext = '.pscalar.nii'; explain = 'scalars by parcels';
                        case 'dense'
                            code = 3009; string = 'ConnParcelDense'; expectext = '.pdconn.nii'; explain = 'dense by parcels';
                    end
            end
    end
    if isempty(expectext)
        periods = find(filename == '.', 2, 'last');
        if length(periods) < 2 || length(filename) < 4 || ~myendswith(filename, '.nii')
            warning(['cifti file with nonstandard mapping combination "' filename '" should be saved ending in .<something>.nii']);
        else
            problem = true;
            switch filename(periods(1):end)
                case '.dconn.nii'
                case '.dtseries.nii'
                case '.dscalar.nii'
                case '.dlabel.nii'
                case '.dpconn.nii'
                case '.pconnseries.nii'
                case '.pconnscalar.nii'
                case '.pconn.nii'
                case '.ptseries.nii'
                case '.pscalar.nii'
                case '.pdconn.nii'
                case '.dfan.nii'
                case '.fiberTemp.nii'
                otherwise
                    problem = false;
            end
            if problem
                warning(['cifti file with nonstandard mapping combination "' filename '" should Not be saved using an already-used cifti extension, please choose a different, reasonable cifti extension of the form .<something>.nii']);
            end
        end
    else
        if ~myendswith(filename, expectext)
            if ~strcmp(expectext, '.dscalar.nii')
                warning([explain ' cifti file "' filename '" should be saved ending in ' expectext]);
            else
                if ~(myendswith(filename, '.dfan.nii') || myendswith(filename, '.fiberTEMP.nii'))
                    warning([explain ' cifti file "' filename '" should be saved ending in ' expectext]);
                end
            end
        end
    end
end
