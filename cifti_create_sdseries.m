function cifti = cifti_create_sdseries(data, start, step, unit, namelist, metadatalist)
    %function cifti = cifti_create_sdseries(data, start, step, unit, namelist, metadatalist)
    %   Construct an sdseries cifti object around the 2D data matrix.
    %
    %   Only the data argument is required.
    if nargin < 2
        start = 0;
    end
    if nargin < 3
        step = 1;
    end
    if nargin < 4
        unit = 'SECOND'; %let make_series sanity check whatever the user gave
    end
    cifti = struct('cdata', data, 'metadata', {{}}, 'diminfo', {cell(1, 2)});
    if nargin < 5
        cifti.diminfo{1} = cifti_diminfo_make_scalars(size(data, 1));
    elseif nargin < 6
        cifti.diminfo{1} = cifti_diminfo_make_scalars(size(data, 1), namelist);
    else
        cifti.diminfo{1} = cifti_diminfo_make_scalars(size(data, 1), namelist, metadatalist);
    end
    cifti.diminfo{2} = cifti_diminfo_make_series(size(data, 2), start, step, unit);
end
