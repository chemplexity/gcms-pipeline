function data = cropDataByTimeRange(data, timeStart, timeEnd)

% for loop for each row in data

    % lookup indices for each row

    % data(i).time = data(i).time(startIndex:endIndex, 1)
    % data(i).intensity = data(i).intensity(startIndex:endIndex, :)

    % data(i).start_time = data(i).time(1)
    % data(i).end_time = data(i).time(end)
    % data(i).num_records = length(data(i).time)

mySize = size(data, 1);
disp(mySize);
for i=1: size(data, 1)
    [startInd, endInd] = lookupTimeRangeIndex(data(i).time, timeStart, timeEnd);
    data(i).time = data(i).time(startInd:endInd, 1);
    data(i).intensity = data(i).intensity(startInd:endInd, :);

    data(i).start_time = data(i).time(1);
    data(i).end_time = data(i).time(end);
    data(i).num_records = length(data(i).time);
end
end