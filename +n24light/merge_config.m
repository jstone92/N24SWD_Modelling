function cfg = merge_config(userCfg)
%MERGE_CONFIG Combine user config with package defaults (recursive over fields).

    cfg = n24light.defaults();
    if nargin < 1 || isempty(userCfg)
        return
    end
    cfg = local_merge(cfg, userCfg);
end

function out = local_merge(base, over)
    out = base;
    fn = fieldnames(over);
    for i = 1:numel(fn)
        key = fn{i};
        if isstruct(over.(key)) && isfield(base, key) && isstruct(base.(key))
            out.(key) = local_merge(base.(key), over.(key));
        else
            out.(key) = over.(key);
        end
    end
end
