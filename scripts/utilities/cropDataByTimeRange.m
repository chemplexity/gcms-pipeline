function data = cropDataByTimeRange(data, timeStart, timeEnd)

% ------------------------------------------------------------------------
% Method      : cropDataByTimeRange
% Description : crops the time and intensity data to only include the
% passed in time range; updates the start time, end time, and number of
% records for the data accordingly
% ------------------------------------------------------------------------

for i=1: size(data, 1)

    [startInd, endInd] = lookupTimeRangeIndex(data(i).time, timeStart, timeEnd);
    data(i).time = data(i).time(startInd:endInd, 1);
    data(i).intensity = data(i).intensity(startInd:endInd, :);
    data(i).start_time = data(i).time(1);
    data(i).end_time = data(i).time(end);
    data(i).num_records = length(data(i).time);

end

end