function data = detectPeaksInData(data, varargin)

% ------------------------------------------------------------------------
% Method      : detectPeaksInData()
% Description : runs the peak detection NN to detect all peaks in the 
% specified sample, then runs the peak fitting NN to fit all peaks and
% calculate their areas; stores all peak info in the peakList struct
% ------------------------------------------------------------------------

% Set maximum error for peak fit
maxError = 50;

% Set minimum intensity (%) of mass spectra ion in peak to save 
minIntensity = 0.02;

for i = 1:length(data)

    peakList = [];

    % Perform baseline correction on TIC
    if isfield(data, 'baseline')
        data(i).intensity(:,1) = sum(data(i).intensity(:, 2:end) - data(i).baseline(:, 2:end), 2);
    end

    % Find all peaks in the TIC
    peakLocations = peakfindNN( ...
        data(i).time, ...
        data(i).intensity(:, 1), ...
        'sensitivity', 75);
    
    % Filter unique peaks
    [~, peakIndex] = unique(peakLocations(:,1));
    peakLocations = peakLocations(peakIndex,:);

    for j = 1:length(peakLocations)

        % Integrate each detected peak
        peak = peakfitNN( ...
            data(i).time, ...
            data(i).intensity(:, 1), ...
            peakLocations(j, 1), ...
            'frequency', 500);
        
        if peak.error > maxError
            continue
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
        
        % Normalize peak intensity and filter by minimum intensity
        peak.intensity = Normalize(peak.intensity);
        peakFilter = peak.intensity >= minIntensity;

        peak.mz = peak.mz(peakFilter);
        peak.intensity = peak.intensity(peakFilter);

        % Append peak to peak list
        peakList = [peakList, peak];
    end

    % Filter unique peaks again
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

            keepIndex = find([peakList(matchIndex).error] == min(peakList(matchIndex).error));
            keepIndex = keepIndex(1);

            matchIndex(keepIndex) = [];
            removeIndex = [removeIndex, matchIndex];
        end
    end

    peakList(removeIndex) = [];

    data(i).peaks = peakList;
end