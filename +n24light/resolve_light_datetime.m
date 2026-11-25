function dt = resolve_light_datetime(T, cols)
%RESOLVE_LIGHT_DATETIME Datetime vector from light epoch table.
%   Uses cfg.cols names, else Date+Time pair, else common column names / dtypes.

    vn = T.Properties.VariableNames;

    if ~isempty(cols.light_datetime) && ismember(cols.light_datetime, vn)
        dt = T.(cols.light_datetime)(:);
    elseif all(ismember({cols.light_date, cols.light_time}, vn))
        dt = T.(cols.light_date) + T.(cols.light_time);
    else
        dt = local_auto_datetime(T);
    end

    if ~isdatetime(dt)
        dt = datetime(dt);
    end
    if isempty(dt) || all(isnat(dt))
        error('n24light:Light', ...
            'Light file needs a datetime column (e.g. DateTime) or Date+Time pair.');
    end
end

function dt = local_auto_datetime(T)
    vn = T.Properties.VariableNames;
    prefer = {'DateTime', 'datetime', 'Date_Time', 'EpochDateTime', 'dt'};
    for i = 1:numel(prefer)
        if ismember(prefer{i}, vn)
            dt = T.(prefer{i})(:);
            return
        end
    end
    dtIdx = false(size(vn));
    for i = 1:numel(vn)
        dtIdx(i) = isdatetime(T.(vn{i}));
    end
    if sum(dtIdx) == 1
        dt = T.(vn{find(dtIdx, 1)})(:);
        return
    end
    if sum(dtIdx) > 1
        error('n24light:Light', ...
            'Multiple datetime columns in light file; set cfg.cols.light_datetime in config.');
    end
    error('n24light:Light', ...
        'Light file needs datetime column or Date+Time pair (e.g. DateTime, or Date + Time).');
end
