% File: plot_metrics_loglog_with_shade_legend_annotation_logscale.m

% Setup Figure with Compact Layout
figure;
tiledlayout(1, 3, 'Padding', 'tight', 'TileSpacing', 'tight');

% Define Custom Markers and Colors
markerStyles = {'o', 's', 'd', '^', 'v'}; % Markers for each line
lineStyles = {'-', '--', ':', '-.'}; % Line styles for differentiation

% Titles for each plot
ttl = {'Frobenius error', 'Time (s)', 'Number of iterations'};

% Legend labels
legendLabels = {'ratio = 0.2', 'ratio = 0.4', 'ratio = 0.6', 'ratio = 0.8', 'ratio = 1'};

% Loop for Each Metric
for metric = 1:3
    nexttile; hold on; grid on; % Select next tile and prepare plot
    
    % Add Vertical Lines at x = 120 and x = 625
    xline(120, '--k', 'LineWidth', 1.5); % Dashed black line
    xline(625, '-k', 'LineWidth', 1.5);  % Solid black line
    
    % Store handles for the legend
    legendHandles = gobjects(Num_method, 1); % Initialize legend handles
    
    % Plot Each Method
    for t = 1:Num_method
        marker = markerStyles{mod(t-1, length(markerStyles)) + 1}; % Cycle markers
        lineStyle = lineStyles{mod(t-1, length(lineStyles)) + 1}; % Cycle line styles
        
        % Extract Data
        data = squeeze(all_info(t, metric, :, :))'; % Data for this metric and method
        meanVals = zeros(size(data, 2), 1); % Mean values
        stdVals = zeros(size(data, 2), 1); % Std deviation
        
        % Process each point, excluding outliers
        for i = 1:size(data, 2)
            pointData = data(:, i); % Values for this point across samples
            
            % Exclude outliers using 1.5 * IQR rule
            Q1 = quantile(pointData, 0.25);
            Q3 = quantile(pointData, 0.75);
            IQR = Q3 - Q1;
            lowerBound = Q1 - 1.5 * IQR;
            upperBound = Q3 + 1.5 * IQR;
            validData = pointData(pointData >= lowerBound & pointData <= upperBound);
            
            % Calculate Mean and Standard Deviation
            meanVals(i) = mean(validData);
            stdVals(i) = std(validData);
        end
        
        % Plot Mean and store handle for legend
        legendHandles(t) = loglog(all_M, meanVals, ...
            'LineStyle', lineStyle, 'Marker', marker, ...
            'Color', colors(t, :), 'MarkerSize', 6, 'LineWidth', 1.5);
        
        % Plot Shaded Region for 1-STD
        xVals = [all_M, fliplr(all_M)]; % X-axis for shaded area
        yVals = [meanVals - stdVals; flipud(meanVals + stdVals)]; % Y-axis (±1 STD)
        fill(xVals, yVals, colors(t, :), 'FaceAlpha', 0.2, 'EdgeColor', 'none');
    end
    
    % Axis Labels and Title
    xlabel('M_O'); 
    title(ttl{metric}); % Add title for the plot

    % Format Ticks
    ax = gca;
    ax.XScale = 'log';
    ax.YScale = 'log';
    ax.XTick = 10.^(floor(log10(min(all_M))):ceil(log10(max(all_M))));
    ax.YTick = 10.^(floor(log10(min(meanVals - stdVals))):ceil(log10(max(meanVals + stdVals))));

    % Scientific Notation for Ticks
    ax.XAxis.TickLabelFormat = '10^{%g}';
    ax.YAxis.TickLabelFormat = '10^{%g}';

    % Enhanced Grid Style
    ax.GridLineStyle = '--';
    ax.MinorGridLineStyle = ':';
    ax.GridColor = [0.8, 0.8, 0.8]; % Light gray
    ax.MinorGridAlpha = 0.5; % Slight transparency for minor gridlines
    
    % Set x-axis limits
    xlim([min(all_M), max(all_M)]);
    
    % Add Text Labels at Bottom for Vertical Lines (Considering Log Scale)
    ylimVals = ylim; % Get Y-axis limits
    logYMin = log10(ylimVals(1)); % Min y value in log scale
    logYPosition = 10^(logYMin + 0.05*(log10(ylimVals(2)) - logYMin)); % Slightly above the lower bound in log scale
    
    text(120, logYPosition, 'M_O = 120', 'FontSize', 10, ...
        'HorizontalAlignment', 'center'); % Text for M = 120
    text(625, logYPosition, 'M_O = 625', 'FontSize', 10, ...
        'HorizontalAlignment', 'center'); % Text for M = 625
end

% Add Legend (Global for all plots)
lgd = legend(legendHandles, legendLabels, 'Location', 'south', 'Orientation', 'horizontal', 'Box', 'off');
lgd.Layout.Tile = 'south'; % Place legend at the bottom

% Adjust Overall Figure Size and Font
set(gcf, 'Position', [100, 100, 1600, 350]); % Increase height for legend
set(findall(gcf, '-property', 'FontSize'), 'FontSize', 16);

% Tighten Layout
tightfig(gcf);

% Save the Figure
saveas(gcf, 'Sec_5_3_error_decay_sub_set_ratio.pdf');