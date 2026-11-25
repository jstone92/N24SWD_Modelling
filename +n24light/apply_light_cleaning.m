function lightOut = apply_light_cleaning(cfg, light, sleep_SW_dt)
%APPLY_LIGHT_CLEANING Optional getCleanLit wrapper.

    lightOut = light;
    if ~cfg.use_cleaned_light
        return
    end

    if isempty(light.sw)
        warning('n24light:Clean', 'No sleep-wake on light file; skipping cleaning.');
        return
    end

    cl = cfg.cleaning;
    plotname = cl.plotname;
    if strlength(plotname) == 0
        plotname = cfg.case_id;
    end
    lab_binary = zeros(size(light.lux));

    if nargin < 3 || isempty(sleep_SW_dt)
        sw_dt = light.dt;
        sw = light.sw;
    else
        sw_dt = sleep_SW_dt;
        sw = light.sw; %#ok<NASGU>
    end

    clean = getCleanLit(light.lux, light.dt, light.sw, sw_dt, lab_binary, ...
        cl.rulethree, cl.sleepadjust, cl.sleepclean, cl.plotting, plotname, cl.save_on);

    if isstruct(clean) && isfield(clean, 'cleaned_light')
        lightOut.lux = clean.cleaned_light(:);
    end
end
