%% Function to prepare light data for input into circadian model
% Processes gapfilling based on options:

% Function takes the inputs:
% - time (Nx1 vector)
% - light in lux (Nx1 vector)
% - wakesleep (Nx1 vector); 1=wake, 0=sleep
% - maxgap = duration in hours that an NaN interval in light / wakesleep can
%   be filled by estimated values
% - gapfill = setting for which gapfilling to use; 1 = fill gap with the
% avg of the prior 2 hours, 2= fill gap with the avg of the matched clock
% time on days with same sleep timing classification (daysleep or night
% sleep) - REMOVED THE CLASSIFICATION PART?

% Outputs the longest filled light vector with time and SW

% note this code does not do any data cleaning of light data


function [t, Light, SW] = prepareLightInput(t,Light,wakesleep,maxgap, gapfill)
SW = wakesleep;
%Light = Light;

%gapfill = 2; % 1=gap fill method, 2=clocktime imputation method
fillgap_mins = 120; % minutes to use for matched clocktime gapfilling

% truncate bad data at beginning
ff=find(Light>-Inf);
f1=min(ff);
Light=Light(f1:end);
SW=SW(f1:end);
t=t(f1:end);

% truncate bad data at end
ff=find(Light>-Inf);
f2=max(ff);
Light=Light(1:f2);
SW=SW(1:f2);
t=t(1:f2);

Lgood = 1-isnan(Light.*SW); % variable indicating where there are good light and sleep data

ff = find(diff(Lgood)~=0); % find where transitions occur
fi = [1;ff;length(Lgood)];
Ints = diff(fi);

%GoodInts = Ints(1:2:end)*(t2-t1); % intervals of good data (number of days)
BadInts = Ints(2:2:end)*(t(2)-t(1)); % intervals of bad data (number of days)
maxgap = maxgap/24; % Fraction of day that can be missing
fillgap = 2/24; % Fraction of preceding day to fill with
fillsteps = floor(fillgap/(t(2)-t(1)));
if gapfill == 1
    %% Gap fill method (with all same value or with a previous time value)
    for j=1:length(BadInts) % check length of each bad interval
        if BadInts(j)<maxgap % if the gap is less than max gap, fill it in with avg of previous 2 hours
            Light(ff(2*j-1):ff(2*j))=nanmean(Light(max(ff(2*j-1)-fillsteps,1):ff(2*j-1))); % Set to mean value for fillgap range
            %Light(ff(2*j-1):ff(2*j))=0; % Set to zero in missing interval
            SW(ff(2*j-1):ff(2*j))=1;
        else
        end
    end
    
