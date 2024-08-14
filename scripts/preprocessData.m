function data = preprocessData(data, varargin)

% ------------------------------------------------------------------------
% Method      : preprocessData
% Description : crops the signal by time, applies the centroid algorithm 
% to data.channel and data.intensity, and calculates and returns the
% baseline
% ------------------------------------------------------------------------

% ---------------------------------------
% Defaults
% ---------------------------------------
default.time_start = [];
default.time_end = [];
default.baseline_smoothness = 1E7;
default.baseline_asymmetry = 1E-4;
default.startIndex = 1;
default.endIndex = length(data);

% ---------------------------------------
% Input
% ---------------------------------------
p = inputParser;

addOptional(p, 'timeStart', default.time_start);
addOptional(p, 'timeEnd', default.time_end)
addOptional(p, 'baselineSmoothness', default.baseline_smoothness);
addOptional(p, 'baselineAsymmetry', default.baseline_asymmetry);
addOptional(p, 'startIndex', default.startIndex);
addOptional(p, 'endIndex', default.endIndex);

parse(p, varargin{:});

% ---------------------------------------
% Parse
% ---------------------------------------
options.timeStart = p.Results.timeStart;
options.timeEnd = p.Results.timeEnd;
options.baselineSmoothness = p.Results.baselineSmoothness;
options.baselineAsymmetry = p.Results.baselineAsymmetry;
options.startIndex = p.Results.startIndex;
options.endIndex = p.Results.endIndex;

% ---------------------------------------
% Validate
% ---------------------------------------

% Parameter: 'startIndex'
if isempty(options.startIndex)
    options.startIndex = default.startIndex;
end

if options.startIndex < 0 || options.startIndex > length(data)
    options.startIndex = default.startIndex;
end

% Parameter: 'endIndex'
if isempty(options.endIndex)
    options.endIndex = default.endIndex;
end

if options.endIndex < 0 || options.endIndex > length(data)
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

fprintf([' STATUS  Preprocessing ', num2str(options.endIndex - options.startIndex + 1), ' files...', '\n\n']);
totalProcessTime = 0;

% -----------------------------------------
% Preprocessing
% -----------------------------------------
for i = options.startIndex:options.endIndex

    m = num2str(i);
    n = num2str(options.endIndex);

    fprintf([' [', [repmat('0', 1, length(n) - length(m)), m], '/', n, ']']);
    fprintf([' ', data(i).sample_name, ': START\n']);
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
    fprintf([' ', data(i).sample_name, ': centroiding...']);
    fprintf([' (', num2str(length(data(i).channel)), ' vectors)\n']);

    channelWithoutTic = data(i).channel(:, 2:end);
    intensityWithoutTic = data(i).intensity(:, 2:end);

    [centroidedChannel, centroidedIntensity] = Centroid(channelWithoutTic, intensityWithoutTic);
    
    data(i).channel = [data(i).channel(:, 1), centroidedChannel];
    data(i).intensity = [data(i).intensity(:, 1), centroidedIntensity];

    % -----------------------------------------
    % Baseline correction on all chromatograms
    % -----------------------------------------
    fprintf([' [', [repmat('0', 1, length(n) - length(m)), m], '/', n, ']']);
    fprintf([' ', data(i).sample_name, ': calculating baselines...']);
    fprintf([' (', num2str(length(data(i).channel)), ' vectors)\n']);

    data(i).baseline = Baseline(data(i).intensity, ...
        'smoothness', options.baselineSmoothness, ...
        'asymmetry', options.baselineAsymmetry);

    % -----------------------------------------
    % Status
    % -----------------------------------------
    processTime = toc(preprocessTime);
    totalProcessTime = totalProcessTime + processTime;

    fprintf([' [', [repmat('0', 1, length(n) - length(m)), m], '/', n, ']']);
    fprintf([' ', data(i).sample_name, ': END (', parsetime(processTime), ')\n\n']);
    
end

fprintf([' STATUS  Total processing time : ', parsetime(totalProcessTime), '\n']);

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