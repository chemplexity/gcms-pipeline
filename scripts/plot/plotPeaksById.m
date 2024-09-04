%% Reformat peaks data
peaksData = reformatPeaksData(data);

% Get all unique peak ids
peakIds = {peaksData.match_db_id};
peakIds(cellfun(@(x) isempty(x), peakIds)) = [];
peakIds = unique(peakIds)';

for i = 1:length(peakIds)
    peakIds{i,2} = sum(strcmpi(peakIds{i}, {peaksData.match_db_id}));
end

[~, idx] = sort([peakIds{:,2}], 'descend');
peakIds = peakIds(idx,:);

peakIndex = 0;

%% Set plot options
options.plotAllSamples = true;
options.figureWidth = 0.6;
options.figureHeight = 0.8;
options.figurePosition = [(1-options.figureWidth)/2, (1-options.figureHeight)/2, options.figureWidth, options.figureHeight];
options.xSpan = 6;
options.linewidth = 0.8;
options.ticks.size = [0.0025, 0.0025];
options.line.color = [0.22, 0.22, 0.22];
options.line.width = 1.25;
options.font.size = 10;
options.font.name = 'Avenir Next';
options.font.color = [0, 0, 0];
options.padding = 0.05;
options.yPadding = 0.15;

options.axes = [];
options.sampleText = [];

% Get target peak
peakIndex = peakIndex + 1;
targetPeakId = peakIds{peakIndex,1};

% Get all peaks matching the same db_id
peakMatchIndex = find(strcmpi(targetPeakId, {peaksData.match_db_id}));
peakMatch = peaksData(peakMatchIndex);

% Get all samples containing target peak
if options.plotAllSamples
    sampleIndex = unique([peaksData.sample_index]);
else
    sampleIndex = unique([peakMatch.sample_index]);
end

sampleTime = {};
sampleIntensity = {};

sampleXMin = [];
sampleXMax = [];

for i = 1:length(sampleIndex)
    sampleTime{end+1,1} = data(sampleIndex(i)).time;
    sampleIntensity{end+1,1} = data(sampleIndex(i)).intensity(:,1);

    sampleXMin(end+1) = min(sampleTime{end,1});
    sampleXMax(end+1) = max(sampleTime{end,1});
end

plotXMin = min([peakMatch.xmin]);
plotXMax = max([peakMatch.xmax]);
plotXPad = (plotXMax - plotXMin) + options.xSpan / 2;

plotXMin = plotXMin - plotXPad;
plotXMax = plotXMax + plotXPad;

if plotXMin < min(sampleXMin)
    plotXMin = min(sampleXMin) - 0.1;
end

if plotXMax > max(sampleXMax)
    plotXMax = max(sampleXMax) + 0.1;
end

% Determine available fonts
fonts = listfonts;

% Check for valid font
if ~any(strcmp(fonts, options.font.name))
    if any(strcmp(fonts, 'Avenir Next'))
        options.font.name = 'Avenir Next';
    elseif any(strcmp(fonts, 'Lucida Sans'))
        options.font.name = 'Lucida Sans';
    elseif any(strcmp(fonts, 'Helvetica Neue'))
        options.font.name = 'Helvetica Neue';
    elseif any(strcmp(fonts, 'Century Gothic'))
        options.font.name = 'Century Gothic';
    else
        options.font.name = 'Arial';
    end
end

% Plot TIC for each sample
numPlots = length(sampleIndex);

options.figure = figure(...
    'units', 'normalized', ...
    'outerposition', options.figurePosition, ...
    'color', 'white');

axesIndex = 0;
axesGap = [0.0, 0.0];
marginVertical = [0.075, 0.025];
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

        options.axes(axesIndex) = axes(...
            'parent', options.figure, ...
            'units','normalized', ...
            'position', [axesX, axesY, axesWidth, axesHeight], ...
            'fontsize', options.font.size, ...
            'xticklabel', '', ...
            'yticklabel', '', ...
            'color', 'none',...
            'xtick', [], ...
            'ytick', [], ...
            'tickdir', 'none',...
            'ticklength', options.ticks.size,...
            'box', 'off',...
            'xcolor', options.line.color,...
            'ycolor', options.line.color,...
            'linewidth', options.line.width, ...
            'nextplot', 'add');

        if i == numVertical
            xticks('auto');
            xticklabels('auto');
            xtickformat('%.1f');
            set(options.axes(axesIndex), 'xminortick', 'on');
            set(options.axes(axesIndex), 'tickdir', 'out');
            set(options.axes(axesIndex), 'box', 'off');
        end

        axesX = axesX + axesWidth + axesGap(2);
    end

    axesY = axesY - axesHeight - axesGap(1);
end

options.axes = options.axes(:);

% Create box around all axes using empty axes
maxAxesPosition = get(options.axes(1), 'position');
minAxesPosition = get(options.axes(end), 'position');
emptyAxesPosition = [minAxesPosition(1), minAxesPosition(2), minAxesPosition(3), maxAxesPosition(2) + maxAxesPosition(4) - minAxesPosition(2)];

options.empty = axes(...
    'parent', options.figure,...
    'box','on',...
    'units', 'normalized',...
    'linewidth', options.line.width,...
    'color', 'none',...
    'layer', 'bottom',...
    'xcolor', options.line.color,...
    'ycolor', options.line.color,...
    'looseinset', [0.075,0.12,0.05,0.05],...
    'xtick', [],...
    'ytick', [],...
    'layer', 'bottom',...
    'selectionhighlight', 'off',...
    'position', emptyAxesPosition + [-0.003, 0, 0.006, 0]);

% Align axes edges
align([options.axes(end), options.empty], 'verticalalignment', 'bottom');
align([options.axes; options.empty], 'horizontalalignment', 'left');
linkaxes([options.axes; options.empty],'x');

