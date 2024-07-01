function [indexStart, indexEnd] = lookupTimeRangeIndex(timeArray, timeStart, timeEnd)

% return best absolute value match of time start and time end

indexStart = lookupTimeIndex(timeArray, timeStart);
indexEnd = lookupTimeIndex(timeArray, timeEnd);
disp([indexStart, indexEnd]);
end


function index = lookupTimeIndex(timeArray, timeValue)

% function to lookup the index of time value x in time array

% find the closest index value of timeValue in time array

% closest absolute value of time value

ind = find(abs(timeArray - timeValue) < 0.0001);
TF = isempty(ind);

if TF == 1
    currSmallestDiff = [1, abs(timeArray(1) - timeValue)];

    for i = 2:length(timeArray)
    
        diff = abs(timeArray(i) - timeValue);
        if diff < currSmallestDiff(2)
            currSmallestDiff = [i, diff];
        elseif diff > currSmallestDiff(2) && timeArray(i) > timeValue
            break
        end
    end

    index = currSmallestDiff(1);
    
else 
    index = ind;
end
end

