function sleep = load_sleep_wake(cfg)
%LOAD_SLEEP_WAKE Build sleep switch vector X from diary table.
%   Returns continuous hours (not yet shifted to light reference).

    T = n24light.read_table_cfg(cfg, cfg.sleep_wake_file);
    c = n24light.resolve_sleep_cols(T, cfg.cols);

    if all(ismember({c.sleep_on_cont, c.wake_up_cont}, T.Properties.VariableNames))
        on = T.(c.sleep_on_cont)(:);
        off = T.(c.wake_up_cont)(:);
        if numel(on) ~= numel(off)
            error('n24light:Sleep', 'Sleep onset/wake columns must have equal length.');
        end
        X = zeros(1, numel(on) + numel(off));
        X(1:2:end) = on;
        X(2:2:end) = off;
        sleep.X = X;
        sleep.source = 'continuous_columns';
        sleep.first_bed_dn = [];
        if ismember(c.bed_date, T.Properties.VariableNames)
            bd = T.(c.bed_date)(1);
            if isdatetime(bd)
                sleep.first_bed_dn = datenum(bd);
            else
                sleep.first_bed_dn = bd;
            end
        end
        sleep.onset_dt = [];
        sleep.wake_dt = [];
        return
    end

    on = T.(c.sleep_onset_dt)(:);
    off = T.(c.wakeup_dt)(:);
    if ~isdatetime(on), on = datetime(on); end
    if ~isdatetime(off), off = datetime(off); end

    X = zeros(1, numel(on) + numel(off));
    ref0 = datenum(on(1));
    X(1:2:end) = (datenum(on) - ref0) * 24;
    X(2:2:end) = (datenum(off) - ref0) * 24;

    sleep.X = X;
    sleep.source = 'datetime_columns';
    sleep.first_bed_dn = ref0;
    sleep.onset_dt = on;
    sleep.wake_dt = off;
end
