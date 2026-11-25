%% FUNCTION to clean light data
% Call this function per recording, for any type of light data
% This function is agnostic to the type of light data, and the study
% protocol

% Julia Stone   July 2024
% adapted cleaning code written for the CLASS Study by Anthony Hand 2022,
% which was adapted from Andrew's cleaning codes.
% (getClean.m)


% ******* INPUTS *******
%   light:          light variable (device agnostic) long format
%   light_dt:       corresponding light date-time variable in datetime format
%                   'dd-mm-yyyy HH:mm'
%   sleep_wake:     binary sleep-wake variable where 0 = sleep, 1=wake in long
%                   format
%   sleep_wake_dt:  corresponding sleep-wake date-time variable in datetime
%                   format 'dd-mm-yyyy HH:mm'

%   rulethree:       =0 does not implement cleaning rule 3, =1 runs cleaning rule 3
%                   (removes data that is too flat as "non-wear", =1
%   sleepadjust:    = 0 will leave light during sleep
%                   = 1 will adjust light levels during sleep by a fraction
%                   of XXX
%                   = 2 will set light during sleep to 0;
%   sleepclean:     =0 will not clean data according to sleep-wake (not
%                       recommended),
%                   =1 will clean using available sleep-wake data,
%                   =2 will clean using available sleep-wake data AND remove data where there is
%                       missing sleep
%   plotting:       =0 no data plot
%                   =1 plots raw and cleaned data by days
%   plotname:       string with figure title ('ID' 'timepoint' 'devicetype')
%                   recommended
%   save:           =1 save the figure, =0 doesn't save

% Note: The code will check for sleep data for cleaning. If none it will
%       spit a warning. The sleep-wake data doesn't have to align perfectly to
%       the light data, but if there is no overlap this will mean the light data
%       cannot be cleaned by all cleaning rules.

% Issue for SIM data: in-lab light is cleaned out, but we want to keep it. Read in lab times to exclude those sections from cleaning?

%% ADJUSTMENTS TO CODE for SIM:
% Added in set lux to 0 during sleep, or to set light to a small fraction (sleepadjust)
% Added in do not clean out light if lab_binary=1 in threshold step
% ADD IN do not clean out light if lab_binary=1 in flattness step
% Added inplot lab_binary  on the figures

% Adapted for iLIGHT September 2025


function clean_light = getCleanLit(light, light_dt, sleep_wake, sleep_wake_dt,lab_binary, rulethree,sleepadjust, sleepclean, plotting, plotname, save_on)


light_raw = light;

% Calculate % missing prior to any cleaning
percent_nan = ((sum(isnan(light)))/length(light))*100;

%%  ***** Zeroth rule: *****
% Remove light values that are greater than the sun can produce
% (glitch in some light pins, unlikely in condor/geneactiv devices)
uthr = 10^6; % Threshold in lux for removing light values (above)
light(light > uthr) = NaN;
clean_light.zeroth_rule = light;
clean_light.zeroth_rule_percent = ((sum(isnan(light)))/length(light))*100 - percent_nan;

%% ***** ADDED RULE: SLEEP ***
% set light values during sleep to be a fraction of the light (thus not
% discounting sleeping in a bright room entirely, but not allowing full
% levels when presumably eyes are closed)
if sleepadjust==1

% Find sleep-times in the data
    f_sleep = find(sleep_wake == 0); % Find indices corresponding to sleep
    sleep_dt = sleep_wake_dt(f_sleep); % Extract the corresponding sleep date-times (datetime format)

    % Set all datetime variables to the same format
    light_dt = dateshift(light_dt,'start','minute'); % round to the nearest minute
    sleep_dt = dateshift(sleep_dt,'start','minute');

    % Find where light datetimes are found in sleep_dt (agnostic to whether
    % they are pre-aligned)
    ismember_lp_sleep = ismember(light_dt, sleep_dt); % find where Light datetimes are found in wake_dt
    lp_sleep_idx = find(ismember_lp_sleep); % find the index of Light datetimes that correspond to sleep

    % set to missing if light less than threshold occurs during wake and
    % not in lab
    light(lp_sleep_idx) = light(lp_sleep_idx)*0.03; % determine threshold

    % store this light stream in cleaning under first step
    clean_light.sleep_rule = light;

elseif sleepadjust ==2 % set light during sleep to 0
% Find sleep-times in the data
    f_sleep = find(sleep_wake == 0); % Find indices corresponding to sleep
    sleep_dt = sleep_wake_dt(f_sleep); % Extract the corresponding sleep date-times (datetime format)

    % Set all datetime variables to the same format
    light_dt = dateshift(light_dt,'start','minute'); % round to the nearest minute
    sleep_dt = dateshift(sleep_dt,'start','minute');

    % Find where light datetimes are found in sleep_dt (agnostic to whether
    % they are pre-aligned)
    ismember_lp_sleep = ismember(light_dt, sleep_dt); % find where Light datetimes are found in wake_dt
    lp_sleep_idx = find(ismember_lp_sleep); % find the index of Light datetimes that correspond to sleep

    % set to missing if light less than threshold occurs during wake and
    % not in lab
    light(lp_sleep_idx)=NaN;

    % store this light stream in cleaning under first step
    clean_light.sleep_rule = light;

end

%% ***** First rule: COVERAGE *****
% Remove light values that are less than a threshold during
% wake, as these correspond to very likely device coverage
if sleepclean == 1 || sleepclean == 2 % run if cleaning with sleep-wake data
    threshold = 0.5; % Threshold in lux for removing light values - should we try 0.5 for melanopic?
    % Find wake-times in the data
    f1 = find(sleep_wake == 1); % Find indices corresponding to wake
    wake_dt = sleep_wake_dt(f1); % Extract the corresponding wake date-times (datetime format)

    % Set all datetime variables to the same format
    light_dt = dateshift(light_dt,'start','minute'); % round to the nearest minute
    wake_dt = dateshift(wake_dt,'start','minute');

    % Find where light datetimes are found in wake_dt (edited to be
    % agnostic to whether they are pre-aligned
    ismember_lp = ismember(light_dt, wake_dt); % find where Light datetimes are found in wake_dt
    lp_idx = find(ismember_lp); % find the index of Light datetimes that correspond to wake
    % find where pt is in the lab
    il_idx = find(lab_binary ==1); % where pt is in lab, aligned to light datetime
    cleanout_idx = setdiff(lp_idx, il_idx); % index in light data where pt is awake, and not in the lab
    % find where light is less than threshold % EDIT: but is not 'in-lab'
    f2 = find(light<threshold);

    % set to missing if light less than threshold occurs during wake and
    % not in lab
    light(intersect(cleanout_idx,f2))=NaN;

    % store this light stream in cleaning under first step
    clean_light.first_rule = light;

    % store the percent of the light stream that was removed in this cleaning step
    clean_light.first_rule_percent = ((sum(isnan(light)))/length(light))*100 - clean_light.zeroth_rule_percent;

elseif sleepclean== 0

    % Should values <1 lux be removed at all or is no cleaning for coverage
    % possible without wake times?

end

%% ***** Second rule: Rapid Drops *****
% Remove the light value if it's less than a
% certain fraction of values on both sides of it (sudden drop),
% as this also likely corresponds to device coverage.
dfact = 10; % Factor difference
minlux = 10; %10; % Value of lux that middle value must be below
for x = 2:length(light)-1 % Iterate over epochs
    if (light(x-1)/light(x))>dfact &&...
            (light(x+1)/light(x))>dfact &&...
            light(x)<minlux
        light(x) = NaN;
    else
    end
end
clean_light.second_rule = light;
clean_light.second_rule_percent = ((sum(isnan(light)))/length(light))*100 - clean_light.first_rule_percent;

%% ***** Third rule: Flatness *****
% Remove light values that are in time windows that are AWAKE with very
% low variance (i.e., too flat). This rule is still being tested.
% Currently only looks within times where pt is "awake", leaving flat data
% during sleep (as this is likely to occur during sleep)
%
%% Settings for rule three that need testing: sthr, win, lmax
% Threshold for standard deviation of log10-transformed light values.
% Set as missing if the standard deviation within a window falls below this. Should typically be ~0.05
% The bigger the s-threshold the more data you loose
sthr =  0.05; % was 0.1, seemed too strong (JS)
% Length of window for checking variance (in minutes). Should typically be ~10-20 min
win = 10; %% can we make this agnostic
lmax = 10000; % Do not clean smooth values if they are above this lux threshold (since this is outdoor)

% Adjust to not exclude data during lab visits

if rulethree ==1 % if running rule 3
    if sleepclean == 1 || sleepclean ==2 % if using sleep in cleaning
        dt = datenum(timeofday(light_dt)); % time in datenum hours (no dates)
        t1 = dt(1,1);
        t2 = dt(2,1);
        dt = (t2-t1)*60; % find the timestep duration  *24); % removed the *24 as this was throwing off the calculations of time (the unit was wrong)
        contime = ([1:(length(light))]'*(t2-t1)+t1)*24; % continuous time in decimal hours the length of light data

        wsteps = win*dt*24; % in 1min epochs this should =10 epochs covering 10 minutes
        wsteps = wsteps + mod(wsteps+1,2); % If it's an even number, add one to make the window size an odd number
        luxclean = light;
        v_ind = luxclean*0;

        %% Align sleep-wake and light data for this step:
        % make sleep_wake the length of light, but with all wake if there are
        % missing epochs (warning: if there is a large mismatch (> multiple days) this will
        % assume wake when there was probably sleep
        % Create a new sleep_wake array to match the length of light, assuming awake
        new_sleep_wake_dt = light_dt; % use light_dt as the reference for the new sleep_wake_dt
        new_sleep_wake = ones(size(new_sleep_wake_dt)); % initialize with 1s (awake)
        % Find indices in new_sleep_wake_dt that match sleep_wake_dt
        [~, matching_idx] = ismember(sleep_wake_dt, light_dt);

        % Update new_sleep_wake with the values from the original sleep_wake
        new_sleep_wake(matching_idx(matching_idx > 0)) = sleep_wake(matching_idx > 0);

        % find where pt is in the lab
        il_idx = find(lab_binary ==1); % where pt is in lab, aligned to light datetime
        % set new_sleep_wake to sleep when in lab purely for this rule.
        new_sleep_wake(il_idx) = 0; % set new sleep wake to sleep (0) when in lab, so that it is not included in the flatness rule (THIS RULE ONLY)

        if ~isempty(sleep_wake) % if sleep_wake variable is present
            for j = 1:length(light) % loops over light, not the windows? moving window in 1min timesteps?
                % Find the closest timestamps in sleep_wake to the current light timestamp
                [~, closest_idx] = min(abs(new_sleep_wake_dt - light_dt(j))); % this finds the closest not a match - if sleep-wake is misaligned this won't work?
                % Extract windows around the closest timestamp
                awakewin_start = max(1, closest_idx - ceil((wsteps - 1) / 2)); % find the start index of the current window
                awakewin_end = min(length(new_sleep_wake), ceil(closest_idx + (wsteps - 1) / 2)); % find the end index of the current window
                awakewin = new_sleep_wake(awakewin_start:awakewin_end); % sleepwake values within the current window

                % Determine if any part of the window is awake
                awake = any(awakewin==1);

                % Extract light data windows around the current point
                Lwin_start = max(1, floor(j - (wsteps - 1) / 2));
                Lwin_end = min(length(luxclean), ceil(j + (wsteps - 1) / 2));
                Lwin = luxclean(Lwin_start:Lwin_end); % extract the light values in the current window
                Lwin_log = log10(Lwin + 0.1); % logtransform the light variable

                % Extract corresponding continuous time windows
                twin = contime(Lwin_start:Lwin_end);
                twin = twin(Lwin_log > -Inf); % not sure what this is doing and if it is necessary
                Lwin_log = Lwin_log(twin > -Inf);

                % Run linear regression model on light data within time window to test if residuals of fit are sufficiently high
                % (i.e. data isn't flat) during wake. Excludes data >lmax (i.e. outdoor light data allowed to be flat - review)
                if length(Lwin_log) >= 2
                    p = polyfit(twin, Lwin_log, 1); % coefficients for linear regression over the light data within the window
                    Lwin_log_fit = p(1) * twin + p(2); % Calcualtes fitted values based on the linear model (predicted log transformed light values)
                    Lwin_log_res = Lwin_log - Lwin_log_fit; %calculate the residuals between model-predicted data and actual light data
                    v_ind(j) = abs((nanstd(Lwin_log_res) < sthr)... % checks if the SD of the residuals is less than specified threshold
                        * (nanmean(Lwin) < lmax) ... % checks if the mean original light data in the window is less than specified max value (outdoor daylight value)
                        * awake);  % checks if the window covers wake data
                    % if ALL conditions are true then v_ind(j) will be 1 (i.e., light is during wake and too flat and below the max light limit), else it will be 0
                end
            end
        end
        luxclean(v_ind==1) = nan; % set all indices of v_ind (not meeting criteria for being sufficiently variable data during wake) to NaN
        light = luxclean; % update the light variable



    elseif sleepclean ==0 % run rule three but without the wake requirement
        dt = datenum(timeofday(light_dt)); % time in datenum hours (no dates)
        t1 = dt(1,1);
        t2 = dt(2,1);
        dt = (t2-t1)*60; % find the timestep duration  *24); % removed the *24 as this was throwing off the calculations of time (the unit was wrong)
        contime = ([1:(length(light))]'*(t2-t1)+t1)*24; % continuous time in decimal hours the length of light data

        wsteps = win*dt*24; % in 1min epochs this should =10 epochs covering 10 minutes
        wsteps = wsteps + mod(wsteps+1,2); % If it's an even number, add one to make the window size an odd number (JS: why?)
        luxclean = light;
        v_ind = luxclean*0;

        for j = 1:length(light)
            % Extract light data windows around the current point
            Lwin_start = max(1, floor(j - (wsteps - 1) / 2));
            Lwin_end = min(length(luxclean), ceil(j + (wsteps - 1) / 2));
            Lwin = luxclean(Lwin_start:Lwin_end); % extract the light values in the current window
            Lwin_log = log10(Lwin + 0.1); % logtransform the light variable

            % Extract corresponding continuous time windows
            twin = contime(Lwin_start:Lwin_end);
            twin = twin(Lwin_log > -Inf); % not sure what this is doing and if it is necessary
            Lwin_log = Lwin_log(twin > -Inf);

            % Run linear regression model on light data within time window to test if residuals of fit are sufficiently high
            % (i.e. data isn't flat). Excludes data >lmax (i.e. outdoor light data allowed to be flat - review)
            if length(Lwin_log) >= 2
                p = polyfit(twin, Lwin_log, 1); % coefficients for linear regression over the light data within the window
                Lwin_log_fit = p(1) * twin + p(2); % Calcualtes fitted values based on the linear model (predicted log transformed light values)
                Lwin_log_res = Lwin_log - Lwin_log_fit; %calculate the residuals between model-predicted data and actual light data
                v_ind(j) = abs((nanstd(Lwin_log_res) < sthr)... % checks if the SD of the residuals is less than specified threshold
                    * (nanmean(Lwin) < lmax));% ... % checks if the mean original light data in the window is less than specified max value (outdoor daylight value)
                % if ALL conditions are true then v_ind(j) will be 1 (i.e., light is too flat and below the max light limit), else it will be 0
            end
        end

        luxclean(v_ind==1) = nan; % set all indices of v_ind (not meeting criteria for being sufficiently variable data during wake) to NaN
        light = luxclean; % update the light variable

    end
    clean_light.third_rule = light;
    clean_light.third_rule_percent = ((sum(isnan(light)))/length(light))*100 - clean_light.second_rule_percent - clean_light.first_rule_percent;
end


%% Plot data for review
% plot by days: raw in red, with cleaned overlaid in blue
if plotting ==1
    % determine range of days
    startDay = dateshift(light_dt(1), 'start', 'day');
    endDay = dateshift(light_dt(end), 'start', 'day');
    numDays = days(endDay - startDay) + 1;
    numCols = 5;
    numRows = ceil(numDays / numCols);
    figure;
    % Loop through each day and create a subplot
    for dayIdx = 0:numDays-1
        % Define the start and end of the current day
        day_start = startDay + days(dayIdx);
        day_end = day_start + days(1);
        % Logical index for the current 24-hour period
        day_Idx = light_dt >= day_start & light_dt < day_end;
        % Extract the data for the current 24-hour period
        day_light_dt = light_dt(day_Idx);
        day_light_clean = light(day_Idx);
        day_light_raw = light_raw(day_Idx);
        day_lab_binary = lab_binary(day_Idx); % in lab or no
       

        % Find the corresponding sleep_wake data for the current day
        idx_sleep_wake = sleep_wake_dt >= day_start & sleep_wake_dt < day_end;
        day_sleep_wake_dt = sleep_wake_dt(idx_sleep_wake);
        day_sleep_wake = sleep_wake(idx_sleep_wake);
        % Plot grey shading for sleep periods
        sleep_interval = find(day_sleep_wake == 0);
        sleep_interval_dt = day_sleep_wake_dt(sleep_interval);
        % Create a vector for shading sleep intervals
        sleep_shading = nan(length(day_light_dt),2); %log10(0.1) * ones(size(day_light_dt)); % initalise shading vector
        for k = 1:length(sleep_interval_dt)
            [~, closest_idx] = min(abs(day_light_dt - sleep_interval_dt(k)));
            sleep_shading(closest_idx,:) = [log10(0.1), 1]; %max(log10(day_light_raw))
        end
        % plot blue shading for lab periods - get intervals
        lab_interval = find(day_lab_binary == 1);
        % if ~isempty(lab_interval)
            lab_interval_dt = day_light_dt(lab_interval);
            % Create a vector for shading lab intervals
            lab_shading = nan(length(day_light_dt),2); %log10(0.1) * ones(size(day_light_dt)); % initalise shading vector
            for k = 1:length(lab_interval_dt)
                [~, closest_idx] = min(abs(day_light_dt - lab_interval_dt(k)));
                lab_shading(closest_idx,:) = [log10(0.1), 1]; %max(log10(day_light_raw))
            end
        % else
        %     lab_shading = []; % if no lab on that date
        % end

               
        % Create a subplot for the current day
        subplotIdx = dayIdx +1;
        subplot(numRows,numCols,subplotIdx);
        hold on

        % Plot grey shading for sleep periods  (note: puts a line at 0, cannot work out how to get rid of it)
        area(day_light_dt, sleep_shading, 'FaceColor', [0 0 0], 'EdgeColor', 'none'); %[0.9 0.9 0.9]
        % Plot purple shading for in-lab periods  
        if ~isempty(lab_shading)
            area(day_light_dt, lab_shading, 'FaceColor', "#B65FCF", 'EdgeColor', 'none'); 
        end
              
        % Plot the light data
        plot(day_light_dt, log10(day_light_raw + 0.1), 'r', 'DisplayName', 'Light Raw');
        plot(day_light_dt, log10(day_light_clean + 0.1), 'b','DisplayName','Light Clean');

        hold off

        title(['Day ', num2str(dayIdx), ': ', datestr(day_start, 'mmm dd, yyyy')]);
        %xlabel('Time');
        ylabel('Light Intensity');
        % Format x-axis to show hours
        xtickformat('HH:mm');
        xlim([day_start day_end]);
        ylim([-2, 5]);
        grid on;
    end
    sgtitle(plotname);
    %legend('show')
    if save_on ==1
        fname= strcat(plotname, '.tif');
        set(gcf,'Position', [100, 100, 1200, 1000]);
        print(gcf, fname, '-dtiff', '-r500');
    end
end


%% Output data
clean_light.cleaned_light = light; % cleaned light
clean_light.orig_light = light_raw; % raw light
clean_light.light_dt = light_dt;
end