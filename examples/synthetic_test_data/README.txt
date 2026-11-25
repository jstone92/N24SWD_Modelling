Synthetic monitoring data for toolbox testing.

Files (after generation):
  synthetic_sleep.csv       - 38 nights; onset interval ~25.05 h + noise (~1 h later per calendar day)
  synthetic_light.csv       - 15-min epochs, photopic lux + Sleep_Wake (0/1)
  synthetic_acrophase.csv   - 3 urinary acrophase datetimes at day 0, 12, 24

Regenerate:
  In MATLAB: generate_synthetic_example_data
  Or Python: python generate_synthetic_example_data.py  (if Python installed)

Run analysis:
  cd to package root; setup_n24_toolbox;
  run_n24_case(fullfile('examples','N24_CaseConfig_synthetic_test.m'));

Outputs: examples/synthetic_test_data/outputs/
