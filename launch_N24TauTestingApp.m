function launch_N24TauTestingApp(forceClassic)
%LAUNCH_N24TAUTESTINGAPP Open the N24 tau testing desktop UI.
%   forceClassic — optional true or 'classic' to open only the classic window.
%   Modern window: uifigure (R2016a+, R2019b+ recommended for analysis).
%   Older MATLAB / JVM off: classic figure/uicontrol UI (same fields).
%   launch_N24TauTestingApp('classic') — skip modern UI (one window only).

    setup_n24_toolbox();
    n24_close_stale_windows();
    forceOnlyClassic = (nargin >= 1) && (ischar(forceClassic) && strcmpi(forceClassic, 'classic') ...
        || islogical(forceClassic) && forceClassic);
    openedModern = false;
    if ~forceOnlyClassic && n24_modern_ui_smoke_test()
        try
            N24TauTestingApp();
            openedModern = true;
        catch ME
            n24_close_stale_windows();
            if n24_ui_failure(ME)
                fprintf('Modern UI failed (%s)\nOpening classic UI instead.\n', ME.message);
            else
                rethrow(ME);
            end
        end
    else
        n24_print_ui_unavailable_hint();
    end
    if ~openedModern
        N24TauTestingApp_classic();
    end
end

function tf = n24_modern_ui_smoke_test()
    tf = false;
    if ~usejava('jvm') || isempty(which('uilabel')) || isempty(which('uifigure'))
        return;
    end
    f = [];
    try
        f = uifigure('Visible', 'off', 'Name', '__n24_ui_test__');
        uilabel(f, 'Text', 'ok');
        delete(f);
        tf = true;
    catch
        if ~isempty(f) && isgraphics(f)
            delete(f);
        end
    end
end

function n24_close_stale_windows()
    figs = findall(0, '-property', 'Name');
    for k = 1:numel(figs)
        try
            if isgraphics(figs(k)) && strcmp(figs(k).Name, 'N24 tau testing')
                close(figs(k));
            end
        catch
        end
    end
end

function tf = n24_ui_failure(ME)
    msg = ME.message;
    names = {'uilabel', 'uifigure', 'uigridlayout', 'uieditfield', 'uitextarea', 'uialert'};
    tf = any(cellfun(@(s) contains(msg, s), names));
end

function n24_print_ui_unavailable_hint()
    fprintf(['App Designer UI (uilabel/uifigure) is not available in this session.\n' ...
        'MATLAB %s | JVM on: %d | which(uilabel): %s\n'], ...
        version, usejava('jvm'), n24_which_or_missing('uilabel'));
    if ~usejava('jvm')
        fprintf(['Java is off (common if MATLAB was started with -nojvm).\n' ...
            'Restart MATLAB from the normal desktop shortcut, then run launch_N24TauTestingApp again.\n']);
    end
end

function s = n24_which_or_missing(name)
    w = which(name);
    if isempty(w), s = '(not found)'; else, s = w; end
end
