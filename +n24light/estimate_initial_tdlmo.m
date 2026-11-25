function tDLMO = estimate_initial_tdlmo(cfg, sleep_X)
%ESTIMATE_INITIAL_TDLMO Auto initial DLMO from first sleep bout or manual override.

    if strcmpi(cfg.tdlmo_mode, 'manual')
        tDLMO = cfg.tdlmo_manual;
        return
    end

    if isempty(sleep_X)
        error('n24light:Model', 'Cannot estimate tDLMO: empty sleep switch vector.');
    end
    t_on = sleep_X(1);
    clock_h = mod(t_on, 24);
    % Heuristic: DLMO typically precedes habitual sleep onset (see README.md).
    tDLMO = mod(clock_h - 2.5, 24);
end
