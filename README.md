# N24 light behaviour testing code — guidebook

## Purpose and associated publication

This MATLAB package supports analyses of **interactions between measured light exposure and variation in estimated circadian period (τ)** in **sighted non-24-hour sleep–wake disorder (N24SWD)**, as described in Stone et al. (2026). It is intended for assessing interactions between monitored light behaviours and tau as explanatory factors for the measured cycling circadian phase. Inputs are sleep–wake, light, and urinary aMT6s acrophase files for each participant. The workflow aligns timelines, optionally cleans light, runs a **St Hilaire et al. (2007)** light–sleep–non-photic pacemaker model over a τ grid, and compares modelled core body temperature minimum (CBTmin) to measured acrophase times. Outputs include optional **sleep-onset period** and **aMT6s acrophase period**, **best-fitting model τ** (by phase RMSE), and a **default τ = 24.15 h** comparison. No participant dates or identifiers are hard-coded.

**Associated publication:**

Stone, J. E., McGlashan, E. M., Downie, L. E., Wu, C. Y., Cichello, E., Ayton, L., Yap, R., Zhong, Y., Landry, S. A., Mansfield, D. R., Bei, B., Rajaratnam, S. M. W., & Phillips, A. J. K. (2026). Assessing physiological underpinnings of sighted non-24-hour sleep-wake phase disorder. *Journal of Biological Rhythms*.

**Circadian pacemaker model:**

St Hilaire, M. A., Klerman, E. B., Khalsa, S. B. S., Wright, K. P., Jr., Czeisler, C. A., & Kronauer, R. E. (2007). Addition of a non-photic component to a light-based mathematical model of the human circadian pacemaker. *Journal of Theoretical Biology*, *247*(4), 583–599.

---

## Quick start

1. Open MATLAB and change directory to this folder.
2. Copy `N24_CaseConfig_template.m` to a new file (e.g. `MyCase_config.m`).
3. Set paths to your three input tables and adjust column names if needed (see **Data formats** below).
4. Run:

```matlab
setup_n24_toolbox;
run_n24_case('MyCase_config.m');
```

Alternatively, define `cfg` in your script and call `run_n24_case(cfg)`.

### Synthetic test data

Folder `examples/synthetic_test_data/` contains fake monitoring data (~25 h sleep cycle, small nightly jitter; aMT6s acrophase at **day 0, 12, and 24**). Regenerate with `generate_synthetic_example_data.m` (or `.py` if Python is available).

Folder `examples/synthetic_irregular_test_data/` adds **irregular sleep-onset spacing** (mostly ~25 h with intermittent ~24 h “phase-hold” nights and occasional long gaps); run `generate_synthetic_irregular_data` and `N24_CaseConfig_synthetic_irregular.m` — see that folder’s `README.txt`.

Then (regular synthetic):

```matlab
setup_n24_toolbox;
run_n24_case(fullfile('examples', 'N24_CaseConfig_synthetic_test.m'));
```

Or open the app and browse to the three `synthetic_*.csv` files; set case ID `SYNTHETIC_TEST`.

### Desktop app (MATLAB R2019b or later)

```matlab
setup_n24_toolbox;
launch_N24TauTestingApp;
```

Browse for files, set τ search bounds, choose **report** rows and **outputs** (TIFF, XLSX), then **Run analysis**. The UI source is `N24TauTestingApp.m` (editable in App Designer if you wish).

---

## What the analysis does

1. **Align** sleep, light, and acrophase to the **first valid light epoch**.
2. Optionally **clean** light (`getCleanLit`).
3. Set initial DLMO phase (`tDLMO`) automatically from the first sleep onset or manually.
4. **Sweep τ** over a user-defined range; at each τ, run the St Hilaire et al. (2007) model (see reference above) and score CBTmin vs measured acrophase (circular RMSE).
5. Compute **observed periods**: sleep-onset drift per night; aMT6s period from acrophase datetime drift beyond 24 h/day (see **Report fields**).
6. Export optional **raster** (sleep, acrophase markers, default vs best-fit CBTmin) and **Excel summary**.


---

## Data formats

Three input files per participant (Excel `.xlsx` or `.csv`). All times must parse as MATLAB `datetime` where indicated.

### 1. Sleep–wake (`cfg.sleep_wake_file`)

**Option A — continuous hours** (if already on a diary timebase)

| Column (default name) | Config key | Description |
|----------------------|------------|-------------|
| SleepOn_Continuous | `sleep_on_cont` | Sleep onset, decimal hours |
| WakeUp_Continuous | `wake_up_cont` | Wake time, same scale |
| BedTimeDate | `bed_date` (optional) | Used to shift diary onto the light reference |

**Option B — datetimes**

| Column | Config key | Description |
|--------|------------|-------------|
| SleepOnset_DT | `sleep_onset_dt` | Sleep onset |
| WakeUp_DT | `wakeup_dt` | Wake time |

The raster expects alternating switches: onset₁, wake₁, onset₂, wake₂, …

**Example (Option B — datetime columns):**

```
BedTimeDate          SleepOnset_DT           WakeUp_DT
2021-03-14           2021-03-14 23:30:00    2021-03-15 07:15:00
2021-03-15           2021-03-15 23:45:00    2021-03-16 07:00:00
2021-03-16           2021-03-16 00:15:00    2021-03-16 07:30:00
```

**Example (Option A — continuous hours on a diary timebase, with optional bed date):**

