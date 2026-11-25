function N24TauTestingApp_classic()
%N24TAUTESTINGAPP_CLASSIC Legacy figure/uicontrol UI when uifigure is unavailable.

    fig = figure('Name', 'N24 tau testing', 'NumberTitle', 'off', ...
        'MenuBar', 'none', 'ToolBar', 'none', ...
        'Position', [80 40 720 780], 'Resize', 'on');

    uicontrol(fig, 'Style', 'text', 'Units', 'normalized', ...
        'Position', [0.03 0.93 0.94 0.05], 'String', 'N24 light / tau testing', ...
        'FontWeight', 'bold', 'HorizontalAlignment', 'left');

    y = 0.90;
    dy = 0.038;
    logBottom = 0.02;
    logHeight = 0.14;
    btnBarY = logBottom + logHeight + 0.02;
    h = struct();
    h.fig = fig;

    h.editCase = addRow(fig, y, 'Case ID', 'CASE001', ''); y = y - dy;
    h.editOut  = addRow(fig, y, 'Output folder', '', 'folder'); y = y - dy;
    h.editSleep = addRow(fig, y, 'Sleep-wake file', '', 'file'); y = y - dy;
    h.editLight = addRow(fig, y, 'Light epochs file', '', 'file'); y = y - dy;
    h.editAcro  = addRow(fig, y, 'aMT6s acrophase file', '', 'file'); y = y - dy;

    uicontrol(fig, 'Style', 'text', 'Units', 'normalized', ...
        'Position', [0.03 y 0.4 0.035], 'String', 'Model and search', ...
        'FontWeight', 'bold', 'HorizontalAlignment', 'left');
    y = y - dy;

    h.editTauMin  = addRow(fig, y, 'tau min (h)', '24', ''); y = y - dy;
    h.editTauMax  = addRow(fig, y, 'tau max (h)', '25.5', ''); y = y - dy;
    h.editTauStep = addRow(fig, y, 'tau step (h)', '0.05', ''); y = y - dy;
    h.editTauDef  = addRow(fig, y, 'Default tau (h)', '24.15', ''); y = y - dy;
    h.editClock   = addRow(fig, y, 'Clock hour start of raster (h)', '6', ''); y = y - dy;

    uicontrol(fig, 'Style', 'text', 'Units', 'normalized', ...
        'Position', [0.03 y+0.005 0.22 0.032], 'String', 'Initial tDLMO', ...
        'HorizontalAlignment', 'left');
    h.popTdlmo = uicontrol(fig, 'Style', 'popupmenu', 'Units', 'normalized', ...
        'Position', [0.26 y 0.28 0.034], ...
        'String', {'Auto (first sleep bout)', 'Manual'}, ...
        'Callback', @(~,~) onTdlmoMode(fig));
    h.editTdlmo = uicontrol(fig, 'Style', 'edit', 'Units', 'normalized', ...
        'Position', [0.56 y 0.12 0.034], 'String', '11', 'Enable', 'off');
    y = y - dy;

    h.chkClean = uicontrol(fig, 'Style', 'checkbox', 'Units', 'normalized', ...
        'Position', [0.26 y 0.65 0.034], ...
        'String', 'Optional light cleaning (getCleanLit)', 'Value', 0);
    y = y - dy * 0.85;
    h.chkPlotLight = uicontrol(fig, 'Style', 'checkbox', 'Units', 'normalized', ...
        'Position', [0.26 y 0.68 0.034], ...
        'String', 'Show measured light on raster (lux bands; wake epochs)', 'Value', 1);
    y = y - dy * 0.9;

    uicontrol(fig, 'Style', 'text', 'Units', 'normalized', ...
        'Position', [0.03 y 0.6 0.035], 'String', 'Report (XLSX)', 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'left');
    y = y - dy * 0.95;

    h.chkRepSleep = mkCheck(fig, 0.26, y, 'Sleep-onset period', 1);
    h.chkRepAmt6  = mkCheck(fig, 0.26, y - dy * 0.85, 'aMT6s period', 1);
    h.chkRepBest  = mkCheck(fig, 0.52, y, 'Best-fit tau + RMSE', 1);
    h.chkRepDef   = mkCheck(fig, 0.52, y - dy * 0.85, 'Default tau RMSE', 1);
    h.chkRepSweep = mkCheck(fig, 0.26, y - dy * 1.7, 'Full tau sweep table', 1);

    yExport = btnBarY + 0.055;
    h.chkOutTiff = mkCheck(fig, 0.26, yExport, 'Export raster TIFF', 1);
    h.chkOutXlsx = mkCheck(fig, 0.52, yExport, 'Export summary XLSX', 1);

    uicontrol(fig, 'Style', 'pushbutton', 'Units', 'normalized', ...
        'Position', [0.72 btnBarY 0.22 0.048], 'String', 'Run analysis', ...
        'FontWeight', 'bold', 'Callback', @(~,~) onRun(fig));

    uicontrol(fig, 'Style', 'pushbutton', 'Units', 'normalized', ...
        'Position', [0.03 btnBarY 0.2 0.048], 'String', 'Load synthetic example', ...
        'Callback', @(~,~) loadSynthetic(fig));

    h.listLog = uicontrol(fig, 'Style', 'listbox', 'Units', 'normalized', ...
        'Position', [0.03 logBottom 0.94 logHeight], ...
        'String', {'Ready. Set files and options, then Run analysis.'}, ...
        'Max', 1, 'Min', 0, 'FontName', 'FixedWidth');

    guidata(fig, h);
