function light = load_light_epochs(cfg)
%LOAD_LIGHT_EPOCHS Load epoch light (datetime, lux, optional SW).

    T = n24light.read_table_cfg(cfg, cfg.light_file);
    c = cfg.cols;

    dt = n24light.resolve_light_datetime(T, c);

    if ~ismember(c.light_lux, T.Properties.VariableNames)
        error('n24light:Light', 'Missing lux column: %s', c.light_lux);
    end
    lux = T.(c.light_lux)(:);

    sw = [];
    if ismember(c.light_sw, T.Properties.VariableNames)
        sw = T.(c.light_sw)(:);
        if any(strcmpi(T.Properties.VariableNames{strcmp(T.Properties.VariableNames, c.light_sw)}, 'IntervalStatus'))
            % Geneactiv-style: optional remap elsewhere
        end
        if max(sw) > 1.5
            sw = double(sw > 0.5);
        end
    end

    light.dt = dt;
    light.lux = lux;
    light.sw = sw;
    light.dn = datenum(dt);
    light.reference_dn = light.dn(find(isfinite(light.dn), 1, 'first'));
end
