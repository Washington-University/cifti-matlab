function cifti = cifti_create_dconn_from_template(ciftitemplate, data, dimension)
    %function cifti = cifti_create_dconn_from_template(ciftitemplate, data, dimension)
    %   Create a square dconn from any dense file and a square data matrix.
    %   Non-square dconns must be made manually by setting cifti.diminfo and cifti.cdata.
    %
    %   The dimension argument is optional except when the template is dconn or other
    %   types of cifti with more than one dense dimension, and is used to select which
    %   dimension to copy the dense mapping from.
    if size(data, 1) ~= size(data, 2)
        error('this function is only for making a square dconn from a dscalar or similar template, asymmetric dconns must be made manually by setting cifti.cdata to the new matrix');
    end
    if nargin < 3
        dimension = [];
        for i = 1:length(ciftitemplate.diminfo)
            if strcmp(ciftitemplate.diminfo{i}.type, 'dense')
                dimension = [dimension i]; %#ok<AGROW>
            end
        end
        if isempty(dimension)
            error('template cifti has no dense dimension');
        end
        if ~isscalar(dimension)
            error('template cifti has more than one dense dimension, you must specify the dimension to use');
        end
    end
    if ~strcmp(ciftitemplate.diminfo{dimension}.type, 'dense')
        error('selected dimension of template cifti file is not of type dense');
    end
    if size(data, 1) ~= ciftitemplate.diminfo{dimension}.length
        error('input data has the wrong dimensions for the dense diminfo');
    end
    cifti.cdata = data;
    cifti.metadata = ciftitemplate.metadata;
    cifti.diminfo = {ciftitemplate.diminfo{dimension} ciftitemplate.diminfo{dimension}};
end
