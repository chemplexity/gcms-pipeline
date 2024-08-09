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

% ---------------------------------------
% Preprocessing
% ---------------------------------------
for i = 1:size(data, 1)

    if isempty(options.timeStart)
        timeStart = data(i).time(1) - 1;
    end

    if isempty(options.timeEnd)
        timeEnd = data(i).time(end) + 1;
    end
   
    data(i) = cropDataByTimeRange(data(i), timeStart, timeEnd);

    % Apply centroid algorithm to channel and intensity data
    channelWithoutTic = data(i).channel(:, 2:end);
    intensityWithoutTic = data(i).intensity(:, 2:end);
    [centroidedChannel, centroidedIntensity] = Centroid(channelWithoutTic, intensityWithoutTic);
    data(i).channel = [data(i).channel(:, 1), centroidedChannel];
    data(i).intensity = [data(i).intensity(:, 1), centroidedIntensity];

    % Calculate the baseline
    data(i).baseline = Baseline(data(i).intensity, 'smoothness', ...
        options.baselineSmoothness, 'asymmetry', options.baselineAsymmetry);
    
end