end

function editH = addRow(fig, y, label, defaultVal, browseMode)
    uicontrol(fig, 'Style', 'text', 'Units', 'normalized', ...
        'Position', [0.03 y+0.005 0.22 0.032], 'String', label, ...
        'HorizontalAlignment', 'left');
    editH = uicontrol(fig, 'Style', 'edit', 'Units', 'normalized', ...
        'Position', [0.26 y 0.44 0.034], 'String', defaultVal, ...
        'HorizontalAlignment', 'left');
    if strcmp(browseMode, 'file')
        uicontrol(fig, 'Style', 'pushbutton', 'Units', 'normalized', ...
            'Position', [0.72 y 0.22 0.034], 'String', 'Browse', ...
            'Callback', @(~,~) browseFile(editH));
    elseif strcmp(browseMode, 'folder')
        uicontrol(fig, 'Style', 'pushbutton', 'Units', 'normalized', ...
            'Position', [0.72 y 0.22 0.034], 'String', 'Browse', ...
            'Callback', @(~,~) browseFolder(editH));
    end
end

function h = mkCheck(fig, x, y, label, val)
    h = uicontrol(fig, 'Style', 'checkbox', 'Units', 'normalized', ...
        'Position', [x y 0.42 0.034], 'String', label, 'Value', val);
end

function onTdlmoMode(fig)
    h = guidata(fig);
    if get(h.popTdlmo, 'Value') == 2
        set(h.editTdlmo, 'Enable', 'on');
    else
        set(h.editTdlmo, 'Enable', 'off');
    end
end

function browseFile(editH)
    [f, p] = uigetfile({'*.xlsx;*.xls;*.csv', 'Tables (*.xlsx, *.csv)'}, 'Select file');
    if isequal(f, 0), return; end
    set(editH, 'String', fullfile(p, f));
end

function browseFolder(editH)
    d = uigetdir(pwd, 'Output folder');
    if isequal(d, 0), return; end
    set(editH, 'String', d);
end

function loadSynthetic(fig)
    h = guidata(fig);
    root = n24light.toolbox_root();
    dataDir = fullfile(root, 'examples', 'synthetic_test_data');
    set(h.editCase, 'String', 'SYNTHETIC_TEST');
    set(h.editOut, 'String', fullfile(dataDir, 'outputs'));
    set(h.editSleep, 'String', fullfile(dataDir, 'synthetic_sleep.csv'));
    set(h.editLight, 'String', fullfile(dataDir, 'synthetic_light.csv'));
    set(h.editAcro, 'String', fullfile(dataDir, 'synthetic_acrophase.csv'));
    set(h.editTauMin, 'String', '24');
    set(h.editTauMax, 'String', '26');
    set(h.editTauStep, 'String', '0.1');
    logMsg(h, 'Loaded synthetic example paths.');