elseif gapfill ==2 
    %% fill using clock time on days with similar sleep time 
    % Convert time and identify unique days
    t_dt = datetime(t, 'ConvertFrom', 'datenum');
    clock_times = timeofday(t_dt);% time of day (HH:MM:SS)
    isSleep = SW == 0; % find sleeps
    sleep_transitions = diff([0; isSleep; 0]);  % find transitions
    sleep_starts = find(sleep_transitions == 1);
    sleep_ends = find(sleep_transitions == -1) - 1;

    % % === STEP 1: Classify sleep episodes based on midpoint time ==
    % % (midpoint pre-9am = night sleep, after 9am = day sleep)
    % nEpisodes = length(sleep_starts);
    % sleep_midpoints = nan(nEpisodes, 1);
    % sleep_episode_label = nan(nEpisodes, 1);  % 1 = night, 0 = day
    % % loop over sleep episodes to classify sleep type (night or day sleep)
    % for i = 1:nEpisodes
    %     idx = sleep_starts(i):sleep_ends(i);
    %     sleep_clock = timeofday(datetime(t(idx), 'ConvertFrom', 'datenum')); % Clock times in this episode
    %     sleep_secs = seconds(sleep_clock); % Convert to seconds since midnight
    %     % Calculate circular sleep midpoint midpoint (e.g. 23:00 and 01:00 → 00:00)
    %     angles = 2*pi*sleep_secs/(24*3600);
    %     mean_angle = atan2(mean(sin(angles)), mean(cos(angles)));
    %     if mean_angle < 0
    %         mean_angle = mean_angle + 2*pi;
    %     end
    %     mid_sec = (mean_angle / (2*pi)) * 24*3600;
    %     sleep_midpoints(i) = mid_sec; % midpoint in seconds since midnight
    % 
    %     % Classify sleep type based on circular midpoint
    %     if mid_sec < 11*3600 % if midpoint is before 9am (9* seconds)
    %         sleep_episode_label(i) = 1; % night sleeper
    %     else
    %         sleep_episode_label(i) = 0; % day sleeper
    %     end
    % end
    % 
    % % Assign each timepoint the class of its corresponding sleep episode
    % time_sleep_class = ones(size(t)); %% Initialize timepoint-level vector for sleep class, assume 1 (night sleep) as default
    % for s = 1:length(sleep_starts)
    %     time_sleep_class(sleep_starts(s):sleep_ends(s)) = sleep_episode_label(s); % adds in day sleeps
    % end

    % === STEP 2: Fill missing light using matching sleep type and clock time ===
    for j = 1:length(BadInts)
        if BadInts(j) < maxgap
            gap_idx = ff(2*j-1):ff(2*j);
           % sleep_midpoints = round((sleep_starts + sleep_ends) / 2); % Compute midpoints of sleep episodes in index units
           % [~, closest_ep_idx] = min(abs(sleep_midpoints - gap_idx(1))); % Find index of the sleep episode with midpoint closest to start of the gap
           % this_sleep_class = sleep_episode_label(closest_ep_idx);  % Use the sleep class label for that episode

            % Find times with same sleep class and valid light data
            %matching_idx = find((time_sleep_class == this_sleep_class)); % & (Lgood == 1));
            % if this_sleep_class ==0
            %     fillgap_mins = 4*60; % 4 hours if day sleep (expand catchment)
            % elseif this_sleep_class ==1
                fillgap_mins = 2*60; % 2 hours if night sleep (more likely to have data?)
            % end
            % Fill each missing point using clock-time matched mean, on
            % relevant day or night sleep times
            fill_vals = nan(size(gap_idx));
            for k = 1:length(gap_idx)

                ct = clock_times(gap_idx(k));
                match_ct_idx = find(abs(clock_times - ct) < minutes(fillgap_mins));  % clock time match within 2 hours - make broader?
                %relevant_idx = intersect(match_ct_idx,matching_idx); % keep the indices of times that match CT, and are in the correct sleep class
                % if ~isempty(relevant_idx)
                %     % 1: try matching with clock time across similar days,
                %     % within 2 hours
                    fill_vals(k) = mean(Light(match_ct_idx), 'omitnan');
                % else
                %     % 2: else try using 2h of prior light data from the gap
                %     fill_vals(k) = mean(Light(gap_idx(k)-fillsteps:gap_idx(k)), 'omitnan');
                % end
            end
            % If some values were filled but others are still NaN, fill NaNs with the mean of the filled values
            if any(~isnan(fill_vals)) && any(isnan(fill_vals))
                mean_val = mean(fill_vals, 'omitnan');
                fill_vals(isnan(fill_vals)) = mean_val;
            end

            Light(gap_idx) = fill_vals; % insert filled gap values into Light
            SW(gap_idx) = 1;  % assume wake in filled gaps
        end

    end
end

%% Check for remaining gaps:
% Check the data again after filling gaps
Lgood = 1-isnan(Light); % variable displaying where there are good light data

ff = find(diff(Lgood)~=0); % find where transitions occur
fi = [1;ff;length(Lgood)];
Ints = diff(fi);

GoodInts = Ints(1:2:end)*(t(2)-t(1)); % intervals of good data (number of days)
BadInts = Ints(2:2:end)*(t(2)-t(1)); % intervals of bad data (number of days)

gg = max(GoodInts);
fg = find(GoodInts==max(GoodInts));

Light = Light(fi(2*fg-1)+1:fi(2*fg)-1);
SW = SW(fi(2*fg-1)+1:fi(2*fg)-1);
t = t(fi(2*fg-1)+1:fi(2*fg)-1);

days = floor(t(end)-t(1));
ff = find((t-t(1))<(days)-10^-8);

% Set final light/sw values for the model
Light = Light(ff);
SW = SW(ff);
t = t(ff);

end