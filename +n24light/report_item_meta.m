function meta = report_item_meta(key)
%REPORT_ITEM_META Plain-language label and definition for Excel report rows.

    switch key
        case 'case_id'
            meta.label = 'Case ID';
            meta.definition = 'Label for this analysis run (from the app or config file).';

        case 'reference_time'
            meta.label = 'Model timeline start';
            meta.definition = 'Calendar date-time when the model clock is anchored (first light epoch in your file).';

        case 'tdlmo_hours'
            meta.label = 'Starting DLMO for model (h)';
            meta.definition = ['Initial dim-light melatonin onset used to start the circadian light model (hours on the ' ...
                '24-h clock). Usually estimated from the first sleep bout (auto) or set manually in the app.'];

        case 'sleep_light_overlap_h'
            meta.label = 'Sleep and light overlap (h)';
            meta.definition = 'Length of time (hours) where both sleep diary and light recordings exist; overlap is required for modelling.';

        case 'tau_estimated_sleep_onset_h'
            meta.label = 'Sleep-onset period estimate (h)';
            meta.definition = ['Linear fit: sleep onset time (h from first light epoch) vs night index 0,1,2,…; ' ...
                'slope is the OLS period estimate (h per bout).'];

        case 'tau_sleep_onset_median_h'
            meta.label = 'Sleep-onset median interval (h)';
            meta.definition = 'Median hours between successive sleep onsets; robust when some nights shorten toward a 24 h day.';

        case 'n_sleep_onsets'
            meta.label = 'Sleep onsets used';
            meta.definition = 'Number of sleep onsets included in the sleep-onset period estimate.';

        case 'tau_estimated_amt6s_h'
            meta.label = 'aMT6s acrophase period estimate (h)';
            meta.definition = ['Estimated circadian period from urinary acrophase datetimes: ' ...
                'drift of unwrapped clock time (h) per solar day since the first collection, plus 24 h.'];

        case 'n_acrophase'
            meta.label = 'Acrophase measurements used';
            meta.definition = 'Number of aMT6s acrophase datetimes used for the period estimate.';

        case 'tau_best_fit_model_h'
            meta.label = 'Best-fit model tau (h)';
            meta.definition = 'Circadian period in the light model that minimises phase error vs measured acrophase.';

        case 'rmse_best_fit_h'
            meta.label = 'Phase error at best-fit tau (RMSE, h)';
            meta.definition = 'Root-mean-square difference (hours) between model-predicted CBTmin and measured acrophase at best-fit tau.';

        case 'tau_best_fit_ties'
            meta.label = 'Tied best-fit tau values (h)';
            meta.definition = 'Other tau values that achieved the same lowest RMSE, if more than one.';

        case 'n_acrophase_aligned_rmse'
            meta.label = 'Acrophase points at best-fit tau';
            meta.definition = 'Number of acrophase measurements aligned to the model and included in the best-fit RMSE.';

        case 'tau_default_h'
            meta.label = 'Comparison tau (fixed, h)';
            meta.definition = 'Fixed model period used for comparison (default 24.15 h unless changed in the app).';

        case 'rmse_at_tau_default_h'
            meta.label = 'Phase error at comparison tau (RMSE, h)';
            meta.definition = 'Phase error (RMSE, hours) between model CBTmin and measured acrophase at the fixed comparison tau.';

        otherwise
            meta.label = strrep(key, '_', ' ');
            meta.definition = '';
    end
end
