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

% Get target peak
peakIndex = peakIndex + 1;
targetPeakId = peakIds{peakIndex,1};

% Get all peaks matching the same db_id
peakMatchIndex = find(strcmpi(targetPeakId, {peaksData.match_db_id}));
peakMatch = peaksData(peakMatchIndex);

options.plotAllSamples = true;
options.plotMassSpectra = true;

options.figureWidth = 0.6;
options.figureHeight = 0.8;
options.figurePosition = [(1-options.figureWidth)/2, (1-options.figureHeight)/2, options.figureWidth, options.figureHeight];

options.xSpan = 6;

options.linewidth = 0.8;

options.ticks.size = [0.0025, 0.0025];
options.ticks.xticks.format = {'%.1f', '%d'};

options.line.color = [0.22, 0.22, 0.22];
options.line.width = 1.25;
options.line.style = 'none';

options.bar.width = 7;
options.bar.color = [0,0,0];

options.font.size = 10;
options.font.name = getDefaultFont();
options.font.color = [0, 0, 0];

options.padding = 0.05;
options.yPadding = 0.15;

options.spectrum.xlimits = getMassSpectraXLimits(peakMatch);
options.spectrum.ylimits = [-0.05, 1.15];
options.spectrum.showScore = true;

options.axesPlot = {};
options.axesEmpty = {};
options.sampleText = [];


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
plotXPad = options.xSpan / 2;

plotXMin = plotXMin - plotXPad;
plotXMax = plotXMax + plotXPad;

if plotXMin < min(sampleXMin)
    plotXMin = min(sampleXMin) - 0.1;
end

if plotXMax > max(sampleXMax)
    plotXMax = max(sampleXMax) + 0.1;
end

% Plot TIC for each sample
options.figure = figure(...
    'units', 'normalized', ...
    'outerposition', options.figurePosition, ...
    'color', 'white');

axesGap = [0.0, 0.02];
marginVertical = [0.1, 0.025];
marginHorizontal = [0.04, 0.04];

numVertical = length(sampleIndex);

if options.plotMassSpectra
    numHorizontal = 2;
    axesWidth = [(1-sum(marginHorizontal)-axesGap(2)) * 0.7, (1-sum(marginHorizontal)-axesGap(2)) * 0.3];
else
    numHorizontal = 1;
    axesWidth = (1-sum(marginHorizontal) - (numHorizontal-1) * axesGap(2)) / numHorizontal;
end

axesHeight = (1-sum(marginVertical) - (numVertical-1) * axesGap(1)) / numVertical; 
axesY = 1 - marginVertical(2) - axesHeight; 

% Create axes
for i = 1:numVertical
    axesX = marginHorizontal(1);
    
    for j = 1:numHorizontal
        
        % Create chromatogram axes
        if j == 1
            options.axesPlot{i,1} = axes(...
                'parent', options.figure, ...
                'units', 'normalized', ...
                'position', [axesX, axesY, axesWidth(j), axesHeight], ...
                'fontsize', options.font.size, ...
                'xticklabel', '', ...
                'yticklabel', '', ...
                'color', 'none',...
                'xtick', [], ...
                'ytick', [], ...
                'tickdir', 'in',...
                'ticklength', options.ticks.size,...
                'box', 'off',...
                'xcolor', options.line.color,...
                'ycolor', options.line.color,...
                'linewidth', options.line.width, ...
                'nextplot', 'add');
    
            if i == numVertical
                xticks('auto');
                xticklabels('auto');
                xtickformat(options.ticks.xticks.format{1});
                set(options.axesPlot{i,1}, 'xminortick', 'on');
                set(options.axesPlot{i,1}, 'tickdir', 'out');
                set(options.axesPlot{i,1}, 'box', 'off');
            end

        % Create mass spectra axes
        elseif j == 2
            options.axesPlot{i,2} = axes(...
                'parent', options.figure, ...
                'units', 'normalized', ...
                'position', [axesX, axesY, axesWidth(j), axesHeight], ...
                'fontsize', options.font.size, ...
                'xticklabel', '', ...
                'yticklabel', '', ...
                'color', 'none',...
                'xtick', [], ...
                'ytick', [], ...
                'tickdir', 'in',...
                'ticklength', options.ticks.size,...
                'box', 'on',...
                'xcolor', options.line.color,...
                'ycolor', options.line.color,...
                'linewidth', options.line.width, ...
                'nextplot', 'add');

            if i == numVertical
                xticks('auto');
                xticklabels('auto');
                xtickformat(options.ticks.xticks.format{2});
                set(options.axesPlot{i,2}, 'xminortick', 'on');
                set(options.axesPlot{i,2}, 'tickdir', 'out');
                set(options.axesPlot{i,2}, 'box', 'off');
            end

        end

        axesX = axesX + axesWidth(1) + axesGap(2);
    end

    axesY = axesY - axesHeight - axesGap(1);
