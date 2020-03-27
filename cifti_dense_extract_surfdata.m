function [outdata, outroi] = cifti_dense_extract_surfdata(cifti, structure, dimension)
    %function [outdata, outroi] = cifti_dense_extract_surfdata(cifti, structure, dimension)
    %   Extract the data for one cifti surface structure, expanding it to the full number of vertices.
    %   Vertices without data are given a value of 0, and outroi is a logical that is only
    %   true for vertices that have data.
    %
    %   The dimension argument is optional except for dconn files (generally, use 2 for dconn).
    %   The cifti object must have exactly 2 dimensions.
    if length(cifti.diminfo) < 2
        error('cifti objects must have 2 or 3 dimensions');
    end
    if length(cifti.diminfo) > 2
        error('this function only operates on 2D cifti, use cifti_dense_get_surface_mapping instead');
    end
    if nargin < 3
        dimension = [];
        for i = 1:2
            if strcmp(cifti.diminfo{i}.type, 'dense')
                dimension = [dimension i]; %#ok<AGROW>
            end
        end
        if isempty(dimension)
            error('cifti object has no dense dimension');
        end
        if ~isscalar(dimension)
            error('dense by dense cifti (aka dconn) requires specifying the dimension argument');
        end
    end
    otherdim = 3 - dimension;
    [vertlist, ciftilist, numverts] = cifti_dense_get_surf_map(cifti.diminfo{dimension}, structure);
    outroi = false(numverts, 1);
    outroi(vertlist) = true;
    outdata = zeros(numverts, size(cifti.cdata, otherdim), 'single');
    if dimension == 1
        outdata(vertlist, :) = cifti.cdata(ciftilist, :);
    else
        outdata(vertlist, :) = cifti.cdata(:, ciftilist);
    end
end
