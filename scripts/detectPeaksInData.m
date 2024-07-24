% Script will do 2 things for peak detection:
    % 1) perform peakfindNN on data.time, data.intensity(:,1)
        % - find all peak locations in the signal
        % - returns 2 columns (peak centers (x), peak tops (y))
    % 2) perform peakfitNN at each peak location
        % store all peaks in struct
        % return struct

% Plot examples
% Sample TIC
% plot(data(1).time, data(1).intensity(:,1))
% hold all
%
% Plot all peaks with markers
% plot(peaks(:,1), peaks(:,2), '.', 'markersize', 15)

% Plot the fitted line to signal
% plot(peak.fit(:,1),peak.fit(:,2))

% input is data, sampleIndex
% output is list of peaks
 