end

% Create box around all axes using empty axes
maxAxesPosition = get(options.axesPlot{1,1}, 'position');
minAxesPosition = get(options.axesPlot{end,1}, 'position');
emptyAxesPosition = [minAxesPosition(1), minAxesPosition(2), minAxesPosition(3), maxAxesPosition(2) + maxAxesPosition(4) - minAxesPosition(2)];

options.axesEmpty{1} = axes(...
    'parent', options.figure,...
    'box', 'on',...
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
align([options.axesPlot{end,1}, options.axesEmpty{1}], 'verticalalignment', 'bottom');
align([options.axesPlot{:,1}, options.axesEmpty{1}], 'horizontalalignment', 'left');
linkaxes([options.axesPlot{:,1}, options.axesEmpty{1}], 'x');

% Prevent axes overlap
for i = 1:length(options.axesPlot(:,1))
    set(get(get(options.axesPlot{i,1}, 'yruler'), 'axle'), 'visible', 'off');
    set(get(get(options.axesPlot{i,1}, 'xruler'), 'axle'), 'visible', 'off');
    set(get(get(options.axesPlot{i,1}, 'ybaseline'), 'axle'), 'visible', 'off');
end

if options.plotMassSpectra
    maxAxesPosition = get(options.axesPlot{1,2}, 'position');
    minAxesPosition = get(options.axesPlot{end,2}, 'position');
    emptyAxesPosition = [minAxesPosition(1), minAxesPosition(2), minAxesPosition(3), maxAxesPosition(2) + maxAxesPosition(4) - minAxesPosition(2)];
    
    options.axesEmpty{2} = axes(...
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
    align([options.axesPlot{end,2}, options.axesEmpty{2}], 'verticalalignment', 'bottom');
    align([options.axesPlot{:,2}, options.axesEmpty{2}], 'horizontalalignment', 'left');
    linkaxes([options.axesPlot{:,2}, options.axesEmpty{2}], 'x');
    
    % Prevent axes overlap
    for i = 1:length(options.axesPlot(:,1))
        set(get(get(options.axesPlot{i,2}, 'yruler'), 'axle'), 'visible', 'off');
        set(get(get(options.axesPlot{i,2}, 'xruler'), 'axle'), 'visible', 'off');
        set(get(get(options.axesPlot{i,2}, 'ybaseline'), 'axle'), 'visible', 'off');
    end
end

% Plot data
for i = 1:length(sampleIndex)

    % Set sample variables
    isReferenceSample = false;
    
    % Plot TIC
    plot(sampleTime{i,1}, sampleIntensity{i,1}, ...
        'parent', options.axesPlot{i,1}, ...
        'color', 'black');

    % Plot peak
    peakPlotIndex = find([peakMatch.sample_index] == sampleIndex(i));
    
    plotYMin = [];
    plotYMax = [];
    plotYPad = [];

    for j = 1:length(peakPlotIndex)

        % Set peak variables
        isTopMatchFromSample = true;

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
        
        % Only show best peak from each sample in green
        if length(peakPlotIndex) > 1 && peak.match_score ~= max([peakMatch(peakPlotIndex).match_score])
            isTopMatchFromSample = false;
            peakFillColor = [0.4, 0.4, 0.4];
        end

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
                'parent', options.axesPlot{i,1}, ...
                'facecolor', peakFillColor, ...
                'facealpha', 0.3, ...
                'edgecolor', 'none', ...
                'linestyle', 'none');

            % Peak retention time marker
            peakX = peak.time;
            peakY = peak.height + peak.ymin;

            plot(peakX, peakY, '.', ...
                'parent', options.axesPlot{i,1}, ...
                'color', 'red', ...
                'markersize', 5);

            if options.plotMassSpectra && isempty(options.axesPlot{i,2}.Children) && isTopMatchFromSample

                % Plot mass spectra of peak
                [plotMz, plotIntensity] = addZeroPadding(peak.mz, peak.intensity, options.spectrum.xlimits, 0.1);
                
                bar(plotMz, plotIntensity,...
                    'parent', options.axesPlot{i,2},...
                    'barwidth', options.bar.width, ...
                    'linestyle', options.line.style,...
                    'edgecolor', options.bar.color, ...
                    'facecolor', options.bar.color);

                % Show match score
                if options.spectrum.showScore
                    
                    if isReferenceSample
                        peakText = 'REFERENCE';
                    else
                        peakText = num2str(peak.match_score, '%.2f');
                    end
                    
                    peakTextX = options.spectrum.xlimits(end) - diff(options.spectrum.xlimits) * 0.00;
                    peakTextY = options.spectrum.ylimits(end) - diff(options.spectrum.ylimits) * 0.03;
    
                    text(peakTextX, peakTextY, peakText, ...
                        'parent', options.axesPlot{i,2}, ...
                        'horizontalalignment', 'right', ... 
                        'verticalalignment', 'top', ...
                        'color', options.font.color, ...
                        'clipping', 'on', ...
                        'fontsize', 9);
                end
            end
        end

    end

    if isempty(plotYPad)
        sampleTimeFilter = sampleTime{i,1} >= plotXMin & sampleTime{i,1} <= plotXMax;
        plotYPad = (max(sampleIntensity{i,1}(sampleTimeFilter)) - min(sampleIntensity{i,1}(sampleTimeFilter))) * options.yPadding;
    end

    if ~any(sampleTimeFilter)
        plotYPad = 0;
        plotYMin(end+1) = 0;
        plotYMax(end+1) = 1;
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

    set(options.axesPlot{i,1}, 'xlim', [plotXMin, plotXMax]);
    set(options.axesPlot{i,1}, 'ylim', [plotYMin, plotYMax]);

    if options.plotMassSpectra
        set(options.axesPlot{i,2}, 'xlim', options.spectrum.xlimits);
        set(options.axesPlot{i,2}, 'ylim', options.spectrum.ylimits);
    end

    % Set sample name text
    sampleName = strrep(data(sampleIndex(i)).sample_name, '%', '');
    sampleName = strrep(sampleName, '_', '\_');

    if isReferenceSample
        sampleName = [sampleName, ' (REFERENCE)'];
    end

    options.sampleText(end+1,1) = text(...
        plotXMin + plotXPad * 0.05, (max(plotYMax)+min(plotYMin))/2, sampleName,...
        'parent', options.axesPlot{i,1},...
        'horizontalalignment', 'left',...
        'verticalalignment', 'middle',...
        'clipping', 'on',...
        'fontsize', options.font.size,...
        'fontname', options.font.name);
end

% Set x-label for chromatogram plot
options.xLabel = xlabel(...
    'Time (min)',...
    'parent', options.axesPlot{end,1}, ...
    'fontname', options.font.name,...
    'fontsize', options.font.size,...
    'units', 'normalized');

% Set x-label for mass spectra plot
if options.plotMassSpectra
    options.xlabel = xlabel(...
        'Mass (m/z)',...
        'parent', options.axesPlot{end,2}, ...
        'fontname', options.font.name,...
        'fontsize', options.font.size,...
        'units', 'normalized');
end

% -----------------------------------------
% Get default font name
% -----------------------------------------
function defaultFont = getDefaultFont()

% Default font
defaultFont = 'Avenir Next';

% Determine available fonts
fonts = listfonts;

% Check for valid font
if ~any(strcmpi(fonts, defaultFont))
    if any(strcmpi(fonts, 'Avenir Next'))
        defaultFont = 'Avenir Next';
    elseif any(strcmpi(fonts, 'Lucida Sans'))
        defaultFont = 'Lucida Sans';
    elseif any(strcmpi(fonts, 'Helvetica Neue'))
        defaultFont = 'Helvetica Neue';
    elseif any(strcmpi(fonts, 'Century Gothic'))
        defaultFont = 'Century Gothic';
    else
        defaultFont = 'Arial';
    end
end

end

% -----------------------------------------
% Get mass spectra x-limits
% -----------------------------------------
function xLimits = getMassSpectraXLimits(peaks)

xLimits = [];

if isempty(peaks)
    return
end

mzMin = min([peaks.mz]);
mzMax = max([peaks.mz]);

xLimits(1) = mzMin - mod(mzMin, 10);
xLimits(2) = mzMax + (10 - mod(mzMax, 10));

if diff(xLimits) < 200
    xLimits(2) = xLimits(2) + 200 - diff(xLimits);
end

end

% -----------------------------------------
% Format mass spectra data
% -----------------------------------------
function [mz, y] = addZeroPadding(mz, y, mzRange, mzStep)

% Get average distance between mz points
if mean(diff(mz)) < 1 && length(mz) >= 100
    return
end

if isempty(mzRange)
    minMz = mz(1);
    maxMz = mz(end);
else
    minMz = min([mz(1), mzRange(1)]);
    maxMz = max([mz(end), mzRange(2)]);
end

mz0 = [];
y0 = [];
idx = 1;

% Fill in resampled arrays with zeros
for i = minMz:mzStep:maxMz
   
    if idx > length(mz) || i < mz(idx)
        mz0(end+1) = i;
        y0(end+1) = 0;
    end

    while idx <= length(mz) && i >= mz(idx)
        mz0(end+1) = mz(idx);
        y0(end+1) = y(idx);
        idx = idx + 1;
    end
end

mz = mz0;
y = y0;

end
