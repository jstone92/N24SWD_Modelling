function score = score_acrophase_rmse(cfg, acrophase_dt, cbt_cont, t_dlmo, reference_dn)
%SCORE_ACROPHASE_RMSE Compare model CBTmin to measured acrophase datetimes.
%   Alignment: match each acrophase calendar day to nearest model DLMO day.
%   Error: circular difference in clock hours with cfg.clock_offset.

    offset = cfg.clock_offset;
    model_start_dn = t_dlmo(1);
    model_day_dn = floor(t_dlmo(:));
    n = numel(acrophase_dt);
    errs = nan(n, 1);
    aligned_k = nan(n, 1);

    for i = 1:n
        acro_dn = datenum(acrophase_dt(i));
        [~, k] = min(abs(model_day_dn - floor(acro_dn)));
        if k < 1 || k > numel(cbt_cont)
            continue
        end
        aligned_k(i) = k;

        obs_cont = (acro_dn - reference_dn) * 24;
        obs_clock = mod(obs_cont - offset, 24) + offset;
        cbt_clock = mod(cbt_cont(k) - offset, 24) + offset;
        diff_hr = cbt_clock - obs_clock;
        errs(i) = min(abs(diff_hr), 24 - abs(diff_hr));
    end

    ok = isfinite(errs);
    score.errs = errs(ok);
    score.aligned_k = aligned_k(ok);
    score.n = numel(score.errs);
    if score.n > 0
        score.mae = mean(score.errs);
        score.rmse = sqrt(mean(score.errs.^2));
    else
        score.mae = NaN;
        score.rmse = NaN;
    end
    score.day_offset_diary_model = round(reference_dn - model_start_dn);
end
