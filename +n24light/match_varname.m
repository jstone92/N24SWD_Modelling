function name = match_varname(varNames, candidates)
%MATCH_VARNAME First table variable name matching any candidate (case-insensitive).

    if isstring(varNames)
        varNames = cellstr(varNames);
    end
    varNames = cellfun(@(s) strtrim(char(s)), varNames, 'UniformOutput', false);

    for k = 1:numel(candidates)
        want = strtrim(char(candidates{k}));
        if strlength(want) == 0
            continue
        end
        idx = strcmp(varNames, want);
        if any(idx)
            name = varNames{find(idx, 1)};
            return
        end
        idx = strcmpi(varNames, want);
        if any(idx)
            name = varNames{find(idx, 1)};
            return
        end
    end
    name = '';
end
