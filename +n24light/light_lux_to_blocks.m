function BL = light_lux_to_blocks(t_h, lux)
%LIGHT_LUX_TO_BLOCKS Raster segments [t_start, t_end, band] from epoch lux.
%   band 1 = 0–100 lux, band 2 = >100 lux (matches raster_deluxe_cursor colours).

    t_h = t_h(:);
    lux = lux(:);
    ok = isfinite(t_h) & isfinite(lux);
    t_h = t_h(ok);
    lux = lux(ok);
    if isempty(t_h)
        BL = zeros(0, 3);
        return
    end

    [t_h, ord] = sort(t_h);
    lux = lux(ord);

    if numel(t_h) > 1
        dt = median(diff(t_h), 'omitnan');
        if ~isfinite(dt) || dt <= 0
            dt = 0.25;
        end
    else
        dt = 0.25;
    end
    t_end_pad = dt / 2;

    band = ones(size(lux));
    band(lux > 100) = 2;

    blocks = zeros(0, 3);
    k = 1;
    while k <= numel(t_h)
        b = band(k);
        t0 = t_h(k);
        while k < numel(t_h) && band(k + 1) == b && (t_h(k + 1) - t_h(k)) <= 1.5 * dt + 1e-6
            k = k + 1;
        end
        t1 = t_h(k) + t_end_pad;
        blocks(end+1, :) = [t0, t1, b]; %#ok<AGROW>
        k = k + 1;
    end
    BL = blocks;
end
