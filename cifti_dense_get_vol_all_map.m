function [voxlist1, ciftilist, voldims, volsform1] = cifti_dense_get_vol_all_map(diminfo, cropped)
    %function [voxlist1, ciftilist, voldims, volsform1] = cifti_dense_get_vol_all_map(diminfo, cropped)
    %   Get information on how to map cifti indices to voxels.
    %   If cropped is true, the voxlist, voldims, and volsform1 are all
    %   adjusted to the minimum bounding box of the valid voxels.
    %   The volsform1 output is adjusted so that 1-based voxel indices (as returned
    %   in voxlist1) can be multiplied through and give the correct coordinates.
    %
    %   The cropped argument is optional and defaults to false.
    %
    %   >> [voxlist1, ciftilist, voldims, volsform1] = cifti_dense_get_vol_all_mapping(cifti.diminfo{1});
    %   >> extracted = zeros(voldims, 'single');
    %   >> extracted(cifti_vox2ind(voldims, voxlist1)) = cifti.cdata(ciftilist, 1);
    if nargin < 2
        cropped = false;
    end
    if ~isstruct(diminfo) || ~strcmp(diminfo.type, 'dense')
        error('this function must be called on a diminfo element with type "dense"');
    end
    voldims = [-1 -1 -1]; %return empty and -1 for not found
    volsform1 = zeros(4) - 1;
    voxlist1 = [];
    ciftilist = [];
    if isfield(diminfo.vol, 'dims')
        voldims = diminfo.vol.dims;
        %sform in cifti struct is for 0-based indices
        volsform1 = diminfo.vol.sform;
        volsform1(:, 4) = volsform1 * [-1 -1 -1 1]'; %set the offset to the coordinates of the -1 -1 -1 0-based voxel, so that 1-based voxel indices give the correct coordinates
        for i = 1:length(diminfo.models)
            if strcmp(diminfo.models{i}.type, 'vox')
                %voxel indices in cifti struct are 0-based
                voxlist1 = [voxlist1; diminfo.models{i}.voxlist + 1]; %#ok<AGROW>
                ciftilist = [ciftilist; (diminfo.models{i}.start:(diminfo.models{i}.start + diminfo.models{i}.count - 1))']; %#ok<AGROW>
            end
        end
        if cropped
            lowcorner = min(voxlist1);
            highcorner = max(voxlist1);
            volsform1(1:3, 4) = volsform1(1:3, 4) + volsform1(1:3, 1:3) * (lowcorner - 1)';
            voxlist1 = voxlist1 - repmat(lowcorner - 1, size(voxlist1, 1), 1);
            voldims = highcorner - lowcorner + 1;
        end
        %models from read_cifti should already be sorted by cifti index
    end
end
