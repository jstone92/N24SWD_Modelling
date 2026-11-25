function h = raster_legend_marker(ax, R)
%RASTER_LEGEND_MARKER Invisible line handle for raster legend (NaN markers).

    mk = 'o';
    mcol = [0 0 0];
    mfc = mcol;
    msz = 8;
    mlw = 1.5;
    if isfield(R, 'Marker'), mk = R.Marker; end
    if isfield(R, 'MarkerColor'), mcol = R.MarkerColor; end
    if isfield(R, 'MarkerFaceColor'), mfc = R.MarkerFaceColor; end
    if isfield(R, 'MarkerSize'), msz = R.MarkerSize; end
    if isfield(R, 'MarkerLineWidth'), mlw = R.MarkerLineWidth; end

    if ismember(mk, {'+', 'x', '.', '_', '|', 'none'})
        h = plot(ax, NaN, NaN, mk, 'Color', mcol, 'MarkerSize', msz, ...
            'LineWidth', mlw, 'HandleVisibility', 'on');
    else
        h = plot(ax, NaN, NaN, mk, 'Color', mcol, 'MarkerFaceColor', mfc, ...
            'MarkerSize', msz, 'LineWidth', mlw, 'HandleVisibility', 'on');
    end
end
