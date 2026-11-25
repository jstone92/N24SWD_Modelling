function root = toolbox_root()
%TOOLBOX_ROOT Absolute path to the N24 light behaviour testing package.

    root = fileparts(which('run_n24_case'));
    if isempty(root)
        root = fileparts(which('launch_N24TauTestingApp'));
    end
    if isempty(root)
        root = fileparts(mfilename('fullpath'));
        root = fileparts(root);
    end
end
