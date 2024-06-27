function data = preprocessData(data)

% for loop

% step 1 - crop signal by time
    % figure out good start end times 
timeStart = 10;
timeEnd = 60;

% step 2 - apply centroid algorithm to mz, y
    % data(i).mz, data(i).y = centroid(data(i).mz, data(i).y)


% step 3a - calculate baseline 
baselineSmoothness = 1E4;
baselineAsymmetry = 1E-3;

    % compute baselines for each intensity 


% step 3b - subtract baselines
    
    % subtract each intensity row - baseline 
    % data(i).intensity(:,i) = data(i).intensity(:,i) - baseline(:,i)

return data

end