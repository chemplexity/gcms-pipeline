function data = preprocessData(data, timeStart, timeEnd)

% ------------------------------------------------------------------------
% Method      : preprocessData
% Description : crops the signal by time, applies the centroid algorithm 
% to data.channel and data.intensity, and calculates and returns the
% baseline
% ------------------------------------------------------------------------

% Defaults will be empty
% options.time_start = []
% options.time_end = []

% baseline smoothness, default = 1E7
% baseline asymmetry, default = 1E-4

baselineSmoothness = 1E7;
baselineAsymmetry = 1E-4;

for i = 1:size(data, 1)
    
    % Crop signal by start and end time

    % if isempty(options.time_start)
    %   timeStart = data(i).time(1) - 1

    % if isempty(options.time_end)
    %   timeEnd = data(i).time(end) + 1

    data(i) = cropDataByTimeRange(data(i), timeStart, timeEnd);

    % Apply centroid algorithm to channel and intensity data
    channelWithoutTic = data(i).channel(:, 2:end);
    intensityWithoutTic = data(i).intensity(:, 2:end);
    [centroidedChannel, centroidedIntensity] = Centroid(channelWithoutTic, intensityWithoutTic);
    data(i).channel = [data(i).channel(:, 1), centroidedChannel];
    data(i).intensity = [data(i).intensity(:, 1), centroidedIntensity];

    % Calculate the baseline
    data(i).baseline = Baseline(data(i).intensity, 'smoothness', baselineSmoothness, 'asymmetry', baselineAsymmetry);
    
end

end