function outmap = cifti_diminfo_make_series(nummaps, start, step, unit)
    %function outmap = cifti_diminfo_make_series(nummaps, start, step, unit)
    %   Create a new series diminfo object.
    %
    %   Only the nummaps argument is required.
    if nargin < 2
        start = 0;
    end
    if nargin < 3
        step = 1;
    end
    if nargin < 4
        unit = 'SECOND';
    end
    if ~isscalar(start) || ~isnumeric(start)
        error('series start must be a number');
    end
    if ~isscalar(step) || ~isnumeric(step)
        error('series step must be a number');
    end
    switch unit
        case 'SECOND'
        case 'HERTZ'
        case 'METER'
        case 'RADIAN'
        otherwise
            error(['invalid unit "' unit '"']);
    end
    outmap = struct('type', 'series', 'length', nummaps, 'seriesStart', start, 'seriesStep', step, 'seriesUnit', unit);
end
