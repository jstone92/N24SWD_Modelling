function diagnose_n24_ui()
%DIAGNOSE_N24_UI Print checks when launch_N24TauTestingApp / uilabel fails.

    fprintf('MATLAB version: %s\n', version);
    fprintf('JVM enabled (usejava(''jvm'')): %d\n', usejava('jvm'));
    fprintf('Desktop (usejava(''desktop'')): %d\n', usejava('desktop'));
    names = {'uilabel', 'uifigure', 'uigridlayout', 'uieditfield', 'uitextarea'};
    for k = 1:numel(names)
        w = which(names{k});
        if isempty(w)
            fprintf('which(%s): NOT FOUND\n', names{k});
        else
            fprintf('which(%s): %s\n', names{k}, w);
        end
    end
    root = fileparts(which('launch_N24TauTestingApp'));
    if isempty(root)
        fprintf('launch_N24TauTestingApp: NOT ON PATH (cd to toolbox folder, run setup_n24_toolbox)\n');
    else
        fprintf('Toolbox root: %s\n', root);
    end
    fprintf('\nIf JVM is 0, restart MATLAB without -nojvm, then run launch_N24TauTestingApp.\n');
    fprintf('Classic UI: N24TauTestingApp_classic  (works without uilabel)\n');
end
