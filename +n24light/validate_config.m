function validate_config(cfg)
%VALIDATE_CONFIG Fail fast with plain-language errors.

    req = {'case_id','sleep_wake_file','light_file','acrophase_file'};
    for i = 1:numel(req)
        if ~isfield(cfg, req{i}) || (ischar(cfg.(req{i})) && strlength(strtrim(cfg.(req{i}))) == 0)
            error('n24light:Config', 'Missing or empty cfg.%s', req{i});
        end
    end

    fileFields = {'sleep_wake_file', 'light_file', 'acrophase_file'};
    for i = 1:numel(fileFields)
        f = cfg.(fileFields{i});
        if ischar(f) && ~isfile(f)
            error('n24light:Config', 'File not found: %s (%s)', f, fileFields{i});
        end
    end

    if cfg.tau_step <= 0 || cfg.tau_min >= cfg.tau_max
        error('n24light:Config', 'Invalid tau sweep: min < max and step > 0 required.');
    end

    if ~ismember(cfg.tdlmo_mode, {'auto','manual'})
        error('n24light:Config', 'cfg.tdlmo_mode must be ''auto'' or ''manual''.');
    end
end
