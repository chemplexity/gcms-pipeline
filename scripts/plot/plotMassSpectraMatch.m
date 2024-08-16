function plotMassSpectraMatch(data, sampleIndex, peakIndex, minMz)

if isempty(data(sampleIndex).peaks(peakIndex).library_match)
    return
end

% Get data
sampleTime = data(sampleIndex).time;
sampleIntensity = data(sampleIndex).intensity(:,1);

peakMz = data(sampleIndex).peaks(peakIndex).mz;
peakIntensity = data(sampleIndex).peaks(peakIndex).intensity;

peakFilter = peakMz >= minMz;
peakMz = peakMz(peakFilter);
peakIntensity = Normalize(peakIntensity(peakFilter));

matchMz = data(sampleIndex).peaks(peakIndex).library_match(1).mz;
matchIntensity = Normalize(data(sampleIndex).peaks(peakIndex).library_match(1).intensity);

% Set plot options
options.xlimits = [min([peakMz, matchMz])-20, max([peakMz, matchMz])+20];
options.ylimits = [-1.05, 1.05];
options.linewidth = 0.8;
options.ticks.size = [0.007, 0.0075];
options.line.color = [0.22,0.22,0.22];
options.line.width = 1.25;

% Format data
sampleWindow = 1;
peakTime = data(sampleIndex).peaks(peakIndex).time;

sampleFilter = sampleTime >= (peakTime - sampleWindow) & sampleTime <= (peakTime + sampleWindow);
sampleTime = sampleTime(sampleFilter);
sampleIntensity = sampleIntensity(sampleFilter);

[peakMz, peakIntensity] = addZeroPadding(peakMz, peakIntensity, options, 0.1);
[matchMz, matchIntensity] = addZeroPadding(matchMz, matchIntensity, options, 0.1);

% Initialize plots
clf;

options.figure = figure(gcf);
set(options.figure, 'units', 'normalized');
set(options.figure, 'color', 'white');

options.axes_plot = axes(...
    'parent', options.figure,...
    'units', 'normalized',...
    'position', [0.08, 0.68, 0.88, 0.27], ...
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

options.axes_spectra = axes(...
    'parent', options.figure,...
    'units', 'normalized',...
    'position', [0.08, 0.08, 0.88, 0.52], ...
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
    'nextplot', 'replacechildren');

% Plot chromatogram
plot(sampleTime, sampleIntensity, ...
    'parent', options.axes_plot, ...
    'color', 'black', ...
    'linewidth', options.linewidth);

hold all;

% Plot peaks
peakTimes = [data(sampleIndex).peaks.time];
peakFilter = peakTimes >= (peakTime - sampleWindow) & peakTimes <= (peakTime + sampleWindow);
peaks = data(sampleIndex).peaks(peakFilter);

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
    
        if peaks(i).time == peakTime
            faceColor = [0.00, 0.30, 0.53];
        elseif isempty(peaks(i).library_match)
            faceColor = [0.93, 0.30, 0.30];
        else
            faceColor = [0.30, 0.90, 0.30];
        end

        fill(xArea, yArea, [0.00, 0.30, 0.53],...
            'parent', options.axes_plot, ...
            'facecolor', faceColor,...
            'facealpha', 0.3,...
            'edgecolor', 'none',...
            'linestyle', 'none');
        
        if peaks(i).time == peakTime
            plot( ...
                peaks(i).time, ...
                peaks(i).height + peaks(i).ymin, ...
                '.', ...
                'parent', options.axes_plot, ...
                'color', 'red', ...
                'markersize', 10);
        end
    end
end
                
% Plot mass spectra
plot(peakMz, peakIntensity, ...
    'parent', options.axes_spectra, ...
    'color', 'black', ...
    'linewidth', options.linewidth);

plot(matchMz, -matchIntensity, ...
    'parent', options.axes_spectra, ...
    'color', 'red', ...
    'linewidth', options.linewidth);

% Plot text
compoundName = strsplit(data(sampleIndex).peaks(peakIndex).library_match(1).compound_name, ';');
compoundName = upper(compoundName{1});

if length(compoundName) > 100
    compoundName = compoundName(1:100);
end

text(...
    options.xlimits(2), options.ylimits(1)+0.025, compoundName, ...
    'parent', options.axes_spectra,...
    'horizontalalignment', 'right',... 
    'verticalalignment', 'bottom',...
    'clipping', 'on', ...
    'fontsize', 12);

scoreValue = num2str(data(sampleIndex).peaks(peakIndex).match_score);
scoreText = ['Score: ', scoreValue];

text(...
    options.xlimits(2), options.ylimits(2)-0.025, scoreText, ...
    'parent', options.axes_spectra,...
    'horizontalalignment', 'right',... 
    'verticalalignment', 'top',...
    'clipping', 'on', ...
    'fontweight', 'demi', ...
    'fontsize', 12);

% Title
plotTitle = ['Sample #', num2str(sampleIndex), ', Peak #' num2str(peakIndex), '/', num2str(length(data(sampleIndex).peaks)),' - '];
plotTitle = [plotTitle, data(sampleIndex).sample_name];
plotTitle = strrep(plotTitle, '_', '\_');

title(plotTitle, 'parent', options.axes_plot);

% Axes labels
xlabel('Time (min)', 'parent', options.axes_plot);
ylabel('Intensity', 'parent', options.axes_plot);

xlabel('Mass (m/z)', 'parent', options.axes_spectra);
ylabel('Intensity (%)', 'parent', options.axes_spectra);

% Axes limits
ymin = data(sampleIndex).peaks(peakIndex).ymin;
ymax = data(sampleIndex).peaks(peakIndex).ymax;
ypad = (ymax-ymin) * 0.075;

set(options.axes_plot, 'xlim', [peakTime - sampleWindow, peakTime + sampleWindow]);
set(options.axes_plot, 'ylim', [ymin-ypad, ymax+ypad]);

set(options.axes_spectra, 'xlim', options.xlimits);
set(options.axes_spectra, 'ylim', options.ylimits);

end

function [mz, y] = addZeroPadding(mz, y, options, mzStep)

% Get average distance between mz points
if mean(diff(mz)) < 1 && length(mz) >= 100
    return
end

if isempty(options.xlimits)
    minMz = mz(1);
    maxMz = mz(end);
else
    minMz = min([mz(1), options.xlimits(1)]);
    maxMz = max([mz(end), options.xlimits(2)]);
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
