function ciftisave(cifti, filename, varargin)
    %function ciftisave(cifti, filename, ...)
    %   Compatibility wrapper for write_cifti.
    if ~isfield(cifti, 'diminfo')
        error('cifti structure has no diminfo field, maybe use the old ciftisave code instead?');
    end
    tic;
    write_cifti(cifti, filename);
    toc; %for familiarity, have them output a timing?  the original ciftisave printed 2 timings...
end
