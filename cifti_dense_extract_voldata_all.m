function [outdata, outsform1, outroi] = cifti_dense_extract_voldata_all(cifti, cropped, dimension)
    %function [outdata, outsform1, outroi] = cifti_dense_extract_voldata_all(cifti, cropped, dimension)
    %   Extract the data for all cifti volume structures, expanding it to volume frames.
    %   Voxels without data are given a value of zero, and outroi is a logical that is only
    %   true for voxels that have data.
    %
    %   The cropped argument is optional and defaults to false, returning a volume with
    %   the full original dimensions.
    %   The dimension argument is optional except for dconn files (generally, use 2 for dconn).
    %   The cifti object must have exactly 2 dimensions.
    if length(cifti.diminfo) < 2
        error('cifti objects must have 2 or 3 dimensions');
    end
    if length(cifti.diminfo) > 2
        error('this function only operates on 2D cifti, use cifti_dense_get_surface_mapping instead');
    end
    if nargin < 2
        cropped = false;
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
    otherlength = size(cifti.cdata, otherdim);
    [voxlist1, ciftilist, voldims, outsform1] = cifti_dense_get_vol_all_map(cifti.diminfo{dimension}, cropped);
    assert(length(voldims) == 3);
    indlist = cifti_vox2ind(voldims, voxlist1);
    outroi = false(voldims);
    outroi(indlist) = true;
    outdata = zeros([voldims otherlength], 'single');
    if otherlength == 1 %don't loop if we don't need to
        outdata(indlist) = cifti.cdata(ciftilist);
    else
        tempframe = zeros(voldims, 'single');
        %need a dimension after the ind2sub result, so loop
        for i = 1:size(cifti.cdata, otherdim)
            if dimension == 1
                tempframe(indlist) = cifti.cdata(ciftilist, i);
            else
                tempframe(indlist) = cifti.cdata(i, ciftilist);
            end
            outdata(:, :, :, i) = tempframe;
        end
    end
end
