%% Code for simulating phase and amplitude from light and sleep-wake data
% AJK Phillips, updated 5/2023
% Updated JS July 2025 for use on SIM data

function [t_dt_input,t,t_dlmo, looped_V0, period_h] = circ_model(t,Light,SW,tDLMO, looping, looped_V0, set_p, set_tau)
% [t_dt_input,t,n,x,xc,L,W] = circ_model(t,Light,wakesleep,maxgap,tDLMO, looping, set_p)
% Function takes the inputs:
% - time (Nx1 vector)
% - light in lux (Nx1 vector)
% - wakesleep (Nx1 vector); 1=wake, 0=sleep
% - maxgap = duration in hours that an NaN interval in light / wakesleep can
%   be filled by estimated values
% Function provides the outputs:
% - time (Mx1 vector)
% - n (Mx1 vector) = photoreceptor var
% - x (Mx1 vector) = pacemaker var 1
% - xc (Mx1 vector) = pacemaker var 2
% - L (Mx1 vector) = light
% - W (Mx1 vector) = wakesleep
% amended to export:
% t_dt_input: datetime time vector that was input into the model
% t (Mx1 vector)
% t_dlmo: predicted DLMO times in increasing time over days

%% Circadian parameter values
f    = 0.99729;           % nonlinear correction
taux = set_tau; %24.15;   % endogenous SCN period (h)

% Parameters are stored in a vector. Parameter values
% are from St. Hilaire et al. Addition of a non-photic component to a
% light-based mathematical model the human circadian pacemaker, J.
% Theor. Biol. (2007).

p{1} = 2*pi/(24);       % ap (h^{-1})
p{2} = 0.13;                 % muc
p{3} = 1/3;                  % c1
p{4} = 4/3;                  % c2
p{5} = -256/105;             % c3
p{6} = 1/3;                  % q
p{7} = 0.55;                 % k
p{8} = (24/(f*taux))^2; %
p{9} = 0.007;                % beta (h^{-1})
p{10} = 1*0.032;             % rho

p{11} = 0.10; % alpha0 (h^{-1})
p{12} = 9500; % I0
p{13} = 0.5; % p
p{14} = 100; % I1
p{15} = 0.4; % b %AKA our PRC K parameter %0.4 default
p{16} = 37; % G

if isempty(set_p)
    p{13}=0.5; % default value
else
    p{13} = set_p;
end

