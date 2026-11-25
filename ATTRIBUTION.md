# Attribution and third-party code

## Package authors

- Julia Stone — julia.stone@unimelb.edu.au  
- Andrew J.K. Phillips — ajk.phillips@flinders.edu.au  

When citing this supplement, please credit the authors above and the circadian modelling code below.

## Files in `lib/` (bundled for redistribution with the paper)

| File | Origin / notes |
|------|----------------|
| `circ_model.m` | AJK Phillips (updated J. Stone 2025). Circadian pacemaker simulation from light + sleep–wake. |
| `hilaire_de2.m` | ODE right-hand side for St Hilaire et al. (2007) model (used by `circ_model`). |
| `prepareLightInput.m` | Gap-filling and trimming of light epochs for model input. |
| `raster_deluxe_cursor.m` | Raster sleep/plot overlay (Phillips / Stone adaptations). |
| `getCleanLit.m` | J. Stone (2024) |

These copies are included so recipients can run the toolbox self-contained from this folder. Sync `lib/` before publishing an updated supplement version.

## New code in `+n24light/` and entry scripts

Written for generalised N24 τ testing (2026): configuration, validation, alignment, τ sweep, RMSE scoring, raster export, and XLSX summaries.

**License:** Use and share with the accompanying paper; contact the authors for redistribution outside that context.
