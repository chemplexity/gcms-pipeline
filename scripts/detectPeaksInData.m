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
default.maxPeakOverlap   = 0.5;
default.startIndex       = 1;
default.endIndex         = length(data);
default.minMz            = -1;
default.maxMz            = -1;

% ---------------------------------------
% Input
% ---------------------------------------
p = inputParser;

addOptional(p, 'maxError', default.maxError);
addOptional(p, 'minPeakHeight', default.minPeakHeight)
addOptional(p, 'minPeakWidth', default.minPeakWidth)
addOptional(p, 'minIonIntensity', default.minIonIntensity);
addOptional(p, 'minSignalToNoise', default.minSignalToNoise);
addOptional(p, 'maxPeakOverlap', default.maxPeakOverlap);
addOptional(p, 'startIndex', default.startIndex);
addOptional(p, 'endIndex', default.endIndex);
addOptional(p, 'minMz', default.minMz);
addOptional(p, 'maxMz', default.maxMz);

parse(p, varargin{:});

% ---------------------------------------
% Parse
% ---------------------------------------
options.maxError         = p.Results.maxError;
options.minPeakHeight    = p.Results.minPeakHeight;
options.minPeakWidth     = p.Results.minPeakWidth;
options.minIonIntensity  = p.Results.minIonIntensity;
options.minSignalToNoise = p.Results.minSignalToNoise;
options.maxPeakOverlap   = p.Results.maxPeakOverlap;
options.startIndex       = p.Results.startIndex;
options.endIndex         = p.Results.endIndex;
options.minMz            = p.Results.minMz;
options.maxMz            = p.Results.maxMz;

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
fprintf([' OPTIONS  minMz            : ', num2str(options.minMz), '\n']);
fprintf([' OPTIONS  maxMz            : ', num2str(options.maxMz), '\n']);
fprintf([' OPTIONS  maxError         : ', num2str(options.maxError), '\n']);
fprintf([' OPTIONS  minPeakHeight    : ', num2str(options.minPeakHeight), '\n']);
fprintf([' OPTIONS  minPeakWidth     : ', num2str(options.minPeakWidth), '\n']);
fprintf([' OPTIONS  minIonIntensity  : ', num2str(options.minIonIntensity), '\n']);
fprintf([' OPTIONS  minSignalToNoise : ', num2str(options.minSignalToNoise), '\n']);
fprintf([' OPTIONS  maxPeakOverlap   : ', num2str(options.maxPeakOverlap), '\n\n']);

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
    if ~isfield(data, 'baseline') || isempty(data(i).baseline)
        data(i).baseline = Baseline(data(i).intensity(:,1), 'smoothness', 1E7, 'asymmetry', 5E-4);
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
    
    % -----------------------------------------
    % Check for peaks 
    % -----------------------------------------
    if isempty(peakLocations)
        processTime = toc(peakTime);
        totalProcessTime = totalProcessTime + processTime;

        fprintf([' [', [repmat('0', 1, length(n) - length(m)), m], '/', n, ']']);
        fprintf([' ', sampleName, ': END']);
        fprintf([' (', num2str(length(data(i).peaks)), ' peaks, ', parsetime(processTime), ')\n\n']);
        
        continue;
    end
        
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
            'frequency', 500, ...
            'baseline', data(i).baseline(:,1));
        
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

        % Apply corrections to peak height
        if peak.peakCenterY > peak.height + peak.ymin && ...
            peak.peakCenterX >= peak.xmin && ...
            peak.peakCenterX <= peak.xmax

            peak.time = peak.peakCenterX;
            peak.ymax = peak.peakCenterY;
            peak.height = peak.ymax - peak.ymin;
        end

        % Add the mass spectra of each peak center
        timeIndex = lookupTimeIndex(data(i).time, peak.time);
        peak.mz = data(i).channel(2:end);
        peak.intensity = data(i).intensity(timeIndex, 2:end);

        % Apply baseline correction to peak intensity
        if isfield(data, 'baseline') && length(data(i).baseline(1,:)) == length(data(i).channel)
            peak.intensity = peak.intensity - data(i).baseline(timeIndex, 2:end);
        end
        
        % Filter by minMz and maxMz
        if options.minMz ~= -1
            mzFilter = peak.mz >= options.minMz;
            peak.mz = peak.mz(mzFilter);
            peak.intensity = peak.intensity(mzFilter);
        end

        if options.maxMz ~= -1
            mzFilter = peak.mz <= options.maxMz;
            peak.mz = peak.mz(mzFilter);
            peak.intensity = peak.intensity(mzFilter);
        end

        % Normalize peak intensity and filter by minimum ion intensity
        peak.intensity = peak.intensity ./ max(peak.intensity);

        intensityFilter = peak.intensity >= options.minIonIntensity;
        peak.mz = peak.mz(intensityFilter);
        peak.intensity = peak.intensity(intensityFilter);

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

        % Find exact matches first
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

    % Remove overlapping peaks
    peakList = removeOverlappingPeaks(peakList, options.maxPeakOverlap);
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

    if isempty(data(i).peaks)
        data(i).peaks = [];
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

% ---------------------------------------
% Find overlapping peaks
% ---------------------------------------
function peaks = removeOverlappingPeaks(peaks, maxOverlap)

removeIndex = [];

for i = 1:length(peaks)

    % Get peak boundaries
    a0 = peaks(i).xmin;
    a1 = peaks(i).xmax;

    b0 = [peaks.xmin];
    b1 = [peaks.xmax];

    matchIndex = i;

    % Case 1 (Peak B starts within Peak A)
    isOverlap = b0 >= a0 & b0 <= a1 & b1 > a1;

    overlapIndex = find(isOverlap == 1);
    overlapIndex(overlapIndex == i) = [];

    for j = 1:length(overlapIndex)
        peakSpan = a1 - a0;
        peakOverlapSpan = a1 - peaks(overlapIndex(j)).xmin;

        if peakOverlapSpan / peakSpan > maxOverlap
            matchIndex(end+1) = overlapIndex(j);
        end
    end

    % Case 2 (Peak B ends within Peak A)
    isOverlap = b1 >= a0 & b1 <= a1 & b0 < a0;

    overlapIndex = find(isOverlap == 1);
    overlapIndex(overlapIndex == i) = [];

    for j = 1:length(overlapIndex)
        peakSpan = a1 - a0;
        peakOverlapSpan = peaks(overlapIndex(j)).xmax - a0;

        if peakOverlapSpan / peakSpan > maxOverlap
            matchIndex(end+1) = overlapIndex(j);
        end
    end

    % Case 3 (Peak B is entirely within Peak A)
    isOverlap = b0 >= a0 & b0 <= a1 & b1 >= a0 & b1 <= a1;

    overlapIndex = find(isOverlap == 1);
    overlapIndex(overlapIndex == i) = [];

    for j = 1:length(overlapIndex)
        matchIndex(end+1) = overlapIndex(j);
    end

    % Remove overlapping peaks
    matchIndex = unique(matchIndex);

    if isscalar(matchIndex)
        continue
    end

    % Keep lowest error peak
    keepIndex = find([peaks(matchIndex).error] == min([peaks(matchIndex).error]));
    keepIndex = keepIndex(1);

    matchIndex(keepIndex) = [];
    removeIndex = [removeIndex, matchIndex];

end

% Remove overlapping peaks
removeIndex = unique(removeIndex);
peaks(removeIndex) = [];

end
