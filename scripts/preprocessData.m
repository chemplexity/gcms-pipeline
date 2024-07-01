function data = preprocessData(data)

% for loop

% step 1 - crop signal by time
    % figure out good start end times 

% step 2 - apply centroid algorithm to mz, y
    % data(i).mz, data(i).y = centroid(data(i).mz, data(i).y)
    
% step 3a - calculate baseline 
    % compute baselines for each intensity 

% step 3b - subtract baselines
    % subtract each intensity row - baseline 
    % data(i).intensity(:,i) = data(i).intensity(:,i) - baseline(:,i)

timeStart = 10;
timeEnd = 60;
baselineSmoothness = 1E7;
baselineAsymmetry = 1E-4;

for i=1: size(data, 1)
    data(i) = cropDataByTimeRange(data(i), timeStart, timeEnd);
    [data(i).channel, data(i).intensity] = Centroid(data(i).channel, data(i).intensity);

    for j=1: size(data(i).intensity, 2)
        intColumn = data(i).intensity(:, j);
        b = Baseline(intColumn, 'smoothness', baselineSmoothness, 'asymmetry', baselineAsymmetry);
        data(i).intensity(:, j) = data(i).intensity(:, j) - b(:, 1);
    end
end

end
