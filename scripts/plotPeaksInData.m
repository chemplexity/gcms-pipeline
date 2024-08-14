function plotPeaksInData(data, sampleIndex)

cla; hold all;
plotPeakLine = false;

% Plot TIC
plot( ...
    data(sampleIndex).time, ...
    data(sampleIndex).intensity(:,1), ...
    'color', 'black');

for i = 1:length(data(sampleIndex).peaks)
    
    % Plot peak area of each peak
    x = data(sampleIndex).time;
    y = data(sampleIndex).intensity(:,1);

    xmin = data(sampleIndex).peaks(i).xmin;
    xmax = data(sampleIndex).peaks(i).xmax;
    ymin = data(sampleIndex).peaks(i).ymin;

    xf = x >= xmin & x <= xmax;
    xArea = x(xf);
    yArea = y(xf);

    if isempty(xArea) || isempty(yArea)
        continue
    end
                    
    xArea = [xArea(:); flipud([xmin; xmax])];
    yArea = [yArea(:); flipud([ymin; ymin])];

    fill(xArea, yArea, [0.00, 0.30, 0.53],...
        'facecolor', [0.00, 0.30, 0.53],...
        'facealpha', 0.3,...
        'edgecolor', 'none',...
        'linestyle', 'none');

    plot( ...
        data(sampleIndex).peaks(i).time, ...
        data(sampleIndex).peaks(i).height + data(sampleIndex).peaks(i).ymin, ...
        '.', 'color', 'red');

    if plotPeakLine
        plot( ...
            data(sampleIndex).peaks(i).fit(:,1), ...
            data(sampleIndex).peaks(i).fit(:,2), ...
            'color', 'black', ...
            'linewidth', 1.0);
    end
end

title([num2str(sampleIndex), ' : ', data(sampleIndex).sample_name])

end