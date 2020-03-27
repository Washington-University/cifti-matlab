function [vertlist1, ciftilist, numverts] = cifti_dense_get_surf_map(diminfo, structure)
    %function [vertlist1, ciftilist, numverts] = cifti_dense_get_surf_map(diminfo, structure)
    %   Get information on how to map cifti indices to gifti surface vertices.
    %
    %   >> [vertlist1, ciftilist, numverts] = cifti_dense_get_surface_mapping(cifti.diminfo{1}, 'CORTEX_LEFT');
    %   >> extracted = zeros(numverts, 1, 'single');
    %   >> extracted(vertlist1) = cifti.cdata(ciftilist, 1);
    if ~isstruct(diminfo) || ~strcmp(diminfo.type, 'dense')
        error('this function must be called on a diminfo element with type "dense"');
    end
    numverts = -1; %return empty and -1 for not found, should be friendlier than an error
    vertlist1 = [];
    ciftilist = [];
    for i = 1:length(diminfo.models)
        if strcmp(diminfo.models{i}.type, 'surf') && strcmp(diminfo.models{i}.struct, structure)
            numverts = diminfo.models{i}.numvert;
            vertlist1 = diminfo.models{i}.vertlist + 1; %structure uses 0-based indexing
            ciftilist = (diminfo.models{i}.start:(diminfo.models{i}.start + diminfo.models{i}.count - 1))';
            return;
        end
    end
end
