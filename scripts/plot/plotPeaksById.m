%% Reformat peaks data
peaksData = reformatPeaksData(data);

% Get all unique peak ids
peakIds = {peaksData.match_db_id};
peakIds(cellfun(@(x) isempty(x), peakIds)) = [];
peakIds = unique(peakIds);

peakIndex = 0;

%% Plot peaks
peakIndex = peakIndex + 1;
targetPeakId = peakIds{peakIndex};

% Get all peaks matching the same db_id
peakMatchIndex = find(strcmpi(targetPeakId, {peaksData.match_db_id}));
peakMatch = peaksData(peakMatchIndex);

% Get all samples containing target peak
sampleIndex = unique([peakMatch.sample_index]);

sampleTime = {};
sampleIntensity = {};

plotXMin = NaN;
plotXMax = NaN;

for i = 1:length(sampleIndex)
    sampleTime{end+1,1} = data(sampleIndex(i)).time;
    sampleIntensity{end+1,1} = data(sampleIndex(i)).intensity(:,1);

    if isnan(plotXMin) || min(sampleTime{end,1}) < plotXMin
        plotXMin = min(sampleTime{end,1});
    end

    if isnan(plotXMax) || max(sampleTime{end,1}) > plotXMax
        plotXMax = max(sampleTime{end,1});
    end
end

plotXMin = min([peakMatch.xmin]);
plotXMax = max([peakMatch.xmax]);
plotXSpan = plotXMax - plotXMin;
plotXPad = plotXSpan + 5;

plotXMin = plotXMin - plotXPad;
plotXMax = plotXMax + plotXPad;



% Set plot options
options.linewidth = 0.8;
options.ticks.size = [0.007, 0.0075];
options.line.color = [0.22,0.22,0.22];
options.line.width = 1.25;

% Plot TIC for each sample
numPlots = length(sampleIndex);

figure(...
    'units', 'normalized', ...
    'outerposition', [0.05, 0.05, 0.9, 0.9], ...
    'color', 'white');

axesIndex = 0;

axesGap = [0.0, 0.0];
marginVertical = [0.02, 0.02];
marginHorizontal = [0.05, 0.05];

numVertical = length(sampleIndex);
numHorizontal = 1;

axesHeight = (1-sum(marginVertical) - (numVertical-1) * axesGap(1)) / numVertical; 
axesWidth = (1-sum(marginHorizontal) - (numHorizontal-1) * axesGap(2)) / numHorizontal;

axesY = 1 - marginVertical(2) - axesHeight; 

% Create axes
for i = 1:numVertical
    axesX = marginHorizontal(1);
    
    for j = 1:numHorizontal
        axesIndex = axesIndex + 1;

        axesHandle(axesIndex) = axes(...
            'units','normalized', ...
            'position', [axesX, axesY, axesWidth, axesHeight], ...
            'xticklabel', '', ...
            'yticklabel', '', ...
            'color', 'none',...
            'xtick', [], ...
            'yTick', [], ...
            'tickdir', 'none',...
            'ticklength', options.ticks.size,...
            'box', 'on',...
            'xcolor', options.line.color,...
            'ycolor', options.line.color,...
            'linewidth', options.line.width, ...
            'nextplot', 'add');

        axesX = axesX + axesWidth + axesGap(2);
    end

    axesY = axesY - axesHeight - axesGap(1);
end

axesHandle = axesHandle(:);

% Plot data
for i = 1:length(sampleIndex)

    %axes(axesHandle(i));
    
    % Plot TIC
    plot(sampleTime{i,1}, sampleIntensity{i,1}, ...
        'parent', axesHandle(i), ...
        'color', 'black');

    % Plot peak
    peakPlotIndex = find([peakMatch.sample_index] == sampleIndex(i));
    
    plotYMin = 0;
    plotYMax = [];

    for j = 1:length(peakPlotIndex)
        peak = peakMatch(peakPlotIndex(j));
        peakXMin = peak.xmin;
        peakXMax = peak.xmax;
        peakYMin = peak.ymin;

        % Get peak area
        xf = sampleTime{i,1} >= peakXMin & sampleTime{i,1} <= peakXMax;
        xArea = sampleTime{i,1}(xf);
        yArea = sampleIntensity{i,1}(xf);

        % Get ylim from sample
        plotYMax(end+1) = max(yArea) + max(yArea) * 0.10;

        if ~isempty(xArea) && ~isempty(yArea)
            xArea = [xArea(:); flipud([peakXMin; peakXMax])];
            yArea = [yArea(:); flipud([peakYMin; peakYMin])];

            fill(xArea, yArea, [0.00, 0.30, 0.53], ...
                'parent', axesHandle(i), ...
                'facecolor', [0.30, 0.95, 0.30], ...
                'facealpha', 0.3, ...
                'edgecolor', 'none', ...
                'linestyle', 'none');
        end

    end
    
    % Set axes limits
    set(axesHandle(i), 'xlim', [plotXMin, plotXMax]);

    plotYMin = 0;
    %plotYMax = max(sampleIntensity{i,1});
    %plotYPad = (plotYMax-plotYMin) * 0.05;

    set(axesHandle(i), 'ylim', [plotYMin, max(plotYMax) * 1.05]);
  
end