%% N24 case configuration — copy this file and edit paths only.
% Example:
%   cfg = merge_from_template();  % optional helper
%   run_n24_case(cfg);
%
% Or: edit below and run this script (F5).

cfg = struct();

%% Case identity
cfg.case_id = 'CASE001';
cfg.output_dir = '';  % leave empty -> outputs/CASE001 under package folder

%% Input files (use absolute paths or paths relative to MATLAB current folder)
cfg.sleep_wake_file = 'path\to\sleep_diary.xlsx';
cfg.light_file      = 'path\to\light_epochs.xlsx';
cfg.acrophase_file  = 'path\to\amt6s_acrophase.xlsx';

%% Column names (change if your headers differ)
cfg.cols.sleep_on_cont  = 'SleepOn_Continuous';
cfg.cols.wake_up_cont   = 'WakeUp_Continuous';
cfg.cols.sleep_onset_dt = 'SleepOnset_DT';
cfg.cols.wakeup_dt      = 'WakeUp_DT';
cfg.cols.bed_date       = 'BedTimeDate';
cfg.cols.light_datetime = '';       % set e.g. 'dt' if single datetime column
cfg.cols.light_date     = 'Date';
cfg.cols.light_time     = 'Time';
cfg.cols.light_lux      = 'WhiteLight';
cfg.cols.light_sw       = 'Sleep_Wake';  % 1=wake, 0=sleep; optional
cfg.cols.acrophase_dt   = 'AcrophaseDateTime';

%% Clock hour start of raster / RMSE (h; default 6 gives 6–30 h style windows)
cfg.clock_offset = 6;

%% Tau search
cfg.tau_default = 24.15;
cfg.tau_min     = 24.0;
cfg.tau_max     = 25.5;
cfg.tau_step    = 0.05;

%% Model light preparation
cfg.maxgap  = 6;
cfg.gapfill = 2;

%% Optional light cleaning (getCleanLit)
cfg.use_cleaned_light = false;

%% Initial DLMO phase (hours)
cfg.tdlmo_mode   = 'auto';   % 'auto' from first sleep bout | 'manual'
cfg.tdlmo_manual = 11;       % used when tdlmo_mode = 'manual'

%% Plot / export
cfg.plot_double_raster = true;
cfg.plot_measured_light_on_raster = false; % true: orange/yellow lux bands on raster TIFF
cfg.export_dpi         = 500;
cfg.raster_title       = '';   % generic title when empty
cfg.outputs.export_raster_tiff  = true;
cfg.outputs.export_summary_xlsx = true;

%% Report rows (XLSX sheet "report")
cfg.report.include_sleep_onset_period = true;
cfg.report.include_amt6s_period       = true;
cfg.report.include_best_fit_tau        = true;
cfg.report.include_tau_default         = true;
cfg.report.include_tau_sweep_table     = true;

%% Run (uncomment when files are ready)
% setup_n24_toolbox;
% cfg = n24light.merge_config(cfg);  % optional: fill defaults for omitted fields
% run_n24_case(cfg);
