function T = read_table_cfg(cfg, fpath)
%READ_TABLE_CFG Read sleep/light/acrophase file (xlsx or csv).

    [~,~,ext] = fileparts(fpath);
    fmt = lower(cfg.file_format);
    if strcmp(fmt, 'auto')
        if any(strcmpi(ext, {'.xlsx','.xls'}))
            fmt = 'xlsx';
        else
            fmt = 'csv';
        end
    end

    switch fmt
        case 'xlsx'
            T = readtable(fpath, 'VariableNamingRule', 'preserve');
        case 'csv'
            T = readtable(fpath, 'VariableNamingRule', 'preserve');
        otherwise
            error('n24light:IO', 'Unsupported file format for %s', fpath);
    end
    T = n24light.normalize_table_varnames(T);
end
