function outstruct = myargparse(myvarargs, allowed)
    for i = 1:length(allowed)
        outstruct.(allowed{i}) = '';
    end
    for i = 1:2:(length(myvarargs) - 1) %need to allow for a solitary 'recursed' on the end of the arguments
        if isfield(outstruct, myvarargs{i})
            outstruct.(myvarargs{i}) = myvarargs{i + 1};
        else
            error(['unknown optional parameter specified: "' myvarargs{i} '"']);
        end
    end
end
