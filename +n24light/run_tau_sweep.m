function result = run_tau_sweep(cfg, light_dn, light_lux, light_sw, acrophase_dt, reference_dn, tDLMO)
%RUN_TAU_SWEEP Loop circadian model over tau grid; score vs acrophase.

    taus = cfg.tau_min:cfg.tau_step:cfg.tau_max;
    if isempty(taus)
        error('n24light:Sweep', 'Empty tau grid.');
    end

    nT = numel(taus);
    est = table(taus(:), nan(nT,1), nan(nT,1), nan(nT,1), nan(nT,1), ...
        'VariableNames', {'model_tau','cbtmin_mae','cbtmin_rmse','cbtmin_n','period_h'});

    cbt_store = cell(nT, 1);
    tdlmo_store = cell(nT, 1);

    looping = 0;
    looped_V0 = [];
    set_p = [];

    [light_dn_mod, light_mod, SW_mod] = prepareLightInput( ...
        light_dn, light_lux, light_sw, cfg.maxgap, cfg.gapfill);

    for i = 1:nT
        tau = taus(i);
        [~, ~, t_dlmo, ~, period_h] = circ_model( ...
            light_dn_mod, light_mod, SW_mod, tDLMO, looping, looped_V0, set_p, tau);

        ph = n24light.cbt_cont_from_model(t_dlmo);
        cbt_store{i} = ph.cbt_cont;
        tdlmo_store{i} = t_dlmo;

        sc = n24light.score_acrophase_rmse(cfg, acrophase_dt, ph.cbt_cont, t_dlmo, reference_dn);
        est.cbtmin_mae(i) = sc.mae;
        est.cbtmin_rmse(i) = sc.rmse;
        est.cbtmin_n(i) = sc.n;
        est.period_h(i) = period_h;
    end

    result.tau_table = est;
    result.cbt_by_tau = cbt_store;
    result.t_dlmo_by_tau = tdlmo_store;
    result.taus = taus;

    [min_rmse, idx_all] = min(est.cbtmin_rmse, [], 'omitnan');
    result.min_rmse = min_rmse;
    result.best_idx = idx_all;
    result.best_tau = est.model_tau(idx_all);
    result.best_ties = est.model_tau(abs(est.cbtmin_rmse - min_rmse) < 1e-9 & isfinite(est.cbtmin_rmse));
end
