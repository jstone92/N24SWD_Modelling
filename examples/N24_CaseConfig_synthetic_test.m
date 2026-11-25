function cfg = N24_CaseConfig_synthetic_test()
%N24_CASECONFIG_SYNTHETIC_TEST Config pointing at examples/synthetic_test_data CSVs.
%   Regenerate data: cd examples/synthetic_test_data; generate_synthetic_example_data
%   Run: setup_n24_toolbox; run_n24_case(@N24_CaseConfig_synthetic_test);
%   Or:  run_n24_case(fullfile('examples','N24_CaseConfig_synthetic_test.m'));

dataDir = fullfile(fileparts(mfilename('fullpath')), 'synthetic_test_data');

cfg = struct();
cfg.case_id = 'SYNTHETIC_TEST';
cfg.output_dir = fullfile(dataDir, 'outputs');
cfg.sleep_wake_file = fullfile(dataDir, 'synthetic_sleep.csv');
cfg.light_file      = fullfile(dataDir, 'synthetic_light.csv');
cfg.acrophase_file  = fullfile(dataDir, 'synthetic_acrophase.csv');
cfg.file_format = 'csv';

cfg.cols.light_datetime = 'DateTime';
cfg.cols.light_lux      = 'WhiteLight';
cfg.cols.light_sw       = 'Sleep_Wake';
cfg.cols.acrophase_dt   = 'AcrophaseDateTime';
cfg.cols.sleep_onset_dt = 'SleepOnset_DT';
cfg.cols.wakeup_dt      = 'WakeUp_DT';
cfg.cols.bed_date       = 'BedTimeDate';

cfg.tau_min = 24.0;
cfg.tau_max = 26.0;
cfg.tau_step = 0.1;
end
