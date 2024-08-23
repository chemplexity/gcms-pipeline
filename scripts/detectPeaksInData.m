function data = detectPeaksInData(data, varargin)

% ------------------------------------------------------------------------
% Method      : detectPeaksInData()
% Description : runs the peak detection NN to detect all peaks in the 
% specified sample, then runs the peak fitting NN to fit all peaks and
% calculate their areas; stores all peak info in the peakList struct
% ------------------------------------------------------------------------

% ---------------------------------------
% Defaults
% ---------------------------------------
default.maxError         = 50;
default.minPeakHeight    = 1E4;
default.minPeakWidth     = 0.01;
default.minIonIntensity  = 0.02;
default.minSignalToNoise = 2;
default.startIndex       = 1;
default.endIndex         = length(data);

% ---------------------------------------
% Input
% ---------------------------------------
p = inputParser;

addOptional(p, 'maxError', default.maxError);
addOptional(p, 'minPeakHeight', default.minPeakHeight)
addOptional(p, 'minPeakWidth', default.minPeakWidth)
addOptional(p, 'minIonIntensity', default.minIonIntensity);
addOptional(p, 'minSignalToNoise', default.minSignalToNoise);
addOptional(p, 'startIndex', default.startIndex);
addOptional(p, 'endIndex', default.endIndex);

parse(p, varargin{:});

% ---------------------------------------
% Parse
% ---------------------------------------
options.maxError         = p.Results.maxError;
options.minPeakHeight    = p.Results.minPeakHeight;
options.minPeakWidth     = p.Results.minPeakWidth;
options.minIonIntensity  = p.Results.minIonIntensity;
options.minSignalToNoise = p.Results.minSignalToNoise;
options.startIndex       = p.Results.startIndex;
options.endIndex         = p.Results.endIndex;

% ---------------------------------------
% Validate
% ---------------------------------------

% Parameter: 'minIonIntensity'
if options.minIonIntensity > 1
    options.minIonIntensity = options.minIonIntensity / 100;
end

% Parameter: 'minPeakWidth'
if options.minPeakWidth < 0
    options.minPeakWidth = default.minPeakWidth;
end

% Parameter: 'startIndex'
if isempty(options.startIndex)
    options.startIndex = default.startIndex;
end

if options.startIndex <= 0 || options.startIndex > length(data)
    options.startIndex = default.startIndex;
end

% Parameter: 'endIndex'
if isempty(options.endIndex)
    options.endIndex = default.endIndex;
end

if options.endIndex <= 0 || options.endIndex > length(data)
    options.endIndex = default.endIndex;
end

if options.endIndex < options.startIndex
    options.endIndex = options.startIndex;
end

% -----------------------------------------
% Status
% -----------------------------------------
fprintf(['\n', repmat('-',1,50), '\n']);
fprintf(' PEAK DETECTION');
fprintf(['\n', repmat('-',1,50), '\n']);

fprintf([' OPTIONS  startIndex       : ', num2str(options.startIndex), '\n']);
fprintf([' OPTIONS  endIndex         : ', num2str(options.endIndex), '\n']);
fprintf([' OPTIONS  maxError         : ', num2str(options.maxError), '\n']);
fprintf([' OPTIONS  minPeakHeight    : ', num2str(options.minPeakHeight), '\n']);
fprintf([' OPTIONS  minPeakWidth     : ', num2str(options.minPeakWidth), '\n']);
fprintf([' OPTIONS  minIonIntensity  : ', num2str(options.minIonIntensity), '\n']);
fprintf([' OPTIONS  minSignalToNoise : ', num2str(options.minSignalToNoise), '\n\n']);

fprintf([' STATUS  Detecting peaks in ', num2str(options.endIndex - options.startIndex + 1), ' files...', '\n\n']);
totalProcessTime = 0;

