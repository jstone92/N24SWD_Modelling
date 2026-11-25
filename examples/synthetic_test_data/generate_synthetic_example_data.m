%% Generate synthetic test CSVs (same logic as generate_synthetic_example_data.py)
rng(42);
outDir = fileparts(mfilename('fullpath'));

nNights = 38;
onset0 = datetime(2021, 6, 1, 23, 0, 0);
tauSleepH = 25.05;

bedDate = NaT(nNights, 1);
sleepOn = NaT(nNights, 1);
wakeUp = NaT(nNights, 1);
for i = 1:nNights
    ons = onset0 + hours((i-1) * tauSleepH + 0.25*randn());
    wak = ons + hours(7.5 + 0.1*randn());
    bedDate(i) = dateshift(ons, 'start', 'day');
    sleepOn(i) = ons;
    wakeUp(i) = wak;
end
writetable(table(bedDate, sleepOn, wakeUp, 'VariableNames', ...
    {'BedTimeDate','SleepOnset_DT','WakeUp_DT'}), fullfile(outDir, 'synthetic_sleep.csv'));

acro0 = datetime(2021, 6, 1, 7, 30, 0);
acroDaySpacing = [0, 12, 24];
acro_dt = acro0 + days(acroDaySpacing) + hours(acroDaySpacing * 1.02 + 0.15*randn(1, 3));
writetable(table(acro_dt(:), 'VariableNames', {'AcrophaseDateTime'}), ...
    fullfile(outDir, 'synthetic_acrophase.csv'));

tStart = datetime(2021, 6, 1, 0, 0, 0);
tEnd = wakeUp(end) + hours(12);
tGrid = (tStart:minutes(15):tEnd)';
nE = numel(tGrid);
lux = zeros(nE, 1);
sw = ones(nE, 1);
for k = 1:nE
    tk = tGrid(k);
    asleep = false;
    for j = 1:nNights
        if tk >= sleepOn(j) && tk < wakeUp(j)
            asleep = true;
            break;
        end
    end
    sw(k) = double(~asleep);
    if asleep
        lux(k) = 0.1 + 2*rand();
    else
        hr = hour(tk) + minute(tk)/60;
        if hr >= 8 && hr <= 18
            lux(k) = 180 + 220*rand() + 40*sin(2*pi*hr/24);
        else
            lux(k) = 20 + 80*rand();
        end
    end
end
writetable(table(tGrid, lux, sw, 'VariableNames', {'DateTime','WhiteLight','Sleep_Wake'}), ...
    fullfile(outDir, 'synthetic_light.csv'));

fprintf('Synthetic CSVs written to %s\n', outDir);
