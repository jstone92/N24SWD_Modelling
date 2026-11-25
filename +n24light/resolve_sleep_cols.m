function c = resolve_sleep_cols(T, cols)
%RESOLVE_SLEEP_COLS Map cfg.cols sleep fields to variables present in table T.

    c = cols;
    vn = T.Properties.VariableNames;

    onCont = n24light.match_varname(vn, {c.sleep_on_cont, 'SleepOn_Continuous', ...
        'SleepOnset_Continuous', 'SleepOn_Cont'});
    offCont = n24light.match_varname(vn, {c.wake_up_cont, 'WakeUp_Continuous', ...
        'WakeUp_Cont', 'Wakeup_Continuous'});
    if ~isempty(onCont) && ~isempty(offCont)
        c.sleep_on_cont = onCont;
        c.wake_up_cont = offCont;
        return
    end

    onDt = n24light.match_varname(vn, {c.sleep_onset_dt, 'SleepOnset_DT', 'SleepOnset', ...
        'Sleep_Onset_DT', 'Onset_DT', 'OnsetDateTime', 'Sleep onset'});
    offDt = n24light.match_varname(vn, {c.wakeup_dt, 'WakeUp_DT', 'WakeUp', ...
        'Wake_Up_DT', 'Wakeup_DT', 'Offset_DT', 'WakeUpDateTime', 'Wake up'});

    if ~isempty(onDt) && ~isempty(offDt)
        c.sleep_onset_dt = onDt;
        c.wakeup_dt = offDt;
        bed = n24light.match_varname(vn, {c.bed_date, 'BedTimeDate', 'BedDate', 'Bed_Date'});
        if ~isempty(bed)
            c.bed_date = bed;
        end
        return
    end

    error('n24light:Sleep', ...
        ['Sleep file must include sleep onset and wake times (e.g. SleepOnset_DT and WakeUp_DT, ' ...
        'or SleepOn_Continuous and WakeUp_Continuous). Found columns: %s.'], ...
        strjoin(vn, ', '));
end
