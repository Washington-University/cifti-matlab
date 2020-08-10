function outinfo = cifti_dense_get_vol_all_map(diminfo, cropped)
    %function outinfo = cifti_dense_get_vol_all_map(diminfo, cropped)
    %   Get information on how to map cifti indices to voxels.
    %   The volsform1 field is adjusted so that 1-based voxel indices (as returned
    %   in voxlist1) can be multiplied through and give the correct coordinates.
    %
    %   The cropped argument is optional and defaults to false.
    %   If it is true, then the voxlist1, voldims, and volsform1 fields are all
    %   adjusted to the minimum bounding box of the valid voxels.
    %
    %   >> voxinfo = cifti_dense_get_vol_all_mapping(cifti.diminfo{1});
    %   >> extracted = zeros(voxinfo.voldims, 'single');
    %   >> extracted(cifti_vox2ind(voxinfo.voldims, voxinfo.voxlist1)) = cifti.cdata(voxinfo.ciftilist, 1);
    if nargin < 2
        cropped = false;
    end
    if ~isstruct(diminfo) || ~strcmp(diminfo.type, 'dense')
        error('this function must be called on a diminfo element with type "dense"');
    end
    outinfo = struct();
    outinfo.voldims = [-1 -1 -1]; %return empty and -1 for not found
    outinfo.volsform1 = zeros(4) - 1;
    outinfo.voxlist1 = [];
    outinfo.ciftilist = [];
    if isfield(diminfo.vol, 'dims')
        outinfo.voldims = diminfo.vol.dims;
        %sform in cifti struct is for 0-based indices
        outinfo.volsform1 = diminfo.vol.sform;
        outinfo.volsform1(:, 4) = outinfo.volsform1 * [-1 -1 -1 1]'; %set the offset to the coordinates of the -1 -1 -1 0-based voxel, so that 1-based voxel indices give the correct coordinates
        for i = 1:length(diminfo.models)
            if strcmp(diminfo.models{i}.type, 'vox')
                %voxel indices in cifti struct are 0-based
                outinfo.voxlist1 = [outinfo.voxlist1 diminfo.models{i}.voxlist + 1];
                outinfo.ciftilist = [outinfo.ciftilist diminfo.models{i}.start:(diminfo.models{i}.start + diminfo.models{i}.count - 1)];
            end
        end
        if cropped
            lowcorner = min(outinfo.voxlist1, [], 2);
            highcorner = max(outinfo.voxlist1, [], 2);
            outinfo.volsform1(1:3, 4) = outinfo.volsform1(1:3, 4) + outinfo.volsform1(1:3, 1:3) * (lowcorner - 1);
            outinfo.voxlist1 = outinfo.voxlist1 - repmat(lowcorner - 1, 1, size(outinfo.voxlist1, 2));
            outinfo.voldims = (highcorner - lowcorner + 1)';
        end
        %models from read_cifti should already be sorted by cifti index
    end
end
