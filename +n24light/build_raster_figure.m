function hFig = build_raster_figure(cfg, aligned, acrophase_cont, cbt_default, cbt_best, sweep, light_lux, light_sw)
%BUILD_RASTER_FIGURE Sleep raster + optional measured light + acrophase + CBTmin.
%   aligned.sleep_X and aligned.light_cont_h are hours from first light epoch.

    figNum = 48;
    d = 2;
    if ~cfg.plot_double_raster
        d = 1;
    end

    sleep_X = aligned.sleep_X;
    plotLight = isfield(cfg, 'plot_measured_light_on_raster') && cfg.plot_measured_light_on_raster;

    R = struct([]);
    R(1).X = sleep_X;
    R(1).SkipBuiltInLegend = true;
    R(1).M = acrophase_cont(:).';
    R(1).Marker = 'o';
    R(1).MarkerColor = [0 0 1];
    R(1).MarkerFaceColor = [0 0 1];
    R(1).MarkerSize = 9;
    R(1).MarkerLineWidth = 1.5;

    R(2).X = [];
    R(2).M = cbt_default(:).';
    R(2).Marker = 'x';
    R(2).MarkerColor = [0.45 0.45 0.45];
    R(2).MarkerFaceColor = [0.45 0.45 0.45];
    R(2).MarkerSize = 9;
    R(2).MarkerLineWidth = 1.8;

    R(3).X = [];
    R(3).M = cbt_best(:).';
    R(3).Marker = 'd';
    R(3).MarkerColor = [0 0 0];
    R(3).MarkerFaceColor = [0 0 0];
    R(3).MarkerSize = 8;
    R(3).MarkerLineWidth = 1.8;

    if plotLight
        t_h = aligned.light_cont_h(:);
        lux = light_lux(:);
        if nargin >= 8 && ~isempty(light_sw)
            wake = light_sw(:) >= 0.5;
            if any(wake)
                t_h = t_h(wake);
                lux = lux(wake);
            end
        end
        R(1).LightBlocks = n24light.light_lux_to_blocks(t_h, lux);
    end

    titleStr = cfg.raster_title;
    if strlength(titleStr) == 0
        if plotLight
            titleStr = 'Sleep, measured light, aMT6s acrophase, and model CBT_{min}';
        else
            titleStr = 'Sleep, measured acrophase, and model CBT_{min}';
        end
    end

    hFig = raster_deluxe_cursor(R, figNum, titleStr, d);
    figure(hFig);
    ax = gca;
    hold(ax, 'on');
    legend(ax, 'off');

    rmse_txt = sprintf('%.3f', sweep.min_rmse);
    if isnan(sweep.min_rmse)
        rmse_txt = 'NA';
    end
    tauBest = sweep.best_tau;
    if isempty(tauBest)
        tauBest = NaN;
    else
        tauBest = tauBest(1);
    end

    C_sleep = [0.15, 0.15, 0.15];
    hLeg = gobjects(0);
    labs = {};

    hLeg(end+1, 1) = patch(ax, NaN, NaN, C_sleep, 'EdgeColor', 'none', 'HandleVisibility', 'on');
    labs{end+1, 1} = 'Sleep';

    if plotLight
        C_light_leg = [1.0, 0.7, 0.25; 1.0, 0.92, 0.55];
        hLeg(end+1, 1) = patch(ax, NaN, NaN, C_light_leg(1,:), 'EdgeColor', 'none', 'HandleVisibility', 'on');
        labs{end+1, 1} = 'Measured light 0-100 lux';
        hLeg(end+1, 1) = patch(ax, NaN, NaN, C_light_leg(2,:), 'EdgeColor', 'none', 'HandleVisibility', 'on');
        labs{end+1, 1} = 'Measured light >100 lux';
    end

    if isfield(R(1), 'M') && ~isempty(R(1).M) && any(isfinite(R(1).M(:)))
        hLeg(end+1, 1) = n24light.raster_legend_marker(ax, R(1));
        labs{end+1, 1} = 'Measured aMT6s acrophase';
    end

    if numel(R) >= 2 && isfield(R(2), 'M') && ~isempty(R(2).M) && any(isfinite(R(2).M(:)))
        hLeg(end+1, 1) = n24light.raster_legend_marker(ax, R(2));
        labs{end+1, 1} = sprintf('CBTmin default (tau=%.2f h)', cfg.tau_default(1));
    end

    if numel(R) >= 3 && isfield(R(3), 'M') && ~isempty(R(3).M) && any(isfinite(R(3).M(:)))
        hLeg(end+1, 1) = n24light.raster_legend_marker(ax, R(3));
        labs{end+1, 1} = sprintf('CBTmin best fit (tau=%.2f h, RMSE=%s h)', tauBest, rmse_txt);
    end

    if isempty(hLeg)
        return
    end
    legend(ax, hLeg, labs, 'Location', 'eastoutside', 'Interpreter', 'none');
    hold(ax, 'off');
end
