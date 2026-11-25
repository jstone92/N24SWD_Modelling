function periods = estimate_observed_periods(sleep_X, acrophase_cont, acrophase_dt)
%ESTIMATE_OBSERVED_PERIODS Linear drift periods from sleep onset and acrophase.
%   Sleep: slope of onset (h from reference) vs night index 0,1,2,... (tau in h/night).
%   aMT6s: circadian period from urinary acrophase datetimes — linear drift of
%          unwrapped clock hour vs calendar days since first sample; tau ≈ 24 + slope.

    periods = struct();
    periods.tau_sleep_onset_h = NaN;
    periods.tau_sleep_onset_median_h = NaN;
    periods.tau_amt6s_h = NaN;
    periods.n_sleep_onsets = 0;
    periods.n_acrophase = 0;
    periods.sleep_fit = [];
    periods.amt6s_fit = [];

    if nargin >= 1 && ~isempty(sleep_X)
        onsets = sleep_X(1:2:end);
        onsets = onsets(isfinite(onsets));
        n = numel(onsets);
        periods.n_sleep_onsets = n;
        if n >= 2
            day = (0:n-1)';
            mdl = fitlm(day, onsets(:));
            periods.tau_sleep_onset_h = mdl.Coefficients.Estimate(2);
            periods.tau_sleep_onset_median_h = median(diff(sort(onsets)));
            periods.sleep_fit = mdl;
        end
    end

    if nargin >= 2 && ~isempty(acrophase_cont)
        y = acrophase_cont(:);
        y = y(isfinite(y));
        n = numel(y);
        periods.n_acrophase = n;
        if n >= 2 && nargin >= 3 && ~isempty(acrophase_dt)
            dt = acrophase_dt(:);
            if ~isdatetime(dt)
                dt = datetime(dt);
            end
            ok = isfinite(y) & ~isnat(dt);
            y = y(ok);
            dt = dt(ok);
            n = numel(y);
            if n >= 2
                tDays = double(days(dt - dt(1)));
                phase_h = n24light.unwrap_acrophase_clock(dt);
                if n >= 3
                    mdl = fitlm(tDays, phase_h);
                    drift_per_day = mdl.Coefficients.Estimate(2);
                    periods.amt6s_fit = mdl;
                else
                    drift_per_day = (phase_h(2) - phase_h(1)) / tDays(2);
                    periods.amt6s_fit = [];
                end
                periods.tau_amt6s_h = 24 + drift_per_day;
            end
        elseif n >= 2
            % Fallback: successive intervals (no datetimes) — mean hours between collections
            dY = diff(sort(y));
            periods.tau_amt6s_h = mean(dY);
        end
    end
end
