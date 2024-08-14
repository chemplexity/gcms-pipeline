function plotChromatogramWithLibraryMatches(data, sampleIndex)

% Get data
sampleTime = data(sampleIndex).time;
sampleIntensity = data(sampleIndex).intensity(:,1);

% Set plot options
options.linewidth = 0.8;
options.ticks.size = [0.007, 0.0075];
options.line.color = [0.22,0.22,0.22];
options.line.width = 1.25;

% Initialize plots
clf;

options.figure = figure(gcf);
set(options.figure, 'units', 'normalized');
set(options.figure, 'color', 'white');

options.axes_plot = axes(...
    'parent', options.figure,...
    'units', 'normalized',...
    'position', [0.075, 0.125, 0.88, 0.80], ...
    'color', 'none',...
    'tickdir', 'out',...
    'ticklength', options.ticks.size,...
    'box', 'off',...
    'xminortick', 'on',...
    'layer', 'top',...
    'xcolor', options.line.color,...
    'ycolor', options.line.color,...
    'linewidth', options.line.width,...
    'looseinset', [0.075,0.12,0.05,0.05],...
    'selectionhighlight', 'off',...
    'nextplot', 'add');

% Plot chromatogram
plot(sampleTime, sampleIntensity, ...
    'parent', options.axes_plot, ...
    'color', 'black', ...
    'linewidth', options.linewidth);

hold all;

% Plot peaks
peaks = data(sampleIndex).peaks;
textPad = (max(data(sampleIndex).intensity(:,1)) - min(data(sampleIndex).intensity(:,1))) * 0.01;

for i = 1:length(peaks)
    xmin = peaks(i).xmin;
    xmax = peaks(i).xmax;
    ymin = peaks(i).ymin;
    
    xf = sampleTime >= xmin & sampleTime <= xmax;
    xArea = sampleTime(xf);
    yArea = sampleIntensity(xf);
    
    if ~isempty(xArea) && ~isempty(yArea)
        xArea = [xArea(:); flipud([xmin; xmax])];
        yArea = [yArea(:); flipud([ymin; ymin])];
    
        if isempty(peaks(i).library_match)
            faceColor = [0.93, 0.30, 0.30];
        else
            faceColor = [0.30, peaks(i).match_score/100, 0.30];
        end

        fill(xArea, yArea, [0.00, 0.30, 0.53],...
            'parent', options.axes_plot, ...
            'facecolor', faceColor,...
            'facealpha', 0.3,...
            'edgecolor', 'none',...
            'linestyle', 'none');
        
        % Plot library match text
        if isempty(peaks(i).library_match)
            continue;
        end

        plot(peaks(i).time, peaks(i).height + peaks(i).ymin, '.', ...
            'parent', options.axes_plot, ...
            'color', 'red', ...
            'markersize', 5);
        
        compoundName = strsplit(peaks(i).library_match(1).compound_name, ';');
        compoundName = upper(compoundName{1});
        
        if length(compoundName) > 20
            compoundName = compoundName(1:20);
        end

        scoreText = num2str(peaks(i).match_score, '%.1f');
        peakText = [compoundName, ' (', scoreText, ')'];

        peakTextX = peaks(i).time;
        peakTextY = peaks(i).height + peaks(i).ymin + textPad;

        peakLabel = text(...
            peakTextX, peakTextY, peakText, ...
            'parent', options.axes_plot,...
            'horizontalalignment', 'left',... 
            'verticalalignment', 'middle',...
            'clipping', 'on', ...
            'fontsize', 6);

        peakLabel.Rotation = 90;
    end
end

% Title
plotTitle = ['Sample #', num2str(sampleIndex), ' - ', data(sampleIndex).sample_name];
title(plotTitle, 'parent', options.axes_plot);

% Axes labels
xlabel('Time (min)', 'parent', options.axes_plot);
ylabel('Intensity', 'parent', options.axes_plot);

% Axes limits
xmin = min([data(sampleIndex).peaks.time]);
xmax = max([data(sampleIndex).peaks.time]);
ymin = min(data(sampleIndex).intensity(:,1));
ymax = max(data(sampleIndex).intensity(:,1));

xpad = (xmax-xmin) * 0.025;
ypad = (ymax-ymin) * 0.075;

set(options.axes_plot, 'xlim', [xmin-xpad, xmax+xpad]);
set(options.axes_plot, 'ylim', [ymin-ypad, ymax+ypad]);

fprintf([num2str(ymax+ypad),'\n']);

end