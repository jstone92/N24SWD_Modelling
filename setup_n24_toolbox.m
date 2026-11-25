function setup_n24_toolbox()
%SETUP_N24_TOOLBOX Add this package and circadian model helpers to the path.
%   Run once per MATLAB session before run_n24_case, or rely on run_n24_case
%   which calls this automatically.

    root = fileparts(mfilename('fullpath'));
    addpath(root);
    addpath(fullfile(root, 'lib'));
    addpath(fullfile(root, 'examples'));
end
