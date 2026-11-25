function cfg = apply_ui_template_cols(cfg)
%APPLY_UI_TEMPLATE_COLS Ensure standard column names when cfg.cols was not set (UI runs).

    if ~isfield(cfg, 'cols') || isempty(cfg.cols)
        cfg.cols = n24light.defaults().cols;
        return
    end
    def = n24light.defaults().cols;
    fn = fieldnames(def);
    for i = 1:numel(fn)
        key = fn{i};
        if ~isfield(cfg.cols, key) || (ischar(cfg.cols.(key)) && strlength(strtrim(cfg.cols.(key))) == 0)
            cfg.cols.(key) = def.(key);
        end
    end
end
