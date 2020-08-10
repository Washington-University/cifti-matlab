function outinfo = cifti_dense_get_surf_map(diminfo, structure)
    %function outinfo = cifti_dense_get_surf_map(diminfo, structure)
    %   Get information on how to map cifti indices to gifti surface vertices.
    %
    %   >> leftinfo = cifti_dense_get_surf_map(cifti.diminfo{1}, 'CORTEX_LEFT');
    %   >> extracted = zeros(leftinfo.numverts, 1, 'single');
    %   >> extracted(leftinfo.vertlist1) = cifti.cdata(leftmap.ciftilist, 1);
    if ~isstruct(diminfo) || ~strcmp(diminfo.type, 'dense')
        error('this function must be called on a diminfo element with type "dense"');
    end
    outinfo = struct();
    outinfo.numverts = -1; %return empty and -1 for not found, should be friendlier than an error
    outinfo.vertlist1 = [];
    outinfo.ciftilist = [];
    for i = 1:length(diminfo.models)
        if strcmp(diminfo.models{i}.type, 'surf') && strcmp(diminfo.models{i}.struct, structure)
            outinfo.numverts = diminfo.models{i}.numvert;
            outinfo.vertlist1 = diminfo.models{i}.vertlist + 1; %structure uses 0-based indexing
            outinfo.ciftilist = diminfo.models{i}.start:(diminfo.models{i}.start + diminfo.models{i}.count - 1);
            return;
        end
    end
end
