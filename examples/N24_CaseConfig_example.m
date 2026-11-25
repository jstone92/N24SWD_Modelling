%% Example configuration (paths are placeholders — replace with your files).
% This script does not run automatically. After editing paths:
%   setup_n24_toolbox;
%   run_n24_case(cfg);

cfg = struct();
cfg.case_id = 'EXAMPLE_001';
cfg.sleep_wake_file = 'C:\path\to\sleep_diary.xlsx';
cfg.light_file      = 'C:\path\to\light_epochs.xlsx';
cfg.acrophase_file  = 'C:\path\to\acrophase_datetimes.xlsx';

cfg.cols.acrophase_dt = 'AcrophaseDateTime';
cfg.cols.light_lux    = 'Lux';
cfg.cols.light_datetime = 'DateTime';
cfg.cols.light_sw     = 'Wake';

cfg.tau_min  = 24.0;
cfg.tau_max  = 25.5;
cfg.tau_step = 0.05;
cfg.clock_offset = 6;
cfg.tdlmo_mode = 'auto';
cfg.use_cleaned_light = false;

% run_n24_case(cfg);