end

function onRun(fig)
    h = guidata(fig);
    set(h.listLog, 'String', {'Running...'});
    drawnow;
    try
        cfg = buildCfg(h);
        cfg = n24light.merge_config(cfg);
        logMsg(h, sprintf('Case: %s', cfg.case_id));
        out = run_n24_case(cfg);
        logMsg(h, 'Finished OK.');
        if isfinite(out.periods.tau_sleep_onset_h)
            logMsg(h, sprintf('Sleep-onset period: %.3f h', out.periods.tau_sleep_onset_h));
        end
        if isfinite(out.periods.tau_amt6s_h)
            logMsg(h, sprintf('aMT6s period: %.3f h', out.periods.tau_amt6s_h));
        end
        logMsg(h, sprintf('Best-fit model tau: %.3f h (RMSE %.3f h)', ...
            out.sweep.best_tau, out.sweep.min_rmse));
        if isfield(out.paths, 'raster_tiff') && ~isempty(out.paths.raster_tiff)
            logMsg(h, ['Raster: ' out.paths.raster_tiff]);
        end
        if isfield(out.paths, 'summary_xlsx') && ~isempty(out.paths.summary_xlsx)
            logMsg(h, ['Report: ' out.paths.summary_xlsx]);
        end
    catch ME
        logMsg(h, ['Error: ' ME.message]);
        errordlg(ME.message, 'Run failed');
    end
end

function cfg = buildCfg(h)
    cfg = struct();
    cfg.case_id = strtrim(get(h.editCase, 'String'));
    cfg.output_dir = strtrim(get(h.editOut, 'String'));
    cfg.sleep_wake_file = strtrim(get(h.editSleep, 'String'));
    cfg.light_file = strtrim(get(h.editLight, 'String'));
    cfg.acrophase_file = strtrim(get(h.editAcro, 'String'));
    cfg.tau_min = str2double(get(h.editTauMin, 'String'));
    cfg.tau_max = str2double(get(h.editTauMax, 'String'));
    cfg.tau_step = str2double(get(h.editTauStep, 'String'));
    cfg.tau_default = str2double(get(h.editTauDef, 'String'));
    cfg.clock_offset = str2double(get(h.editClock, 'String'));
    cfg.use_cleaned_light = logical(get(h.chkClean, 'Value'));
    cfg.plot_measured_light_on_raster = logical(get(h.chkPlotLight, 'Value'));
    if get(h.popTdlmo, 'Value') == 2
        cfg.tdlmo_mode = 'manual';
        cfg.tdlmo_manual = str2double(get(h.editTdlmo, 'String'));
    else
        cfg.tdlmo_mode = 'auto';
    end
    cfg.report = struct( ...
        'include_sleep_onset_period', logical(get(h.chkRepSleep, 'Value')), ...
        'include_amt6s_period', logical(get(h.chkRepAmt6, 'Value')), ...
        'include_best_fit_tau', logical(get(h.chkRepBest, 'Value')), ...
        'include_tau_default', logical(get(h.chkRepDef, 'Value')), ...
        'include_tau_sweep_table', logical(get(h.chkRepSweep, 'Value')));
    cfg.outputs = struct( ...
        'export_raster_tiff', logical(get(h.chkOutTiff, 'Value')), ...
        'export_summary_xlsx', logical(get(h.chkOutXlsx, 'Value')));
end

function logMsg(h, msg)
    v = get(h.listLog, 'String');
    if ischar(v), v = {v}; end
    v{end+1} = msg;
    set(h.listLog, 'String', v, 'Value', numel(v));
    drawnow;
end
