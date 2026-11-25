%% Raster plotting function, which can overlay multiple rasters (e.g., sleep, light).
% AJK Phillips 5/2020
%
% raster_deluxe(r), where X is a vector of switching times, will make a
% raster plot for one variable (e.g., sleep). By default, times are assumed
% to be in decimal hours (12 = noon on day 1, 36 = noon on day 2)
% raster_deluxe(r) where r(1).x, r(2).x, ... r(N).x are each 
% vectors of switching times (can be different lengths), will make a raster 
% plot for N variables. These will be overlayed.
%
% Optionally can also include marker times (e.g., CBT min) as a vector
% stored in r(1).M. Markers will be plotted as circles.
%
% Optionally can also include a time series (e.g., activity, light) as a
% 2xN matrix stored in r(1).TS, where first column is time, second column
% are values. A trace will be plotted over the raster plot.
%
% raster_deluxe(r,C) can be used to manually specify colors. C should be
% Nx3 matrix, with each row corresponding to RGB for the variable.
% raster_deluxe(r,d) can be used to manually specify the number of times 
% repeat the raster across the x-axis. Default is d=2 (double-plotting).
% Values of 1-4 are supported.
% raster_deluxe(r,T) can be used to specify the T-cycle (day-length) for
% raster plotting. Default is 24 hours. Values >6 are supported.
% 
% Combinations of inputs are permitted, e.g., raster_deluxe(r,C,T)
%
% --------
%Example: 
% r(1).X = [0,8,24,32,49,56,70,77,95,103,109,112,120,127,140,151];
% r(2).X = [21,22,30,31,42,44,45,47,66,69.5];
% r(3).X = [19,20,26,28,40,43,90,94];
% r(1).M = [4,29,51,75.5,102,125]; % will be blue
% r(2).M = [4,29,51,75.5,102,125]; % will be aqua
% raster_deluxe(r,1)
% This will double plot three types of data (X), along with marker values (M).

% R(1).X = Stimev;
% R(1).TS = light_ts;
% raster_deluxe(R,1)

function hFig= raster_deluxe(R,p,plot_title,i1,i2,i3)

% Optional: when 5th arg is an axes handle, plot into it (for subplots).
    parent_ax = [];
    if nargin >= 5 && exist('i2','var')
        maybe_ax = i2;
        if numel(maybe_ax)==1 && isgraphics(maybe_ax,'axes')
            parent_ax = maybe_ax; i2 = [];
        end
    end

% Standard colors to assign (sleep = darker grey)
    C = [0.15,0.15,0.15;
        0,1,0;
        0,0,1;
        1,0,0;
        1,0,1;
        0,1,1;
        0.7,0.5,0.2;
        rand(10,3)];
    
    T = 24;
    d = 2;

if nargin==1 % If the only input is the data, then use default values

    % Set colors
else % If there are multiple inputs, look for a color input
    
