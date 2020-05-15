function cifti = cifti_create_dscalar_from_template(ciftitemplate, data, varargin)
    %function cifti = cifti_create_dscalar_from_template(ciftitemplate, data, ...)
    %   Create a dscalar cifti object using the dense info from an existing cifti object
    %
    %   If the template cifti file has more than one dense dimension (such as dconn),
    %   you must use "..., 'dimension', 1" or similar to select the dimension to copy the
    %   dense mapping from.
    %
    %   The 'namelist' and 'metadatalist' options are also available for setting the
    %   contents of the scalar map, like:
    %
    %   newcifti = cifti_create_dscalar_from_template(oldcifti, newdata, 'namelist', {'sulc', 'curv'});
    options = myargparse(varargin, {'dimension', 'namelist', 'metadatalist'});
    if length(size(data)) ~= 2
        error('input data must be a 2D matrix');
    end
    if isempty(options.dimension)
        options.dimension = [];
        for i = 1:length(ciftitemplate.diminfo)
            if strcmp(ciftitemplate.diminfo{i}.type, 'dense')
                options.dimension = [options.dimension i]; %#ok<AGROW>
            end
        end
        if isempty(options.dimension)
            error('template cifti has no dense dimension');
        end
        if ~isscalar(options.dimension)
            error('template cifti has more than one dense dimension, you must specify the dimension to use');
        end
    else
        if ~isscalar(options.dimension)
            error('"dimension" option must be a single number');
        end
    end
    if ~strcmp(ciftitemplate.diminfo{options.dimension}.type, 'dense')
        error('selected dimension of template cifti file is not of type dense');
    end
    if size(data, 1) ~= ciftitemplate.diminfo{options.dimension}.length
        if size(data, 2) == ciftitemplate.diminfo{options.dimension}.length
            warning('input data is transposed, this could cause an undetected error when run on different data'); %accept transposed, but warn
            cifti.cdata = data';
        else
            error('input data does not have a dimension length matching the dense diminfo');
        end
    else
        cifti.cdata = data;
    end
    cifti.metadata = ciftitemplate.metadata;
    %HACK: any "empty" value for an option is treated as not specified by make_scalars, including empty string (which is myargparse's default)
    otherdiminfo = cifti_diminfo_make_scalars(size(cifti.cdata, 2), options.namelist, options.metadatalist);
    cifti.diminfo = {ciftitemplate.diminfo{options.dimension} otherdiminfo};
end