for i = options.startIndex:options.endIndex

    m = num2str(i);
    n = num2str(options.endIndex);
    sampleName = strrep(data(i).sample_name, '%', '');

    fprintf([' [', [repmat('0', 1, length(n) - length(m)), m], '/', n, ']']);
    fprintf([' ', sampleName, ': START\n']);
    peakTime = tic;
    
    peakList = [];

    % ---------------------------------------
    % Baseline correction
    % ---------------------------------------
    if isfield(data, 'baseline')
        data(i).intensity(:,1) = sum(data(i).intensity(:, 2:end) - data(i).baseline(:, 2:end), 2);
    end

    % ---------------------------------------
    % Detect peaks
    % ---------------------------------------
    fprintf([' [', [repmat('0', 1, length(n) - length(m)), m], '/', n, ']']);
    fprintf([' ', sampleName, ': detecting peaks...\n']);

    peakLocations = peakfindNN( ...
        data(i).time, ...
        data(i).intensity(:, 1), ...
        'sensitivity', 75);
    
    % ---------------------------------------
    % Filter unique peaks
    % ---------------------------------------
    [~, peakIndex] = unique(peakLocations(:,1));
    peakLocations = peakLocations(peakIndex,:);

    % ---------------------------------------
    % Integrate peaks
    % ---------------------------------------
    fprintf([' [', [repmat('0', 1, length(n) - length(m)), m], '/', n, ']']);
    fprintf([' ', sampleName, ': integrating peaks...\n']);
    
    for j = 1:length(peakLocations(:,1))

        peak = peakfitNN( ...
            data(i).time, ...
            data(i).intensity(:, 1), ...
            peakLocations(j, 1), ...
            'frequency', 500);
        
        % Filter by error
        if peak.error > options.maxError
            continue
        end

        % Filter by peak height
        if peak.height < options.minPeakHeight
            continue
        end

        % Filter by peak width
        if peak.width < options.minPeakWidth
            continue
        end

        % Filter if peak time is outside range
        if peak.time <= peak.xmin || peak.time >= peak.xmax
            continue
        end
        
        peak.peakCenterX = peakLocations(j, 1);
        peak.peakCenterY = peakLocations(j, 2);

        % Get peak center
        if peak.peakCenterY > peak.height + peak.ymin && ...
            peak.peakCenterX >= peak.xmin && ...
            peak.peakCenterX <= peak.xmax
            peakX = peak.peakCenterX;
        else
            peakX = peak.time;
        end

        % Add the mass spectra of each peak center
        timeIndex = lookupTimeIndex(data(i).time, peakX);
        peak.mz = data(i).channel(2:end);
        peak.intensity = data(i).intensity(timeIndex, 2:end);

        % Apply baseline correction to peak intensity
        if isfield(data, 'baseline')
            peak.intensity = peak.intensity - data(i).baseline(timeIndex, 2:end);
        end
        
        % Normalize peak intensity and filter by minimum ion intensity
        peak.intensity = peak.intensity ./ max(peak.intensity);
        peakFilter = peak.intensity >= options.minIonIntensity;

        peak.mz = peak.mz(peakFilter);
        peak.intensity = peak.intensity(peakFilter);

        % Append peak to peak list
        peakList = [peakList, peak];
    end

    % ---------------------------------------
    % Filter unique peaks
    % ---------------------------------------
    removeIndex = [];
    skipIndex = [];

    for j = 1:length(peakList)
        
        if any(skipIndex == j)
            continue
        end

        matches = [peakList.time] == peakList(j).time;

        % Keep lowest error peak among duplicates
        if sum(matches) > 1
            matchIndex = find(matches == 1);
            skipIndex = [skipIndex, matchIndex];

            keepIndex = find([peakList(matchIndex).error] == min([peakList(matchIndex).error]));
            keepIndex = keepIndex(1);

            matchIndex(keepIndex) = [];
            removeIndex = [removeIndex, matchIndex];
        end
    end

    peakList(removeIndex) = [];
    data(i).peaks = peakList;

    % ---------------------------------------
    % Filter by signal to noise
    % ---------------------------------------
    if options.minSignalToNoise > 0
        fprintf([' [', [repmat('0', 1, length(n) - length(m)), m], '/', n, ']']);
        fprintf([' ', sampleName, ': calculating signal to noise...\n']);
    
        data = getSignalToNoise(data, i);
        removeIndex = [];
    
        for j = 1:length(data(i).peaks)
            if data(i).peaks(j).snr < options.minSignalToNoise
                removeIndex(end+1) = j;
            end
        end
    
        if ~isempty(data(i).peaks)
            data(i).peaks(removeIndex) = [];
        end
    end

    % -----------------------------------------
    % Status
    % -----------------------------------------
    processTime = toc(peakTime);
    totalProcessTime = totalProcessTime + processTime;

    fprintf([' [', [repmat('0', 1, length(n) - length(m)), m], '/', n, ']']);
    fprintf([' ', sampleName, ': END']);
    fprintf([' (', num2str(length(data(i).peaks)), ' peaks, ', parsetime(processTime), ')\n\n']);

end

totalPeaks = num2str(sum(length([data(options.startIndex:options.endIndex).peaks])));
totalFiles = num2str(length(data(options.startIndex:options.endIndex)));

fprintf([' STATUS  Total peaks : ', totalPeaks, '\n']);
fprintf([' STATUS  Total files : ', totalFiles, '\n']);
fprintf([' STATUS  Total time  : ', parsetime(totalProcessTime), '\n']);

fprintf([repmat('-',1,50), '\n']);
fprintf(' EXIT');
fprintf(['\n', repmat('-',1,50), '\n']);

end

% ---------------------------------------
% Format time string
% ---------------------------------------
function str = parsetime(x)

if x > 60
    str = [num2str(x/60, '%.1f'), ' min'];
else
    str = [num2str(x, '%.1f'), ' sec'];
end

end