function paths = write_outputs(cfg, sweep, aligned, tDLMO, periods, paths_root)
%WRITE_OUTPUTS Export XLSX summary/report (and metadata for raster path).

    if nargin < 6 || isempty(paths_root)
        pkgRoot = fileparts(fileparts(which('n24light.defaults')));
        paths_root = fullfile(pkgRoot, 'outputs', cfg.case_id);
    end
    if ~isfolder(paths_root)
        mkdir(paths_root);
    end

    if ~isfield(cfg, 'report') || isempty(cfg.report)
        cfg.report = n24light.defaults().report;
    end
    rep = cfg.report;

    tau_tbl = sweep.tau_table;
    rmse_def = NaN;
    [~, iDef] = min(abs(tau_tbl.model_tau - cfg.tau_default));
    if ~isempty(iDef)
        rmse_def = tau_tbl.cbtmin_rmse(iDef);
    end

    if istable(sweep.best_ties) && ismember('model_tau', sweep.best_ties.Properties.VariableNames)
        tie_vals = sweep.best_ties.model_tau;
    else
        tie_vals = sweep.best_ties(:);
    end
    tie_str = strjoin(arrayfun(@(x) sprintf('%.4f', x), tie_vals, 'UniformOutput', false), ', ');

    keys = {'case_id'; 'reference_time'; 'tdlmo_hours'; 'sleep_light_overlap_h'};
    vals = {
        cfg.case_id
        char(aligned.reference_dt)
        tDLMO
        aligned.overlap.overlap_duration_h
    };

    if isfield(rep, 'include_sleep_onset_period') && rep.include_sleep_onset_period
        keys{end+1,1} = 'tau_estimated_sleep_onset_h'; vals{end+1,1} = periods.tau_sleep_onset_h;
        if isfield(periods, 'tau_sleep_onset_median_h') && isfinite(periods.tau_sleep_onset_median_h)
            keys{end+1,1} = 'tau_sleep_onset_median_h'; vals{end+1,1} = periods.tau_sleep_onset_median_h;
        end
        keys{end+1,1} = 'n_sleep_onsets';               vals{end+1,1} = periods.n_sleep_onsets;
    end

    if isfield(rep, 'include_amt6s_period') && rep.include_amt6s_period
        keys{end+1,1} = 'tau_estimated_amt6s_h'; vals{end+1,1} = periods.tau_amt6s_h;
        keys{end+1,1} = 'n_acrophase';            vals{end+1,1} = periods.n_acrophase;
    end

    if isfield(rep, 'include_best_fit_tau') && rep.include_best_fit_tau
        keys{end+1,1} = 'tau_best_fit_model_h';      vals{end+1,1} = sweep.best_tau;
        keys{end+1,1} = 'rmse_best_fit_h';           vals{end+1,1} = sweep.min_rmse;
        keys{end+1,1} = 'tau_best_fit_ties';          vals{end+1,1} = tie_str;
        keys{end+1,1} = 'n_acrophase_aligned_rmse';  vals{end+1,1} = sweep.tau_table.cbtmin_n(sweep.best_idx);
    end

    if isfield(rep, 'include_tau_default') && rep.include_tau_default
        keys{end+1,1} = 'tau_default_h';           vals{end+1,1} = cfg.tau_default;
        keys{end+1,1} = 'rmse_at_tau_default_h';  vals{end+1,1} = rmse_def;
    end

    n = numel(keys);
    labels = cell(n, 1);
    defs = cell(n, 1);
    for i = 1:n
        m = n24light.report_item_meta(keys{i});
        labels{i} = m.label;
        defs{i} = m.definition;
    end

    summary = table(labels, vals, defs, keys, ...
        'VariableNames', {'Item', 'Value', 'Definition', 'Technical_ID'});

    xlsxPath = fullfile(paths_root, [cfg.case_id '_tau_summary.xlsx']);

    if isfield(cfg, 'outputs') && isfield(cfg.outputs, 'export_summary_xlsx') ...
            && ~cfg.outputs.export_summary_xlsx
        paths.summary_xlsx = '';
        paths.output_dir = paths_root;
        return
    end

    writetable(summary, xlsxPath, 'Sheet', 'report');

    if ~isfield(rep, 'include_tau_sweep_table') || rep.include_tau_sweep_table
        tau_export = tau_tbl;
        tau_export.Properties.VariableNames = { ...
            'Model tau (h)', 'Phase error MAE (h)', 'Phase error RMSE (h)', ...
            'Acrophase points in RMSE', 'Model light period (h)'};
        writetable(tau_export, xlsxPath, 'Sheet', 'tau_sweep');
    end

    yesno = 'No';
    if aligned.overlap.has_overlap
        yesno = 'Yes';
    end
    align_tbl = table( ...
        aligned.overlap.sleep_span_h(1), aligned.overlap.sleep_span_h(2), ...
        aligned.overlap.light_span_h(1), aligned.overlap.light_span_h(2), ...
        aligned.overlap.overlap_h(1), aligned.overlap.overlap_h(2), ...
        {yesno}, ...
        'VariableNames', { ...
            'Sleep diary start (h from model start)', 'Sleep diary end (h from model start)', ...
            'Light data start (h from model start)', 'Light data end (h from model start)', ...
            'Overlap start (h)', 'Overlap end (h)', ...
            'Sleep and light data overlap?'});
    writetable(align_tbl, xlsxPath, 'Sheet', 'alignment');

    guide = table( ...
        {'report'; 'tau_sweep'; 'alignment'}, { ...
            'Key results; each row has a plain-language Item name, Value, and Definition.'; ...
            'One row per tested model tau; RMSE compares predicted CBTmin to measured acrophase.'; ...
            'Whether sleep diary and light files cover the same time window (hours from model start).'}, ...
        'VariableNames', {'Sheet', 'What it contains'});
    writetable(guide, xlsxPath, 'Sheet', 'guide');

    paths.summary_xlsx = xlsxPath;
    paths.output_dir = paths_root;
end
