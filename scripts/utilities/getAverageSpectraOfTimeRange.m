function averageIntensitySpectra = getAverageSpectraOfTimeRange(timeArray, intensityArray, timeStart, timeEnd)

% ------------------------------------------------------------------------
% Method      : getAverageSpectraOfTimeRange
% Description : averages the intensity spectra within the given time range
% ------------------------------------------------------------------------

if timeEnd <= timeStart

    error('This is not a valid time range');

elseif timeStart > timeArray(end)

    error('timeStart exceeds all values in timeArray');

end

[startInd, endInd] = lookupTimeRangeIndex(timeArray, timeStart, timeEnd);

relevantRows = intensityArray(startInd: endInd, :);

averageIntensitySpectra = mean(relevantRows);

end







