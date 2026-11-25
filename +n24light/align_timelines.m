function aligned = align_timelines(cfg, sleep, light, acro)
%ALIGN_TIMELINES Shift sleep and acrophase to first light epoch reference.

    ref_dn = light.reference_dn;
    aligned.reference_dn = ref_dn;
    aligned.reference_dt = datetime(ref_dn, 'ConvertFrom', 'datenum');

    if strcmp(sleep.source, 'continuous_columns')
        if isempty(sleep.first_bed_dn)
            shift_h = 0;
        else
            shift_h = (sleep.first_bed_dn - ref_dn) * 24;
        end
        aligned.sleep_X = sleep.X + shift_h;
    else
        on_h = (datenum(sleep.onset_dt) - ref_dn) * 24;
        off_h = (datenum(sleep.wake_dt) - ref_dn) * 24;
        n = min(numel(on_h), numel(off_h));
        on_h = on_h(1:n);
        off_h = off_h(1:n);
        X = zeros(1, 2*n);
        X(1:2:end) = on_h;
        X(2:2:end) = off_h;
        aligned.sleep_X = X;
    end

    aligned.acrophase_cont = (datenum(acro.dt) - ref_dn) * 24;
    aligned.light_cont_h = (light.dn - ref_dn) * 24;

    aligned.overlap = n24light.alignment_report(aligned.sleep_X, aligned.light_cont_h);
end
