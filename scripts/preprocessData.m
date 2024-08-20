function data = preprocessData(data, varargin)

% ------------------------------------------------------------------------
% Method      : preprocessData
% Description : crops the signal by time, applies the centroid algorithm 
% and calculates the baseline for all chromatograms
% ------------------------------------------------------------------------

% ---------------------------------------
% Defaults
% ---------------------------------------
default.timeStart          = [];
default.timeEnd            = [];
default.baselineSmoothness = 5E6;
default.baselineAsymmetry  = 5E-3;
default.startIndex         = 1;
default.endIndex           = length(data);

% ---------------------------------------
% Input
% ---------------------------------------
p = inputParser;

addOptional(p, 'timeStart', default.timeStart);
addOptional(p, 'timeEnd', default.timeEnd)
addOptional(p, 'baselineSmoothness', default.baselineSmoothness);
addOptional(p, 'baselineAsymmetry', default.baselineAsymmetry);
addOptional(p, 'startIndex', default.startIndex);
addOptional(p, 'endIndex', default.endIndex);

parse(p, varargin{:});

% ---------------------------------------
% Parse
% ---------------------------------------
options.timeStart          = p.Results.timeStart;
options.timeEnd            = p.Results.timeEnd;
options.baselineSmoothness = p.Results.baselineSmoothness;
options.baselineAsymmetry  = p.Results.baselineAsymmetry;
options.startIndex         = p.Results.startIndex;
options.endIndex           = p.Results.endIndex;

% ---------------------------------------
% Validate
% ---------------------------------------

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
fprintf(' PREPROCESSING DATA');
fprintf(['\n', repmat('-',1,50), '\n']);

if isempty(options.timeStart)
    timeStartString = 'N/A';
else
    timeStartString = num2str(options.timeStart);
end

if isempty(options.timeEnd)
    timeEndString = 'N/A';
else
    timeEndString = num2str(options.timeEnd);
end

fprintf([' OPTIONS  startIndex         : ', num2str(options.startIndex), '\n']);
fprintf([' OPTIONS  endIndex           : ', num2str(options.endIndex), '\n']);
fprintf([' OPTIONS  timeStart          : ', timeStartString, '\n']);
fprintf([' OPTIONS  timeEnd            : ', timeEndString, '\n']);
fprintf([' OPTIONS  baselineSmoothness : ', num2str(options.baselineSmoothness), '\n']);
fprintf([' OPTIONS  baselineAsymmetry  : ', num2str(options.baselineAsymmetry), '\n\n']);

fprintf([' STATUS  Preprocessing ', num2str(options.endIndex - options.startIndex + 1), ' files...', '\n\n']);
totalProcessTime = 0;

% -----------------------------------------
% Preprocessing
% -----------------------------------------
for i = options.startIndex:options.endIndex

    m = num2str(i);
    n = num2str(options.endIndex);
    sampleName = strrep(data(i).sample_name, '%', '');

    fprintf([' [', [repmat('0', 1, length(n) - length(m)), m], '/', n, ']']);
    fprintf([' ', sampleName, ': START\n']);
    preprocessTime = tic;

    % -----------------------------------------
    % Crop signals by time
    % -----------------------------------------
    if isempty(options.timeStart)
        timeStart = data(i).time(1) - 1;
    else
        timeStart = options.timeStart;
    end

    if isempty(options.timeEnd)
        timeEnd = data(i).time(end) + 1;
    else
        timeEnd = options.timeEnd;
    end
   
    data(i) = cropDataByTimeRange(data(i), timeStart, timeEnd);

    % -----------------------------------------
    % Centroid mass spectra
    % -----------------------------------------
    fprintf([' [', [repmat('0', 1, length(n) - length(m)), m], '/', n, ']']);
    fprintf([' ', sampleName, ': centroiding...']);
    fprintf([' (', num2str(length(data(i).time)), 'x', num2str(length(data(i).channel)), ')\n']);

    channelWithoutTic = data(i).channel(:, 2:end);
    intensityWithoutTic = data(i).intensity(:, 2:end);

    [centroidedChannel, centroidedIntensity] = Centroid(channelWithoutTic, intensityWithoutTic);
    
    data(i).channel = [data(i).channel(:, 1), centroidedChannel];
    data(i).intensity = [data(i).intensity(:, 1), centroidedIntensity];

    % -----------------------------------------
    % Baseline correction on all chromatograms
    % -----------------------------------------
    fprintf([' [', [repmat('0', 1, length(n) - length(m)), m], '/', n, ']']);
    fprintf([' ', sampleName, ': calculating baselines...']);
    fprintf([' (', num2str(length(data(i).time)), 'x', num2str(length(data(i).channel)), ')\n']);

    data(i).baseline = Baseline(data(i).intensity, ...
        'smoothness', options.baselineSmoothness, ...
        'asymmetry', options.baselineAsymmetry);

    % -----------------------------------------
    % Status
    % -----------------------------------------
    processTime = toc(preprocessTime);
    totalProcessTime = totalProcessTime + processTime;

    fprintf([' [', [repmat('0', 1, length(n) - length(m)), m], '/', n, ']']);
    fprintf([' ', sampleName, ': END (', parsetime(processTime), ')\n\n']);
    
end

totalFiles = num2str(length(data(options.startIndex:options.endIndex)));

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