```
BedTimeDate          SleepOn_Continuous    WakeUp_Continuous
2021-03-14           23.50                 31.25
2021-03-15           23.75                 31.00
2021-03-16           24.25                 31.50
```

(Continuous values are decimal hours from the diary reference; the toolbox shifts them onto the **first light epoch** when `bed_date` is supplied.)

### 2. Light epochs (`cfg.light_file`)

| Column | Required | Config key | Description |
|--------|----------|------------|-------------|
| Date + Time, or one datetime column | Yes | `light_date` + `light_time`, or `light_datetime` | Epoch time |
| Illuminance | Yes | `light_lux` | **Photopic illuminance (lux)** — see note below |
| Sleep–wake | Optional | `light_sw` | 1 = wake, 0 = sleep |

Illuminance must be expressed as **photopic illuminance in lux** (V(λ)-weighted), consistent with the light input assumed by the St Hilaire et al. (2007) formulation. Convert device-specific or melanopic metrics to photopic lux before analysis, or document any calibration applied. Any wrist or pendant epoch series is acceptable if times and lux are aligned; device type is not fixed. The **analysis time origin** is the **first valid light epoch**. Optional cleaning is controlled by config only (`use_cleaned_light`).

**Example (Date + Time + lux + wake/sleep flag):**

```
Date         Time      WhiteLight    Sleep_Wake
2021-03-14   00:00:00  0.2           0
2021-03-14   00:01:00  0.2           0
2021-03-14   08:00:00  320           1
2021-03-14   08:01:00  285           1
2021-03-14   23:00:00  45            1
```

(`WhiteLight` = photopic lux; `Sleep_Wake`: 0 = sleep, 1 = wake.)

**Example (single datetime column):**

```
DateTime              Lux    Wake
2021-03-14 00:00:00   0.2    0
2021-03-14 08:00:00   320    1
```

Map column names via `cfg.cols` (e.g. `light_datetime`, `light_lux`, `light_sw`).

### 3. aMT6s acrophase (`cfg.acrophase_file`)

| Column | Required | Config key | Description |
|--------|----------|-------------|-------------|
| AcrophaseDateTime | Yes | `acrophase_dt` | **Datetime** of each measured/fitted acrophase |

One row per collection; rows are sorted by time. Clock-hour-only acrophase columns are not supported in this version.

**Example (column AcrophaseDateTime):**

```
2021-03-15 07:20:00
2021-03-25 08:45:00
```

Map different header names via `cfg.cols` in your config script.

`run_n24_case` checks that files exist, acrophase datetimes are valid, and τ bounds are sensible.

---

## Configuration highlights

| Setting | Role |
|---------|------|
| `clock_offset` | Clock hour start of raster / RMSE window (default 6 h; 6–30 h style) |
| `tau_min`, `tau_max`, `tau_step` | τ search grid |
| `tau_default` | Fixed 24.15 h comparison on raster and report |
| `tdlmo_mode` | `'auto'` (from first sleep bout) or `'manual'` + `tdlmo_manual` |
| `use_cleaned_light` | Run `getCleanLit` when true |
| `cfg.report.*` | Which rows appear on the Excel **report** sheet |
| `cfg.outputs.*` | Export raster TIFF and/or summary XLSX |

Full template: `N24_CaseConfig_template.m`.

---

## Report fields (Excel)

Workbook sheets:

| Sheet | Contents |
|-------|----------|
| **`guide`** | Short description of each sheet |
| **`report`** | Columns **Item** (plain language), **Value**, **Definition**, and **Technical_ID** (internal field name for scripts) |
| **`tau_sweep`** | Friendly column headers for each tested model τ |
| **`alignment`** | Sleep vs light time coverage and overlap |

The UI tick boxes still control which optional rows appear on **`report`** (sleep period, aMT6s period, best-fit τ, default τ, sweep table). Core rows always include case ID, model start time, **starting DLMO for the model**, and sleep–light overlap.

Sheet **`alignment`**: sleep and light span and overlap (hours from model start). Overlap is required for meaningful modelling; a warning is printed if none.

---

## Outputs

Default folder: `outputs/<case_id>/` (override with `cfg.output_dir`).

| File | Contents |
|------|----------|
| `<case_id>_tau_raster.tif` | Double-plotted raster: sleep, optional measured light (lux bands), acrophase, default vs best-fit CBTmin |
| `<case_id>_tau_summary.xlsx` | Sheets: `guide`, `report`, `tau_sweep` (optional), `alignment` |

---

## Troubleshooting

| Issue | What to check |
|-------|----------------|
| Empty RMSE / n = 0 | Acrophase datetimes vs model day span; `clock_offset` |
| No overlap warning | Light dates vs sleep diary dates; reference = first light |
| NaN τ table | Lux units, sleep–wake vector, long gaps in light |
| Unexpected auto tDLMO | Switch to `tdlmo_mode = 'manual'` and set `tdlmo_manual` |

---

## Dependencies

- MATLAB R2019b+ recommended (`datetime`, `writetable`, `uifigure`)
- Statistics and Machine Learning Toolbox (`fitlm` for observed periods)
- Bundled model/plot code in `lib/` — see `ATTRIBUTION.md`

---

## Contact and citation

When using this supplement, cite Stone et al. (2026) and, for the pacemaker implementation, St Hilaire et al. (2007) (full references in **Purpose and associated publication**).

**Code contact:** Dr Julia Stone, University of Melbourne: julia.stone@unimelb.edu.au
