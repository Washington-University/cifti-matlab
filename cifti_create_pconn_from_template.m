function cifti = cifti_create_pconn_from_template(ciftitemplate, data, varargin)
    %function cifti = cifti_create_pconn_from_template(ciftitemplate, data, ...)
    %   Create a square pconn from any parcels file and a square data matrix.
    %   Non-square pconns must be made manually by setting cifti.diminfo and cifti.cdata.
    %
    %   If the template cifti file has more than one parcels dimension (such as pconn),
    %   you must use "..., 'dimension', 1" or similar to select the dimension to copy the
    %   parcels mapping from.
    options = myargparse(varargin, {'dimension'});
    if length(size(data)) ~= 2
        error('input data must be a 2D matrix');
    end
    if size(data, 1) ~= size(data, 2)
        error('this function is only for making a square pconn from a pscalar or similar template, asymmetric pconns must be made manually by setting cifti.cdata to the new matrix');
    end
    if isempty(options.dimension)
        options.dimension = [];
        for i = 1:length(ciftitemplate.diminfo)
            if strcmp(ciftitemplate.diminfo{i}.type, 'parcels')
                options.dimension = [options.dimension i]; %#ok<AGROW>
            end
        end
        if isempty(options.dimension)
            error('template cifti has no parcels dimension');
        end
        if ~isscalar(options.dimension)
            error('template cifti has more than one parcels dimension, you must specify the dimension to use');
        end
    end
    if ~strcmp(ciftitemplate.diminfo{options.dimension}.type, 'parcels')
        error('selected dimension of template cifti file is not of type parcels');
    end
    if size(data, 1) ~= ciftitemplate.diminfo{options.dimension}.length
        error('input data has the wrong dimensions for the parcels diminfo');
    end
    cifti.cdata = data;
    cifti.metadata = ciftitemplate.metadata;
    cifti.diminfo = {ciftitemplate.diminfo{options.dimension} ciftitemplate.diminfo{options.dimension}};
end
