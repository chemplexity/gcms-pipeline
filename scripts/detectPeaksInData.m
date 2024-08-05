function data = detectPeaksInData(data)

% ------------------------------------------------------------------------
% Method      : detectPeaksInData()
% Description : runs the peak detection NN to detect all peaks in the 
% specified sample, then runs the peak fitting NN to fit all peaks and
% calculate their areas; stores all peak info in the peakList struct
% ------------------------------------------------------------------------

for i=1:length(data)

    peaks = peakfindNN(data(i).time, ...
        data(i).intensity(:, 1));
    peakList = [];

    for j=1:length(peaks)

        fittedPeakStruct = peakfitNN(data(i).time, ...
            data(i).intensity(:, 1), peaks(j, 1));
        fittedPeakStruct.peakCenterX = peaks(j, 1);
        fittedPeakStruct.peakCenterY = peaks(j, 2);
        peakList = [peakList, fittedPeakStruct];

    end

    data(i).peaks = peakList;
   
end

