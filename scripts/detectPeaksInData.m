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
default.maxError = 50;
default.minPeakHeight = 1E4;
default.minIonIntensity = 0.02;
default.startIndex = 1;
default.endIndex = length(data);

% ---------------------------------------
% Input
% ---------------------------------------
p = inputParser;

addOptional(p, 'maxError', default.maxError);
addOptional(p, 'minPeakHeight', default.minPeakHeight)
addOptional(p, 'minIonIntensity', default.minIonIntensity);
addOptional(p, 'startIndex', default.startIndex);
addOptional(p, 'endIndex', default.endIndex);

parse(p, varargin{:});

% ---------------------------------------
% Parse
% ---------------------------------------
options.maxError = p.Results.maxError;
options.minPeakHeight = p.Results.minPeakHeight;
options.minIonIntensity = p.Results.minIonIntensity;
options.startIndex = p.Results.startIndex;
options.endIndex = p.Results.endIndex;

% ---------------------------------------
% Validate
% ---------------------------------------

% Parameter: 'minIonIntensity'
if options.minIonIntensity > 1
    options.minIonIntensity = options.minIonIntensity / 100;
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

fprintf([' STATUS  Detecting peaks in ', num2str(options.endIndex - options.startIndex + 1), ' files...', '\n\n']);
peakTime = tic;

for i = options.startIndex:options.endIndex

    m = num2str(i);
    n = num2str(options.endIndex);
    sampleName = strrep(data(i).sample_name, '%', '');

    fprintf([' [', [repmat('0', 1, length(n) - length(m)), m], '/', n, ']']);
    fprintf([' ', sampleName, ': START\n']);
    
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
            continue;
        end
        
        peak.peakCenterX = peakLocations(j, 1);
        peak.peakCenterY = peakLocations(j, 2);

        % Add the mass spectra of each peak center
        timeIndex = lookupTimeIndex(data(i).time, peak.peakCenterX);
        peak.mz = data(i).channel(2:end);
        peak.intensity = data(i).intensity(timeIndex, 2:end);

        % Apply baseline correction to peak intensity
        if isfield(data, 'baseline')
            peak.intensity = peak.intensity - data(i).baseline(timeIndex, 2:end);
        end
        
        % Normalize peak intensity and filter by minimum ion intensity
        peak.intensity = Normalize(peak.intensity);
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

    % -----------------------------------------
    % Status
    % -----------------------------------------
    fprintf([' [', [repmat('0', 1, length(n) - length(m)), m], '/', n, ']']);
    fprintf([' ', sampleName, ': END']);
    fprintf([' (', num2str(length(data(i).peaks)), ' peaks)\n\n']);

end

totalTime = toc(peakTime);
totalFiles = num2str(length(data(options.startIndex:options.endIndex)));
totalPeaks = num2str(sum(length([data(options.startIndex:options.endIndex).peaks])));

fprintf([' STATUS  Total files : ', totalFiles, '\n']);
fprintf([' STATUS  Total peaks : ', totalPeaks, '\n']);
fprintf([' STATUS  Total time  : ', parsetime(totalTime), '\n']);

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