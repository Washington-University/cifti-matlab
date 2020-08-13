function cifti = cifti_file_create_ptseries_from_template(ciftitemplate, data, varargin)
    %function cifti = cifti_file_create_ptseries_from_template(ciftitemplate, data, ...)
    %   Create a dtseries cifti object using the parcels info from an existing cifti object
    %
    %   If the template cifti file has more than one parcels dimension (such as dconn),
    %   you must use "..., 'dimension', 1" or similar to select the dimension to copy the
    %   parcels mapping from.
    %
    %   There are also 'start', 'step', and 'unit' options that default to 0, 1, and
    %   'SECOND', specify them like this:
    %
    %   newcifti = cifti_file_create_ptseries_from_template(oldcifti, newdata, 'step', 0.72);
    options = myargparse(varargin, {'start', 'step', 'unit', 'dimension'});
    if length(size(data)) ~= 2
        error('input data must be a 2D matrix');
    end
    if isempty(options.start)
        options.start = 0;
    end
    if isempty(options.step)
        options.step = 1;
    end
    if isempty(options.unit)
        options.unit = 'SECOND';
    end
    if isempty(options.dimension)
        options.dimension = [];
        for i = 1:length(ciftitemplate.diminfo)
            if strcmp(ciftitemplate.diminfo{i}.type, 'parcels')
                options.dimension = [options.dimension i];
            end
        end
        if isempty(options.dimension)
            error('template cifti has no parcels dimension');
        end
        if ~isscalar(options.dimension)
            error('template cifti has more than one parcels dimension, you must specify the dimension to use');
        end
    else
        if ~isscalar(options.dimension)
            error('"dimension" option must be a single number');
        end
    end
    if ~strcmp(ciftitemplate.diminfo{options.dimension}.type, 'parcels')
        error('selected dimension of template cifti file is not parcels type');
    end
    if size(data, 1) ~= ciftitemplate.diminfo{options.dimension}.length
        if size(data, 2) == ciftitemplate.diminfo{options.dimension}.length
            warning('input data is transposed, this could cause an undetected error when run on different data'); %accept transposed, but warn
            cifti.cdata = data';
        else
            error('input data does not have a dimension length matching the parcels diminfo');
        end
    else
        cifti.cdata = data;
    end
    cifti.metadata = ciftitemplate.metadata;
    cifti.diminfo = {ciftitemplate.diminfo{options.dimension} cifti_diminfo_make_series(size(cifti.cdata, 2), options.start, options.step, options.unit)};
end
