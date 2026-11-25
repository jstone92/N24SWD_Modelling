function acro = load_acrophase(cfg)
%LOAD_ACROPHASE Load measured aMT6s acrophase times (datetime only).

    T = n24light.read_table_cfg(cfg, cfg.acrophase_file);
    vn = T.Properties.VariableNames;
    col = n24light.match_varname(vn, {cfg.cols.acrophase_dt, 'AcrophaseDateTime', ...
        'Acrophase_DT', 'Acrophase', 'aMT6s_Acrophase', 'DateTime'});
    if isempty(col)
        error('n24light:Acrophase', ...
            'Acrophase file needs a datetime column (e.g. AcrophaseDateTime). Found: %s', ...
            strjoin(vn, ', '));
    end
    dt = T.(col)(:);
    if ~isdatetime(dt)
        dt = datetime(dt);
    end
  valid = ~isnat(dt);
    if ~any(valid)
        error('n24light:Acrophase', 'No valid acrophase datetimes.');
    end
    acro.dt = dt(valid);
    acro.dt = sort(acro.dt);
end
