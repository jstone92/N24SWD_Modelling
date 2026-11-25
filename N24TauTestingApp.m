classdef N24TauTestingApp < handle
    %N24TAUTESTINGAPP Desktop UI for N24 light-behaviour tau testing.
    %   Launch via launch_N24TauTestingApp.m
    %   Layout can be reopened in App Designer (export) if you migrate to .mlapp later.

    properties (Access = private)
        UIFigure
        EditCaseID
        EditOutputDir
        EditSleepFile
        EditLightFile
        EditAcroFile
        EditTauMin
        EditTauMax
        EditTauStep
        EditTauDefault
        EditClockOffset
        DropTdlmoMode
        EditTdlmoManual
        CheckCleanLight
        CheckPlotLightOnRaster
        CheckReportSleep
        CheckReportAmt6s
        CheckReportBestTau
        CheckReportTauDefault
        CheckReportSweep
        CheckOutTiff
        CheckOutXlsx
        ButtonRun
        TextLog
    end

    methods
        function app = N24TauTestingApp()
            try
                app.buildUI();
            catch ME
                if ~isempty(app.UIFigure) && isgraphics(app.UIFigure)
                    delete(app.UIFigure);
                    app.UIFigure = [];
                end
                rethrow(ME);
            end
        end

        function buildUI(app)
            app.UIFigure = uifigure('Name', 'N24 tau testing', ...
                'Position', [100 60 720 780]);
            g = uigridlayout(app.UIFigure, [16 3]);
            g.RowHeight = {26, 26, 26, 26, 26, 22, 26, 26, 26, 26, 26, 26, 22, 62, 48, '1x'};
            g.ColumnWidth = {150, '1x', 90};
            g.Padding = [12 12 12 12];
            g.RowSpacing = 6;
            g.ColumnSpacing = 8;

            uilabel(g, 'Text', 'N24 light / tau testing', 'FontWeight', 'bold', ...
                'HorizontalAlignment', 'left');
            g.mergecells(1, [1 3]);

            uilabel(g, 'Text', 'Case ID');
            app.EditCaseID = uieditfield(g, 'text', 'Value', 'CASE001');
            uibutton(g, 'Text', '—', 'Enable', 'off');

            uilabel(g, 'Text', 'Output folder');
            app.EditOutputDir = uieditfield(g, 'text', 'Value', '');
            uibutton(g, 'Text', 'Browse…', 'ButtonPushedFcn', @(~,~) app.browseFolder());

            lblSleep = uilabel(g, 'Text', 'Sleep–wake file');
            lblSleep.Layout.Row = 4;
            app.EditSleepFile = uieditfield(g, 'text');
            app.EditSleepFile.Layout.Row = 4; app.EditSleepFile.Layout.Column = 2;
            btnS = uibutton(g, 'Text', 'Browse…', 'ButtonPushedFcn', @(~,~) app.browseFile(app.EditSleepFile));
            btnS.Layout.Row = 4; btnS.Layout.Column = 3;

            lblL = uilabel(g, 'Text', 'Light epochs file');
            lblL.Layout.Row = 5;
            app.EditLightFile = uieditfield(g, 'text');
            app.EditLightFile.Layout.Row = 5; app.EditLightFile.Layout.Column = 2;
            btnL = uibutton(g, 'Text', 'Browse…', 'ButtonPushedFcn', @(~,~) app.browseFile(app.EditLightFile));
            btnL.Layout.Row = 5; btnL.Layout.Column = 3;

            lblA = uilabel(g, 'Text', 'aMT6s acrophase file');
            lblA.Layout.Row = 6;
            app.EditAcroFile = uieditfield(g, 'text');
            app.EditAcroFile.Layout.Row = 6; app.EditAcroFile.Layout.Column = 2;
            btnA = uibutton(g, 'Text', 'Browse…', 'ButtonPushedFcn', @(~,~) app.browseFile(app.EditAcroFile));
            btnA.Layout.Row = 6; btnA.Layout.Column = 3;

            hdrM = uilabel(g, 'Text', 'Model & search', 'FontWeight', 'bold');
            hdrM.Layout.Row = 7;
            g.mergecells(7, [1 3]);

            lblTau = uilabel(g, 'Text', 'τ min / max / step (h)');
            lblTau.Layout.Row = 8;
            rowTau = uigridlayout(g, [1 3]);
            rowTau.Layout.Row = 8;
            rowTau.Layout.Column = [2 3];
            rowTau.ColumnWidth = {'1x', '1x', '1x'};
            rowTau.Padding = [0 0 0 0];
            app.EditTauMin = uieditfield(rowTau, 'numeric', 'Value', 24.0, 'Limits', [20 30]);
            app.EditTauMax = uieditfield(rowTau, 'numeric', 'Value', 25.5, 'Limits', [20 30]);
            app.EditTauStep = uieditfield(rowTau, 'numeric', 'Value', 0.05, 'Limits', [0.001 1]);
            uilabel(g, 'Text', '').Layout.Row = 8;

            lblD = uilabel(g, 'Text', 'Default τ / raster clock start (h)');
            lblD.Layout.Row = 9;
            row2 = uigridlayout(g, [1 2]);
            row2.Layout.Row = 9;
            row2.Layout.Column = [2 3];
            row2.ColumnWidth = {'1x', '1x'};
            row2.Padding = [0 0 0 0];
            app.EditTauDefault = uieditfield(row2, 'numeric', 'Value', 24.15);
            app.EditClockOffset = uieditfield(row2, 'numeric', 'Value', 6);
            uilabel(g, 'Text', '').Layout.Row = 9;

            lblDl = uilabel(g, 'Text', 'Initial tDLMO (h)');
            lblDl.Layout.Row = 10;
            row3 = uigridlayout(g, [1 2]);
            row3.Layout.Row = 10;
            row3.Layout.Column = [2 3];
            row3.ColumnWidth = {160, '1x'};
            row3.Padding = [0 0 0 0];
            app.DropTdlmoMode = uidropdown(row3, ...
                'Items', {'Auto (first sleep bout)', 'Manual'}, ...
                'Value', 'Auto (first sleep bout)', ...
                'ValueChangedFcn', @(dd,~) app.onTdlmoModeChanged());
            app.EditTdlmoManual = uieditfield(row3, 'numeric', 'Value', 11, 'Enable', 'off');
            uilabel(g, 'Text', '').Layout.Row = 10;

            app.CheckCleanLight = uicheckbox(g, 'Text', 'Optional light cleaning (getCleanLit)', ...
                'Value', false);
            app.CheckCleanLight.Layout.Row = 11;
            app.CheckCleanLight.Layout.Column = [1 3];

            app.CheckPlotLightOnRaster = uicheckbox(g, ...
                'Text', 'Show measured light on raster (lux bands; wake epochs)', ...
                'Value', true);
            app.CheckPlotLightOnRaster.Layout.Row = 12;
            app.CheckPlotLightOnRaster.Layout.Column = [1 3];

            hdrR = uilabel(g, 'Text', 'Report (XLSX sheet "report")', 'FontWeight', 'bold');
            hdrR.Layout.Row = 13;
            g.mergecells(13, [1 3]);
            reportGrid = uigridlayout(g, [2 3]);
            reportGrid.Layout.Row = 14;
            reportGrid.Layout.Column = [1 3];
            reportGrid.ColumnWidth = {'1x', '1x', '1x'};
            reportGrid.Padding = [0 0 0 0];
            app.CheckReportSleep = uicheckbox(reportGrid, ...
                'Text', 'Sleep-onset period (h)', 'Value', true);
            app.CheckReportAmt6s = uicheckbox(reportGrid, ...
                'Text', 'aMT6s period (h)', 'Value', true);
            app.CheckReportBestTau = uicheckbox(reportGrid, ...
                'Text', 'Best-fit model τ + RMSE', 'Value', true);
            app.CheckReportTauDefault = uicheckbox(reportGrid, ...
                'Text', 'Default τ (24.15) RMSE', 'Value', true);
            app.CheckReportSweep = uicheckbox(reportGrid, ...
                'Text', 'Full τ sweep table', 'Value', true);
            uilabel(reportGrid, 'Text', '');
            uilabel(reportGrid, 'Text', '');

            outGrid = uigridlayout(g, [1 3]);
            outGrid.Layout.Row = 15;
            outGrid.Layout.Column = [1 3];
            outGrid.ColumnWidth = {'1x', '1x', '1x'};
            app.CheckOutTiff = uicheckbox(outGrid, 'Text', 'Export raster TIFF', 'Value', true);
            app.CheckOutXlsx = uicheckbox(outGrid, 'Text', 'Export summary XLSX', 'Value', true);
            app.ButtonRun = uibutton(outGrid, 'Text', 'Run analysis', ...
                'FontWeight', 'bold', 'BackgroundColor', [0.2 0.55 0.35], ...
                'FontColor', [1 1 1], 'ButtonPushedFcn', @(~,~) app.onRun());

            app.TextLog = uitextarea(g, 'Editable', 'off', 'FontName', 'Consolas', ...
                'Value', {'Ready. Set files and options, then Run analysis.'});
            app.TextLog.Layout.Row = 16;
            app.TextLog.Layout.Column = [1 3];
        end

        function onTdlmoModeChanged(app)
            if strcmp(app.DropTdlmoMode.Value, 'Manual')
                app.EditTdlmoManual.Enable = 'on';
            else
                app.EditTdlmoManual.Enable = 'off';
            end
        end

        function browseFile(app, editField)
            [f, p] = uigetfile({'*.xlsx;*.xls;*.csv', 'Tables (*.xlsx, *.csv)'}, 'Select file');
            if isequal(f, 0), return; end
            editField.Value = fullfile(p, f);
        end

        function browseFolder(app)
            d = uigetdir(pwd, 'Output folder');
            if isequal(d, 0), return; end
            app.EditOutputDir.Value = d;
        end

        function cfg = buildCfg(app)
            cfg = struct();
            cfg.case_id = strtrim(app.EditCaseID.Value);
            cfg.output_dir = strtrim(app.EditOutputDir.Value);
            cfg.sleep_wake_file = strtrim(app.EditSleepFile.Value);
            cfg.light_file = strtrim(app.EditLightFile.Value);
            cfg.acrophase_file = strtrim(app.EditAcroFile.Value);
            cfg.tau_min = app.EditTauMin.Value;
            cfg.tau_max = app.EditTauMax.Value;
            cfg.tau_step = app.EditTauStep.Value;
            cfg.tau_default = app.EditTauDefault.Value;
            cfg.clock_offset = app.EditClockOffset.Value;
            cfg.use_cleaned_light = app.CheckCleanLight.Value;
            cfg.plot_measured_light_on_raster = app.CheckPlotLightOnRaster.Value;
            if strcmp(app.DropTdlmoMode.Value, 'Manual')
                cfg.tdlmo_mode = 'manual';
                cfg.tdlmo_manual = app.EditTdlmoManual.Value;
            else
                cfg.tdlmo_mode = 'auto';
            end
            cfg.report = struct( ...
                'include_sleep_onset_period', app.CheckReportSleep.Value, ...
                'include_amt6s_period', app.CheckReportAmt6s.Value, ...
                'include_best_fit_tau', app.CheckReportBestTau.Value, ...
                'include_tau_default', app.CheckReportTauDefault.Value, ...
                'include_tau_sweep_table', app.CheckReportSweep.Value);
            cfg.outputs = struct( ...
                'export_raster_tiff', app.CheckOutTiff.Value, ...
                'export_summary_xlsx', app.CheckOutXlsx.Value);
        end

        function log(app, msg)
            v = app.TextLog.Value;
            if ischar(v), v = {v}; end
            v{end+1} = msg;
            app.TextLog.Value = v;
            drawnow;
        end

        function onRun(app)
            app.TextLog.Value = {'Running…'};
            try
                cfg = n24light.merge_config(app.buildCfg());
                app.log(sprintf('Case: %s', cfg.case_id));
                out = run_n24_case(cfg);
                app.log('Finished OK.');
                if isfinite(out.periods.tau_sleep_onset_h)
                    app.log(sprintf('Sleep-onset period: %.3f h', out.periods.tau_sleep_onset_h));
                end
                if isfinite(out.periods.tau_amt6s_h)
                    app.log(sprintf('aMT6s period: %.3f h', out.periods.tau_amt6s_h));
                end
                app.log(sprintf('Best-fit model τ: %.3f h (RMSE %.3f h)', ...
                    out.sweep.best_tau, out.sweep.min_rmse));
                if isfield(out.paths, 'raster_tiff') && ~isempty(out.paths.raster_tiff)
                    app.log(['Raster: ' out.paths.raster_tiff]);
                end
                if isfield(out.paths, 'summary_xlsx') && ~isempty(out.paths.summary_xlsx)
                    app.log(['Report: ' out.paths.summary_xlsx]);
                end
            catch ME
                app.log(['Error: ' ME.message]);
                uialert(app.UIFigure, ME.message, 'Run failed', 'Icon', 'error');
            end
        end
    end
end