% Set initial conditions for the model
days_input=t(end)-t(1); % need to set this for datenum input
if length(t)>1
    if looping ==0
        trange=t(end)-t(1);
        text = t;
        Lext = Light;
        SWext = SW;

    elseif looping==1
        % Tmax = 28; % number of days to simulate
        % trange=t(end)-t(1);
        % text = t;
        % Lext = Light;
        % SWext = SW;
        % Cycs = ceil(Tmax/(t(end)-t(1)));
        % for j=1:Cycs-1
        %     %text = [text; t+j*days]; % days internal might not be the right format? unsure
        %     text = [text; t+j*days_input]; % issue if half days
        %     Lext = [Lext; Light];
        %     SWext = [SWext; SW];
        % end
        Tmax = 28; % number of days to simulate
        trange=t(end)-t(1); % Number of days of light data recording
        trange_trunc = floor(trange)+1; % Number of whole days of data
        ind_trunc = find(t<(t(end)+trange_trunc)); % Indices that correspond to truncated range (removing last partial day)- this needs trange+1 to make continuous loops.
        %ind_trunc = find(t>(t(end)-trange_trunc)); % Indices that correspond to truncated range (removing first partial day) % this seems to actually just be cutting the first day.
        t_trunc = t(ind_trunc); % Truncated time values
        L_trunc = Light(ind_trunc); % Truncated light values
        SW_trunc = SW(ind_trunc); % Truncated sleep/wake values

        % Initialize the t, L, and SW variables for export
        text = [];
        Lext = [];
        SWext = [];

        Cycs = ceil(Tmax/trange); % Number of cycles of data needed to hit Tmax
        for j=1:Cycs%-1
            text = [text; t_trunc+(j-1)*trange_trunc];
            Lext = [Lext; L_trunc];
            SWext = [SWext; SW_trunc];
        end

        % % Then add one iteration of the complete recording at the end
        % text = [text; t+j*trange_trunc];
        % Lext = [Lext; Light];
        % SWext = [SWext; SW];
    end
    text = text*24; % if text is datenum then this rescales to be in continuous hours rather than continuous days
    %% Use a light binning method?
    % binit = 0; % 1=yes, 0=no
    % if binit==1
    %     binlength = 15/60; % bin length in hours
    %     bsteps = round(binlength/(text(2)-text(1)));
    %     bins = ceil((text(end)-text(1))/binlength);
    %
    %     Lext_orig = Lext;
    %     for j=1:bins
    %         Lext((j-1)*bsteps+1:j*bsteps) = max(Lext_orig((j-1)*bsteps+1:j*bsteps)); % max value
    %         %Lext((j-1)*bsteps+1:j*bsteps) = mean(Lext_orig((j-1)*bsteps+1:j*bsteps)); % mean value
    %         %Lext((j-1)*bsteps+1:j*bsteps) = median(Lext_orig((j-1)*bsteps+1:j*bsteps)); % median value
    %     end
    % else
    % end

    %tDLMO=20; % default initial DLMO phase - made this a changable input
    tstart = 24*(t(1)-floor(t(1))); % Starting time for simulation in clock time
    phi_i = -(tstart-tDLMO)*2*pi/24 + pi/2 + 2*pi*-170.7/360; % Estimated initial phase, based on reference phase for DLMO

    %V0 = [1,0.2,-0.9];
    if isempty(looped_V0) % if not inputing initialised conditions from baseline looping
        V0 = [0.5,cos(phi_i),sin(phi_i)]; % initial conditions for the model, store output after looping.
    else
        V0 = looped_V0; % use initialised conditions from baseline looping
    end
    t_dt_input = datetime(t,'ConvertFrom','datenum'); % store input t as datetime so cross-check dates after
    t_dt_inputcheck = datetime(text/24, 'ConvertFrom','datenum');
    %% RUN THE SIMULATIONS

    %[th,V] = ode15s(@(text,V)
    %hilaire_de2(text,V,p,text(1),(text(end)-text(1))/(length(text)-1),Lext,SWext),[text(1),text(end)],V0');
    % should it be changed to this when looping?
    [th,V] = ode15s(@(t,V) hilaire_de2(t,V,p,text(1),(text(end)-text(1))/(length(text)-1),Lext,SWext),[text(1),text(end)],V0');
    % % this was orig, but broke when using looping. perhaps this fix is why
    % but CHECK

    % Define the model variables
    n_raw = V(:,1);
    x_raw = V(:,2);
    xc_raw = V(:,3);

    % Store the final conditions of the model to use as initialised version:
    V=V';
    th_mod = mod(th+12, 24)+12;
    text_mod = mod(text+12, 24)+12;
    tolerance = 3/60; %3min tolerance
    idx_match = find(abs(th_mod - text_mod(1)) <= tolerance);
    target = idx_match(end);
    looped_V0 = V(:,target); % last 3 values  - find the last equivalent timepoint, samish clock time as the start

    ts = 0.01; % is this the right timescale to use if the input is datenum at 1min epochs?
    tint = [th(1):ts:th(end)];
    t = tint;
    n = interp1(th,double(n_raw),tint);
    x = interp1(th,double(x_raw),tint);
    xc = interp1(th,double(xc_raw),tint);
    L = interp1(text,double(Lext),tint);
    W = interp1(text,double(Lext),tint);

    % Calculate output
    A = sqrt(xc.^2 + x.^2);
    phi = (atan2(xc,x)); % continuous phase (add as an output)
    phi_XcX = 2*pi*-170.7/360; % reference phase (from St. Hilaire et al. 2007)
    t_ref = 0.97; % time after reference phase for CBT_min

    % Unwrap to estimate observed tau in the model output
    % how often does it go through 2pi of change on avg: that's period. % calculate observed taus.
    phi_u = unwrap(phi); % continuous phase trajectory in radians
    total_phase_change = phi_u(end) - phi_u(1);   % radians
    n_cycles = total_phase_change / (2*pi); % total number of 2pi cycles
    total_time = t(end) - t(1);   % duration in hours
    %cycles_per_hour = n_cycles / total_time; % average cycle rate (period)
    period_h = abs(total_time / n_cycles); % mean period in hours (observed)



    % Find phase
    ps = sign(phi-phi_XcX);
    tcross=t(find(diff(ps)<0)); % find lab times where the reference phase is crossed

    t_cbt = tcross+t_ref; % times of predicted CBTmin in continuous datenum hours (divide by 12 to get into days for a datenum conversion
    t_cbt_dt = datetime(t_cbt/24,'ConvertFrom','datenum'); %mod(t_cbt+12,24)+12;
    tgap = 7.0; % Assumed time difference between CBTmin and DLMO

    t_dlmo = t_cbt-tgap; % Predicted DLMO times to export in continuous hours
    t_dlmo=t_dlmo/24; % convert back to datenum in days
else
    n = NaN;
    x = NaN;
    xc = NaN;
    L = NaN;
    W = NaN;
    t_dlmo = NaN;
    phi = NaN;
    period_h = NaN;
end