%    L = [length(i2),length(i3),length(i4)];
%     if max(L)>1 % Check if there is a color input
%         ind=find(L>1);
    if exist('i3','var')
        if length(i3)>1
            C = i3;
        elseif length(i2)>1
            C = i2;
        elseif length(i1)>1
            C = i1;
        else
        end
    elseif exist('i2','var')
        if length(i2)>1
            C = i2;
        elseif length(i1)>1
            C = i1;
        else
        end
    else
        if length(i1)>1
            C = i1;
        else
        end
    end

    
    % Set number of times to duplicate x-axis
    if exist('i3','var')
        if i3<6
            d = i3;
        elseif i2<6
            d = i2;
        elseif i1<6
            d = i1;
        else
        end
    elseif exist('i2','var')
        if i2<6
            d = i2;
        elseif i1<6
            d = i1;
        else
        end
    else
        if i1<6
            d = i1;
        else
        end
    end
    
    
    % Set T-cycle (day length)
    if exist('i3','var')
        if i3>=6
            T = i3;
        elseif i2>=6
            T = i2;
        elseif i1>=6
            T = i1;
        else
        end
    elseif exist('i2','var')
        if i2>=6
            T = i2;
        elseif i1>=6
            T = i1;
        else
        end
    else
        if i1>=6
            T = i1;
        else
        end
    end
       
    N = length(R); % Number of signals
    
    mt = []; % Initialize max times (sleep timelines only; marker-only entries omit .X)
    for i=1:N % Iterate over signals
        if isfield(R(i), 'X') && ~isempty(R(i).X)
            mt(end+1,1) = max(R(i).X(:)); %#ok<AGROW>
        end
    end
    if isempty(mt)
        error('raster_deluxe_cursor:NoTimeline', 'R(1).X (sleep) must be nonempty.');
    end
    Dmax = ceil(max(mt)/T)+1;
    
    %% Make raster plot
    if ~isempty(parent_ax)
        fig = ancestor(parent_ax, 'figure');
        if isempty(fig) || ~isgraphics(fig,'figure')
            fig = gcf;
        end
        figure(fig);
        axes(parent_ax);
        hold on
        hFig = fig;
    else
        hFig = figure(p);
    end
    dw = 0.3; % Half-width of raster bars
    for i=1:d-1
        plot(i*T+[0,0],[0,Dmax],'LineWidth',1,'Color',[0.6,0.6,0.6])
        hold on
    end
    for i=1:N % Iterate over signals to plot raster

        if ~isfield(R(i), 'X') || isempty(R(i).X)
            continue
        end
        for j=1:floor(length(R(i).X)/2) % Iterate over on/off pairs
            ton = R(i).X(2*j-1); % onset time
            toff = R(i).X(2*j); % offset time
            D = floor(ton/T); % Day number
            for k=-4:d+3 % make patches multiple times
                patch([ton,ton,toff,toff]-D*T-T*(k-1),D+1+[-1,1,1,-1]*dw+(k-1),C(i,:),'LineStyle','none')
                hold on
            end
        end
    end
    
    alpha(0.5)
    
    % Light blocks: 1=0-100, 2=>100. NaN = blank.
    % Match treatment raster colours: band 1 (lower light) orange, band 2 (higher light) yellow.
    C_light = [1.0, 0.7, 0.25; 1.0, 0.92, 0.55];
    dw_light = 0.25;
    if isfield(R(1),'LightBlocks') && size(R(1).LightBlocks,2) >= 3 && size(R(1).LightBlocks,1) > 0
        BL = R(1).LightBlocks;
        ncopies = d + 7; % k from -4 to d+3
        nblock = size(BL,1);
        nface = nblock * ncopies;
        V = zeros(nface * 4, 2);
        F = zeros(nface, 4);
        C = zeros(nface * 4, 3);
        nv = 0;
        for ib = 1:nblock
            t_start = BL(ib,1); t_end = BL(ib,2); b = BL(ib,3);
            D = floor(t_start/T);
            cb = C_light(b,:);
            for kk = -4:d+3
                xp = [t_start, t_start, t_end, t_end] - D*T - T*(kk-1);
                yp = D + 1 + (kk-1) + [-1,1,1,-1]*dw_light;
                idx = nv+1:nv+4;
                V(idx,:) = [xp', yp'];
                F(nv/4+1,:) = idx;
                C(idx,:) = repmat(cb, 4, 1);
                nv = nv + 4;
            end
        end
        patch('Faces', F, 'Vertices', V, 'FaceVertexCData', C, 'FaceColor', 'flat', 'EdgeColor', 'none', 'FaceAlpha', 0.85);
        hold on
    elseif isfield(R(1),'Light') && size(R(1).Light,2) >= 2
        light_t = R(1).Light(:,1);
        light_lux = R(1).Light(:,2);
        nwake = floor((length(R(1).X)-1)/2);
        for j = 1:nwake
            toff = R(1).X(2*j);
            ton  = R(1).X(2*j+1);
            if ton <= toff, continue; end
            idx = light_t >= toff & light_t <= ton & ~isnan(light_lux);
            if ~any(idx), continue; end
            t_seg = light_t(idx);
            lux_seg = light_lux(idx);
            [t_seg, ord] = sort(t_seg);
            lux_seg = lux_seg(ord);
            band = ones(size(lux_seg));
            band(lux_seg > 100) = 2;
            k = 1;
            blocks = [];
            while k <= length(t_seg)
                b = band(k);
                t_start = t_seg(k);
                while k < length(t_seg) && band(k+1) == b
                    k = k + 1;
                end
                t_end = t_seg(k);
                blocks = [blocks; t_start, t_end, b];
                k = k + 1;
            end
            for ib = 1:size(blocks,1)
                t_start = blocks(ib,1); t_end = blocks(ib,2); b = blocks(ib,3);
                D = floor(t_start/T);
                for kk = -4:d+3
                    xp = [t_start, t_start, t_end, t_end] - D*T - T*(kk-1);
                    yp = D + 1 + (kk-1) + [-1,1,1,-1]*dw_light;
                    patch(xp, yp, C_light(b,:), 'LineStyle', 'none', 'FaceAlpha', 0.85)
                    hold on
                end
            end
        end
    end
    
    if isfield(R(1),'M') % Check if there are markers (aMT6s acrophase: filled blue circle by default)
        mk1 = 'o';
        mcol1 = [0 0 1];
        mfc1 = mcol1;
        msz1 = 6;
        mlw1 = 1;
        if isfield(R(1),'Marker'), mk1 = R(1).Marker; end
        if isfield(R(1),'MarkerColor'), mcol1 = R(1).MarkerColor; end
        if isfield(R(1),'MarkerFaceColor'), mfc1 = R(1).MarkerFaceColor; else, mfc1 = mcol1; end
        if isfield(R(1),'MarkerSize'), msz1 = R(1).MarkerSize; end
        if isfield(R(1),'MarkerLineWidth'), mlw1 = R(1).MarkerLineWidth; end
        for j=1:length(R(1).M)
            D = floor(R(1).M(j)/T); % Day number
            for k=-4:d+3 % make markers multiple times
            plot(R(1).M(j)-D*T-T*(k-1),D+1+(k-1), mk1, 'Color', mcol1, 'MarkerFaceColor', mfc1, 'MarkerSize', msz1, 'LineWidth', mlw1)
            end
        end
    else 
    end

    % Additional marker series (e.g., multiple CBTmin predictions)
    % Backwards compatible: prior behavior was to plot only R(2).M if present.
    for ii = 2:N
        if ~isfield(R(ii),'M') || isempty(R(ii).M)
            continue
        end
        % Defaults
        if ii == 2
            mk = 'd';
            mcol = [106 61 154]/255; % dark purple #6A3D9A
        else
            mk = '+';
            mcol = [0.4 0.4 0.4];
        end
        mfc = mcol;
        msz = 6;
        mlw = 1;
        if isfield(R(ii),'Marker'), mk = R(ii).Marker; end
        if isfield(R(ii),'MarkerColor'), mcol = R(ii).MarkerColor; end
        if isfield(R(ii),'MarkerFaceColor'), mfc = R(ii).MarkerFaceColor; else, mfc = mcol; end
        if isfield(R(ii),'MarkerSize'), msz = R(ii).MarkerSize; end
        if isfield(R(ii),'MarkerLineWidth'), mlw = R(ii).MarkerLineWidth; end

        for j=1:length(R(ii).M)
            D = floor(R(ii).M(j)/T); % Day number
            for k=-4:d+3 % make markers multiple times
                plot(R(ii).M(j)-D*T-T*(k-1),D+1+(k-1), mk, ...
                    'Color', mcol, 'MarkerFaceColor', mfc, 'MarkerSize', msz, 'LineWidth', mlw)
            end
        end
    end
    
    if isfield(R(1),'TS') % Check if there are markers
        for j=1:Dmax
            Y = R(1).TS(:,2);
            Y = (Y-min(Y))/(max(Y)-min(Y)); % Normalize 0-1
            Y = 2*Y-1; % Range -1 to 1
            plot(R(1).TS(:,1)-T*(j-1),(j-1)-Y*0.45,'Color',	[0 0 0],'LineWidth',1)
        end
    else
    end
    
    if isfield(R(1),'TS1') % Check if there are timeseries
        for j=1:Dmax
            Y = R(1).TS1(:,2);
            Y = (Y-min(Y))/(max(Y)-min(Y)); % Normalize 0-1
            Y = 2*Y-1; % Range -1 to 1
            plot(R(1).TS1(:,1)-T*(j-1),(j-1)-Y*0.45,'Color',[1 0 0],'LineWidth',1)
        end
    else
    end
    
    if isfield(R(1),'TS2') % Check if there are timeseries
        for j=1:Dmax
            Y = R(1).TS2(:,2);
            Y = (Y-min(Y))/(max(Y)-min(Y)); % Normalize 0-1
            Y = 2*Y-1; % Range -1 to 1
            plot(R(1).TS2(:,1)-T*(j-1),(j-1)-Y*0.45,'Color',[0 0 1],'LineWidth',1)
        end
    else
    end
    
    if isfield(R(1),'TS3') % Check if there are timeseries
        for j=1:Dmax
            Y = R(1).TS3(:,2);
            Y = (Y-min(Y))/(max(Y)-min(Y)); % Normalize 0-1
            Y = 2*Y-1; % Range -1 to 1
            plot(R(1).TS3(:,1)-T*(j-1),(j-1)-Y*0.45,'Color',[0 1 0],'LineWidth',1)
        end
    else
    end
    
    if isfield(R(1),'TS4') % Check if there are timeseries
        for j=1:Dmax
            Y = R(1).TS4(:,2);
            Y = (Y-min(Y))/(max(Y)-min(Y)); % Normalize 0-1
            Y = 2*Y-1; % Range -1 to 1
            plot(R(1).TS4(:,1)-T*(j-1),(j-1)-Y*0.45,'Color',[0 0 1],'LineWidth',0.5)
        end
    else
    end
    
    xlim([0,T*d])
    ylim([-0.5,Dmax+0.5])
    if T==24
        xlabel('Clock time')
        xticks([0:6:T*d])
        xx = {};
        ct = {'0:00','6:00','12:00','18:00'};
        for j=1:d
            xx = [xx, ct];
        end
        xx = [xx, '0:00'];
        xticklabels(xx)
    else
        xlabel('Time (h)')
    end
    ylabel('Day number')
    
    
     % h_name = [t_name(1).ptID t_name(2).timepoint];
      title(plot_title)
    
    % Legend (with colour matching) when light blocks are plotted
    skipLeg = isfield(R(1), 'SkipBuiltInLegend') && R(1).SkipBuiltInLegend;
    if ~skipLeg && (isfield(R(1),'LightBlocks') || (isfield(R(1),'Light') && size(R(1).Light,2) >= 2))
        C_sleep = [0.15, 0.15, 0.15]; % dark grey, must match sleep patch
        C_light_leg = [1.0, 0.92, 0.55; 1.0, 0.7, 0.25];
        h_leg = [];
        leg_labels = {};
        h_leg(end+1) = patch(NaN, NaN, C_sleep, 'EdgeColor', 'none');
        leg_labels{end+1} = 'Sleep';
        h_leg(end+1) = patch(NaN, NaN, C_light_leg(1,:), 'EdgeColor', 'none');
        leg_labels{end+1} = 'Light 0-100 lux';
        h_leg(end+1) = patch(NaN, NaN, C_light_leg(2,:), 'EdgeColor', 'none');
        leg_labels{end+1} = 'Light >100 lux';
        if isfield(R(1),'M')
            h_leg(end+1) = plot(NaN, NaN, 'o', 'Color', [0 0 1], 'MarkerFaceColor', [0 0 1], 'MarkerSize', 6, 'LineWidth', 1);
            leg_labels{end+1} = 'aMT6s acrophase';
        end
        if isfield(R(2),'M') && ~isempty(R(2).M)
            M2c = [106 61 154]/255; % dark purple #6A3D9A
            M2fc = M2c;
            if isfield(R(2),'MarkerColor'), M2c = R(2).MarkerColor; end
            if isfield(R(2),'MarkerFaceColor'), M2fc = R(2).MarkerFaceColor; else, M2fc = M2c; end
            M2mk = 'd';
            M2sz = 6;
            M2lw = 1;
            if isfield(R(2),'Marker'), M2mk = R(2).Marker; end
            if isfield(R(2),'MarkerSize'), M2sz = R(2).MarkerSize; end
            if isfield(R(2),'MarkerLineWidth'), M2lw = R(2).MarkerLineWidth; end
            h_leg(end+1) = plot(NaN, NaN, M2mk, 'Color', M2c, 'MarkerFaceColor', M2fc, ...
                'MarkerSize', M2sz, 'LineWidth', M2lw);
            if N >= 3 && isfield(R(3),'M') && ~isempty(R(3).M)
                leg_labels{end+1} = 'CBTmin default';
            else
                leg_labels{end+1} = 'Best-fit CBTmin';
            end
        end
        if N >= 3 && isfield(R(3),'M') && ~isempty(R(3).M)
            mk3 = '^'; mc3 = [0 0.42 0.22]; mf3 = [0.2 0.72 0.38]; ms3 = 7; mw3 = 1;
            if isfield(R(3),'Marker'), mk3 = R(3).Marker; end
            if isfield(R(3),'MarkerColor'), mc3 = R(3).MarkerColor; end
            if isfield(R(3),'MarkerFaceColor'), mf3 = R(3).MarkerFaceColor; end
            if isfield(R(3),'MarkerSize'), ms3 = R(3).MarkerSize; end
            if isfield(R(3),'MarkerLineWidth'), mw3 = R(3).MarkerLineWidth; end
            h_leg(end+1) = plot(NaN, NaN, mk3, 'Color', mc3, 'MarkerFaceColor', mf3, ...
                'MarkerSize', ms3, 'LineWidth', mw3);
            leg_labels{end+1} = 'CBTmin best fit';
        end
        legend(h_leg, leg_labels, 'Location', 'northwest');
    end

    hold off
    set(gca, 'YDir','reverse')
    box on
    grid off
    
    
            

end 
end 