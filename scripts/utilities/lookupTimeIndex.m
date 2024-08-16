function index = lookupTimeIndex(timeArray, timeValue)

% ------------------------------------------------------------------------
% Method      : lookupTimeIndex
% Description : returns the index of the closest absolute value match
% for timeValue in timeArray
% ------------------------------------------------------------------------

currSmallestDiff = [1, abs(timeArray(1) - timeValue)];

for i = 2:size(timeArray, 1)

    diff = abs(timeArray(i) - timeValue);

    if diff < currSmallestDiff(2)
        currSmallestDiff = [i, diff];

    elseif diff > currSmallestDiff(2) && timeArray(i) > timeValue
        break

    end 
    
end

    index = currSmallestDiff(1);

end