% Prevent axes overlap
for i = 1:length(options.axes)
    set(get(get(options.axes(i), 'yruler'),'axle'), 'visible', 'off');
    set(get(get(options.axes(i), 'xruler'),'axle'), 'visible', 'off');
    set(get(get(options.axes(i), 'ybaseline'),'axle'), 'visible', 'off');
end

% Plot data
for i = 1:length(sampleIndex)

    % Set variables
    isReferenceSample = false;

    % Plot TIC
    plot(sampleTime{i,1}, sampleIntensity{i,1}, ...
        'parent', options.axes(i), ...
        'color', 'black');

    % Plot peak
    peakPlotIndex = find([peakMatch.sample_index] == sampleIndex(i));
    
    plotYMin = [];
    plotYMax = [];
    plotYPad = [];

    for j = 1:length(peakPlotIndex)
        peak = peakMatch(peakPlotIndex(j));
        peakXMin = peak.xmin;
        peakXMax = peak.xmax;
        peakYMin = peak.ymin;

        % Get peak area
        peakTimeFilter = sampleTime{i,1} >= peakXMin & sampleTime{i,1} <= peakXMax;
        xArea = sampleTime{i,1}(peakTimeFilter);
        yArea = sampleIntensity{i,1}(peakTimeFilter);

        % Get ylim from sample
        sampleTimeFilter = sampleTime{i,1} >= plotXMin & sampleTime{i,1} <= plotXMax;
        plotYPad = (max(yArea) - min([sampleIntensity{i,1}(sampleTimeFilter); peakYMin])) * options.yPadding;
        plotYMin(end+1) = min([sampleIntensity{i,1}(sampleTimeFilter); peakYMin]) - plotYPad;
        plotYMax(end+1) = max(yArea) + plotYPad;

        % Check if peak is reference peak
        peakFillColor = [0.30, 0.95, 0.30];
        peakMatchChecksum = regexp(peak.match_comments, '(?:FileChecksum[:]\W)(\w*)', 'match');
        
        if ~isempty(peakMatchChecksum)
            peakMatchChecksum = strsplit(peakMatchChecksum{1}, ': ');
            peakMatchChecksum = peakMatchChecksum{end};

            if strcmpi(peakMatchChecksum, peak.file_checksum)
                peakFillColor = [0.00, 0.30, 0.53];
                isReferenceSample = true;            
            end
        end

        % Plot peak area and marker for retention time
        if ~isempty(xArea) && ~isempty(yArea)
            xArea = [xArea(:); flipud([peakXMin; peakXMax])];
            yArea = [yArea(:); flipud([peakYMin; peakYMin])];

            % Peak area
            fill(xArea, yArea, [0.00, 0.30, 0.53], ...
                'parent', options.axes(i), ...
                'facecolor', peakFillColor, ...
                'facealpha', 0.3, ...
                'edgecolor', 'none', ...
                'linestyle', 'none');

            % Peak retention time marker
            peakX = peak.time;
            peakY = peak.height + peak.ymin;

            plot(peakX, peakY, '.', ...
                'parent', options.axes(i), ...
                'color', 'red', ...
                'markersize', 5);

            % % Peak score text
            % peakText = num2str(peak.match_score, '%.1f');
            % peakTextX = peakX;
            % peakTextY = peakY + plotYPad * 0.5;
            % 
            % peakLabel = text(...
            %     peakTextX, peakTextY, peakText, ...
            %     'parent', options.axes(i), ...
            %     'horizontalalignment', 'left', ... 
            %     'verticalalignment', 'middle', ...
            %     'color', options.font.color, ...
            %     'clipping', 'on', ...
            %     'fontsize', 8);
            % 
            % peakLabel.Rotation = 90;
            % 
            % % Check if text is outside axes
            % if peakLabel.Extent(2) + peakLabel.Extent(4) > max(plotYMax)
            %     plotYMax(end+1) = peakLabel.Extent(2) + peakLabel.Extent(4);
            % end
        end

    end

    if isempty(plotYPad)
        sampleTimeFilter = sampleTime{i,1} >= plotXMin & sampleTime{i,1} <= plotXMax;
        plotYPad = (max(sampleIntensity{i,1}(sampleTimeFilter)) - min(sampleIntensity{i,1}(sampleTimeFilter))) * options.yPadding;
    end

    if isempty(plotYMin)
        plotYMin(end+1) = min(sampleIntensity{i,1}(sampleTimeFilter)) - plotYPad;
    end

    if isempty(plotYMax)
        plotYMax(end+1) = max(sampleIntensity{i,1}(sampleTimeFilter)) + plotYPad;
    end

    % Set axes limits
    plotYMin = min(plotYMin);
    plotYMax = max(plotYMax);
    plotYPad = (plotYMax - plotYMin) * options.padding;
    plotXPad = (plotXMax - plotXMin) * options.padding;

    set(options.axes(i), 'xlim', [plotXMin, plotXMax]);
    set(options.axes(i), 'ylim', [plotYMin, plotYMax]);

    % Set sample name text
    sampleName = strrep(data(sampleIndex(i)).sample_name, '%', '');
    sampleName = strrep(sampleName, '_', '\_');

    if isReferenceSample
        sampleName = [sampleName, ' (REFERENCE)'];
    end

    options.sampleText(end+1) = text(...
        plotXMin + plotXPad * 0.05, (max(plotYMax)+min(plotYMin))/2, sampleName,...
        'parent', options.axes(i),...
        'horizontalalignment', 'left',...
        'verticalalignment', 'middle',...
        'clipping', 'on',...
        'fontsize', options.font.size,...
        'fontname', options.font.name);
end