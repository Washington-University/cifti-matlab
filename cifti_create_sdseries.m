function cifti = cifti_create_sdseries(data, start, step, unit)
    %function cifti = cifti_create_sdseries(data, start, step, unit)
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
    cifti.diminfo{1} = cifti_diminfo_make_series(size(data, 1), start, step, unit);
    cifti.diminfo{2} = cifti_diminfo_make_scalars(size(data, 2));
end
