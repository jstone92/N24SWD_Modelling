function out = run_n24_case(cfgOrPath)
%RUN_N24_CASE Generalised pre-treatment tau sweep and raster export.
%   out = run_n24_case(cfgStruct)
%   out = run_n24_case('/path/to/N24_CaseConfig_MyCase.m')
%
%   See N24_CaseConfig_template.m and README.md (guidebook).

    setup_n24_toolbox();

    if isa(cfgOrPath, 'function_handle')
        userCfg = cfgOrPath();
    elseif ischar(cfgOrPath) || isstring(cfgOrPath)
        userCfg = load_config_script(char(cfgOrPath));
    elseif isstruct(cfgOrPath)
        userCfg = cfgOrPath;
    else
        error('n24light:Input', 'Provide a config struct or path to a .m config script.');
    end

    cfg = n24light.merge_config(userCfg);
    cfg = n24light.apply_ui_template_cols(cfg);
    n24light.validate_config(cfg);

    if strlength(cfg.output_dir) == 0
        pkgRoot = fileparts(mfilename('fullpath'));
        cfg.output_dir = fullfile(pkgRoot, 'outputs', cfg.case_id);
    end
    if ~isfolder(cfg.output_dir)
        mkdir(cfg.output_dir);
    end

    sleep = n24light.load_sleep_wake(cfg);
    light = n24light.load_light_epochs(cfg);
    acro  = n24light.load_acrophase(cfg);

    if isempty(light.sw)
        warning('n24light:Light', 'light_sw missing; assuming wake=1 for all epochs.');
        light.sw = ones(size(light.lux));
    end

    light = n24light.apply_light_cleaning(cfg, light);

    aligned = n24light.align_timelines(cfg, sleep, light, acro);
    if ~aligned.overlap.has_overlap
        warning('n24light:Align', ...
            'Sleep and light spans do not overlap (check datetime alignment).');
    else
        fprintf('Alignment OK: %.1f h overlap (ref = first light epoch %s).\n', ...
            aligned.overlap.overlap_duration_h, char(aligned.reference_dt));
    end

    tDLMO = n24light.estimate_initial_tdlmo(cfg, aligned.sleep_X);
    fprintf('Initial tDLMO = %.2f h (%s).\n', tDLMO, cfg.tdlmo_mode);

    periods = n24light.estimate_observed_periods(aligned.sleep_X, ...
        aligned.acrophase_cont, acro.dt);
    if isfinite(periods.tau_sleep_onset_h)
        fprintf('Estimated sleep-onset period = %.3f h (n=%d onsets).\n', ...
            periods.tau_sleep_onset_h, periods.n_sleep_onsets);
    end
    if isfinite(periods.tau_amt6s_h)
        fprintf('Estimated aMT6s period = %.3f h (n=%d acrophase).\n', ...
            periods.tau_amt6s_h, periods.n_acrophase);
    end

    sweep = n24light.run_tau_sweep(cfg, light.dn, light.lux, light.sw, ...
        acro.dt, aligned.reference_dn, tDLMO);

    [~, iDef] = min(abs(sweep.tau_table.model_tau - cfg.tau_default));
    [~, iBest] = min(sweep.tau_table.cbtmin_rmse, [], 'omitnan');
    cbt_default = sweep.cbt_by_tau{iDef};
    cbt_best = sweep.cbt_by_tau{iBest};

    fprintf('Best tau = %.3f h (RMSE = %.3f h, n = %d).\n', ...
        sweep.tau_table.model_tau(iBest), ...
        sweep.tau_table.cbtmin_rmse(iBest), ...
        sweep.tau_table.cbtmin_n(iBest));
    if height(sweep.best_ties) > 1
        fprintf('Tied best RMSE at tau: ');
        disp(sweep.best_ties.model_tau);
    end

    export_tiff = true;
    if isfield(cfg, 'outputs') && isfield(cfg.outputs, 'export_raster_tiff')
        export_tiff = cfg.outputs.export_raster_tiff;
    end

    hFig = [];
    paths = struct();
    if export_tiff
        hFig = n24light.build_raster_figure(cfg, aligned, ...
            aligned.acrophase_cont, cbt_default, cbt_best, sweep, light.lux, light.sw);
        tifPath = fullfile(cfg.output_dir, [cfg.case_id '_tau_raster.tif']);
        set(hFig, 'PaperUnits', 'inches', 'PaperPosition', [0 0 11.69 8.27]);
        print(hFig, tifPath, '-dtiff', ['-r' num2str(cfg.export_dpi)]);
        fprintf('Saved raster: %s\n', tifPath);
        paths.raster_tiff = tifPath;
    end

    paths = n24light.write_outputs(cfg, sweep, aligned, tDLMO, periods, cfg.output_dir);
    if isfield(paths, 'summary_xlsx') && ~isempty(paths.summary_xlsx)
        fprintf('Saved summary: %s\n', paths.summary_xlsx);
    end

    out = struct();
    out.cfg = cfg;
    out.aligned = aligned;
    out.sweep = sweep;
    out.periods = periods;
    out.tDLMO = tDLMO;
    out.paths = paths;
    out.figure = hFig;
end

function cfg = load_config_script(fpath)
    if ~isfile(fpath)
        error('n24light:Config', 'Config file not found: %s', fpath);
    end
    [cfgDir, cfgName] = fileparts(fpath);
    addpath(cfgDir, '-begin');
    if exist(cfgName, 'file') == 2
        cfg = feval(cfgName);
    else
        run(fpath);
        if ~evalin('base', 'exist(''cfg'',''var'')')
            error('n24light:Config', ...
                'Script must define cfg in base workspace, or use a function config (function cfg = name()).');
        end
        cfg = evalin('base', 'cfg');
    end
    if isfield(cfg, 'case_id') && ischar(cfg.case_id)
        cfg.case_id = strtrim(cfg.case_id);
    end
end
