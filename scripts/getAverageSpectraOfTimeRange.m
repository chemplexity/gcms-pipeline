function averageIntensitySpectra = getAverageSpectraOfTimeRange(timeArray, intensityArray, timeStart, timeEnd)

if timeEnd <= timeStart
    error('This is not a valid time range');
end

% lookup time start/end index

[startInd, endInd] = lookupTimeRangeIndex(timeArray, timeStart, timeEnd);

% average the intensity spectra within that index range

relevantRows = intensityArray(startInd: endInd, :);

% return the single row (many columns) of the averaged spectras

averageIntensitySpectra = mean(relevantRows);

end







