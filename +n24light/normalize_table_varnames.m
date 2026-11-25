function T = normalize_table_varnames(T)
%NORMALIZE_TABLE_VARNAMES Strip BOM/whitespace from header names.

    vn = T.Properties.VariableNames;
    if isempty(vn)
        return
    end
    for i = 1:numel(vn)
        s = char(vn{i});
        s = regexprep(s, '^\x{FEFF}', '', 'once');
        vn{i} = strtrim(s);
    end
    T.Properties.VariableNames = vn;
end
