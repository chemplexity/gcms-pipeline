function plotChromatogramWithLibraryMatches(data, sampleIndex, varargin)

% Set label type (compound_name OR compound_ontology)
if ~isempty(varargin)
    compoundTextField = varargin{1};
else
    compoundTextField = 'compound_name';
end

if ~any(strcmp(compoundTextField, {'compound_ontology', 'compound_name'}))
    compoundTextField = 'compound_name';
end

if strcmpi(compoundTextField, 'compound_ontology')
    compoundColors = getCompoundOntologyColors(data, sampleIndex);
end

% Get data
sampleTime = data(sampleIndex).time;
sampleIntensity = data(sampleIndex).intensity(:,1);

% Set plot options
options.linewidth = 0.8;
options.ticks.size = [0.007, 0.0075];
options.line.color = [0.22,0.22,0.22];
options.line.width = 1.25;

% Get axes limits
if isempty(data(sampleIndex).peaks) || sum([data(sampleIndex).peaks.match_score]) < 100
    xminPlot = min([data(sampleIndex).time]);
    xmaxPlot = max([data(sampleIndex).time]);
else
    xminPlot = min([data(sampleIndex).peaks.xmin]);
    xmaxPlot = max([data(sampleIndex).peaks.xmax]);

    if xmaxPlot - xminPlot < 5
        xExtra = (xmaxPlot - xminPlot) / 2;
        xminPlot = xminPlot - xExtra;
        xmaxPlot = xmaxPlot + xExtra;
    end
end

yminPlot = min(data(sampleIndex).intensity(:,1));
ymaxPlot = max(data(sampleIndex).intensity(:,1));

xpadPlot = (xmaxPlot-xminPlot) * 0.025;
ypadPlot = (ymaxPlot-yminPlot) * 0.025;

if xpadPlot == 0
    xpadPlot = 2;
end

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
peakFill = [];
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
    
        if strcmpi(compoundTextField, 'compound_ontology')
            if isempty(peaks(i).library_match)
                faceColor = [0.7, 0.7, 0.7];
                textColor = 'black';
            else
                compoundOntology = peaks(i).library_match(1).compound_ontology;
                colorIndex = strcmpi(compoundOntology, {compoundColors{:,1}});
                faceColor = compoundColors{colorIndex,2};
                textColor = faceColor;
            end
        else
            if isempty(peaks(i).library_match)
                faceColor = [0.93, 0.30, 0.30];
            else
                matchScore = peaks(i).match_score;
                
                if matchScore >= 100
                    matchScore = 99.99;
                end

                faceColor = [0.30, matchScore/100, 0.30];
            end

            textColor = 'black';
        end

        peakFill(end+1) = fill(xArea, yArea, [0.00, 0.30, 0.53], ...
            'parent', options.axes_plot, ...
            'facecolor', faceColor, ...
            'facealpha', 0.3, ...
            'edgecolor', 'none', ...
            'linestyle', 'none');
        
        if isempty(peaks(i).library_match)
            continue;
        end

        if peaks(i).peakCenterY > peaks(i).height + peaks(i).ymin && ...
            peaks(i).peakCenterX >= peaks(i).xmin && ...
            peaks(i).peakCenterX <= peaks(i).xmax
            peakX = peaks(i).peakCenterX;
            peakY = peaks(i).peakCenterY;
        else
            peakX = peaks(i).time;
            peakY = peaks(i).height + peaks(i).ymin;
        end
        
        plot(peakX, peakY, '.', ...
            'parent', options.axes_plot, ...
            'color', 'red', ...
            'markersize', 5);

        % Plot library match text
        compoundText = strsplit(peaks(i).library_match(1).(compoundTextField), ';');
        compoundText = upper(compoundText{1});
        
        if length(compoundText) > 50
            compoundText = compoundText(1:50);
        end

        scoreText = num2str(peaks(i).match_score, '%.1f');
        peakText = [compoundText, ' (', scoreText, ')'];
       
        peakTextX = peakX;
        peakTextY = peakY + textPad;

        peakLabel = text(...
            peakTextX, peakTextY, peakText, ...
            'parent', options.axes_plot, ...
            'horizontalalignment', 'left', ... 
            'verticalalignment', 'middle', ...
            'color', textColor, ...
            'clipping', 'on', ...
            'fontsize', 6);

        peakLabel.Rotation = 90;

        % Check if text is outside axes
        if peakLabel.Extent(2) + peakLabel.Extent(4) > ymaxPlot + ypadPlot
            ymaxPlot = peakLabel.Extent(2) + peakLabel.Extent(4);
        end
    end
end

% Title
plotTitle = getPlotTitle(data, sampleIndex);
title(plotTitle, 'parent', options.axes_plot);

% Axes labels
xlabel('Time (min)', 'parent', options.axes_plot);
ylabel('Intensity', 'parent', options.axes_plot);

% Axes limits
set(options.axes_plot, 'xlim', [xminPlot-xpadPlot, xmaxPlot+xpadPlot]);
set(options.axes_plot, 'ylim', [yminPlot-ypadPlot, ymaxPlot+ypadPlot]);

end

% -----------------------------------------
% Get plot title
% -----------------------------------------
function titleText = getPlotTitle(data, sampleIndex)
    
% Get file name and extension
    [~, sequenceName , ~] = fileparts(data(sampleIndex).file_path);
    [fileBase, ~, ~] = fileparts(data(sampleIndex).file_name);
    sampleName = data(sampleIndex).sample_name;

    titleText = [sequenceName, '/', fileBase, ', ', sampleName];

    titleText = strrep(titleText, '\', '/');
    titleText = strrep(titleText, '%', '');
    titleText = strrep(titleText, '_', '\_');
end

% -----------------------------------------
% Get all compound ontologies and color map
% -----------------------------------------
function compoundOntology = getCompoundOntologyColors(data, sampleIndex)

compoundOntology = {};

% Get all compound ontologies for consistent colors
for i = 1:length(data)
    if ~isfield(data, 'peaks')
        continue
    end

    if ~isfield(data(i).peaks, 'library_match')
        continue
    end

    libraryMatch = [data(i).peaks(~[data(i).peaks.match_score] == 0).library_match];
    
    if isempty(libraryMatch)
        continue
    end
    
    libraryMatch = unique({libraryMatch.compound_ontology});
    
    for j = 1:length(libraryMatch)
        compoundOntology{end+1} = lower(libraryMatch{j});
    end
end

% for i = 1:length(data(sampleIndex).peaks)
%     if isempty(data(sampleIndex).peaks(i).library_match)
%         continue
%     end
% 
%     if ~isempty(data(sampleIndex).peaks(i).library_match(1).compound_ontology)
%         compoundOntology{end+1} = lower(data(sampleIndex).peaks(i).library_match(1).compound_ontology);
%     end
% end

compoundOntology = sort(unique(compoundOntology))';
compoundColors = orderedcolors('gem12');

colorIndex = 1;

for i = 1:length(compoundOntology)
    compoundOntology{i,2} = compoundColors(colorIndex, :);
    compoundOntology{i,3} = 0;
    colorIndex = colorIndex + 1;

    if colorIndex > length(compoundColors)
        colorIndex = 1;
    end
end

end