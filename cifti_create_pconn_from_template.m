function cifti = cifti_create_pconn_from_template(ciftitemplate, data, dimension)
    %function cifti = cifti_create_pconn_from_template(ciftitemplate, data, dimension)
    %   Create a square pconn from any parcels file and a square data matrix.
    %   Non-square pconns must be made manually by setting cifti.diminfo and cifti.cdata.
    %
    %   The dimension argument is optional except when the template is pconn or other
    %   types of cifti with more than one parcels dimension, and is used to select which
    %   dimension to copy the parcels mapping from.
    if size(data, 1) ~= size(data, 2)
        error('this function is only for making a square pconn from a pscalar or similar template, asymmetric pconns must be made manually by setting cifti.cdata to the new matrix');
    end
    if nargin < 3
        dimension = [];
        for i = 1:length(ciftitemplate.diminfo)
            if strcmp(ciftitemplate.diminfo{i}.type, 'parcels')
                dimension = [dimension i]; %#ok<AGROW>
            end
        end
        if isempty(dimension)
            error('template cifti has no parcels dimension');
        end
        if ~isscalar(dimension)
            error('template cifti has more than one parcels dimension, you must specify the dimension to use');
        end
    end
    if ~strcmp(ciftitemplate.diminfo{dimension}.type, 'parcels')
        error('selected dimension of template cifti file is not of type parcels');
    end
    if size(data, 1) ~= ciftitemplate.diminfo{dimension}.length
        error('input data has the wrong dimensions for the parcels diminfo');
    end
    cifti.cdata = data;
    cifti.metadata = ciftitemplate.metadata;
    cifti.diminfo = {ciftitemplate.diminfo{dimension} ciftitemplate.diminfo{dimension}};
end
