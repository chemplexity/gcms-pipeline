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

% ---------------------------------------
% Input
% ---------------------------------------
p = inputParser;

addOptional(p, 'timeStart', default.time_start);
addOptional(p, 'timeEnd', default.time_end)
addOptional(p, 'baselineSmoothness', default.baseline_smoothness);
addOptional(p, 'baselineAsymmetry', default.baseline_asymmetry);

parse(p, varargin{:});

% ---------------------------------------
% Parse
% ---------------------------------------
options.timeStart = p.Results.timeStart;
options.timeEnd = p.Results.timeEnd;
options.baselineSmoothness = p.Results.baselineSmoothness;
options.baselineAsymmetry = p.Results.baselineAsymmetry;

% -----------------------------------------
% Status
% -----------------------------------------
fprintf(['\n', repmat('-',1,50), '\n']);
fprintf(' PREPROCESSING DATA');
fprintf(['\n', repmat('-',1,50), '\n\n']);

fprintf([' STATUS  Preprocessing ', num2str(length(data)), ' files...', '\n\n']);

% -----------------------------------------
% Preprocessing
% -----------------------------------------
for i = 1:size(data,1)

    m = num2str(i);
    n = num2str(size(data,1));
    
    fprintf([' [', [repmat('0', 1, length(n) - length(m)), m], '/', n, ']']);
    fprintf([' ', data(i).sample_name, ' START\n']);

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
   
    % -----------------------------------------
    % Crop signals by time
    % -----------------------------------------
    data(i) = cropDataByTimeRange(data(i), timeStart, timeEnd);

    % -----------------------------------------
    % Centroid mass spectra
    % -----------------------------------------
    fprintf([' [', [repmat('0', 1, length(n) - length(m)), m], '/', n, ']']);
    fprintf([' ', data(i).sample_name, ' centroiding...']);
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
    fprintf([' ', data(i).sample_name, ' calculating baselines...']);
    fprintf([' (', num2str(length(data(i).channel)), ' vectors)\n']);

    data(i).baseline = Baseline(data(i).intensity, ...
        'smoothness', options.baselineSmoothness, ...
        'asymmetry', options.baselineAsymmetry);

    % -----------------------------------------
    % Status
    % -----------------------------------------
    fprintf([' [', [repmat('0', 1, length(n) - length(m)), m], '/', n, ']']);
    fprintf([' ', data(i).sample_name, ' END\n']);
    
end

fprintf(['\n', repmat('-',1,50), '\n']);
fprintf(' EXIT');
fprintf(['\n', repmat('-',1,50), '\n']);