function [indexStart, indexEnd] = lookupTimeRangeIndex(timeArray, timeStart, timeEnd)

% ------------------------------------------------------------------------
% Method      : lookupTimeRangeIndex
% Description : returns the indices of the best absolute value matches
% of the given start time and end time in the data.time array
% ------------------------------------------------------------------------

indexStart = lookupTimeIndex(timeArray, timeStart);

indexEnd = lookupTimeIndex(timeArray, timeEnd);

disp([indexStart, indexEnd]);

end