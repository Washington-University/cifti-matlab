function cifti = cifti_create_dconn_from_template(ciftitemplate, data, varargin)
    %function cifti = cifti_create_dconn_from_template(ciftitemplate, data, ...)
    %   Create a square dconn from any dense file and a square data matrix.
    %   Non-square dconns must be made manually by setting cifti.diminfo and cifti.cdata.
    %
    %   If the template cifti file has more than one dense dimension (such as dconn),
    %   you must use "..., 'dimension', 1" or similar to select the dimension to copy the
    %   dense mapping from.
    options = myargparse(varargin, {'dimension'});
    if length(size(data)) ~= 2
        error('input data must be a 2D matrix');
    end
    if size(data, 1) ~= size(data, 2)
        error('this function is only for making a square dconn from a dscalar or similar template, asymmetric dconns must be made manually by setting cifti.cdata to the new matrix');
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
    end
    if ~strcmp(ciftitemplate.diminfo{options.dimension}.type, 'dense')
        error('selected dimension of template cifti file is not of type dense');
    end
    if size(data, 1) ~= ciftitemplate.diminfo{options.dimension}.length
        error('input data has the wrong dimensions for the dense diminfo');
    end
    cifti.cdata = data;
    cifti.metadata = ciftitemplate.metadata;
    cifti.diminfo = {ciftitemplate.diminfo{options.dimension} ciftitemplate.diminfo{options.dimension}};
end
