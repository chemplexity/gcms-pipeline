function data = detectPeaksInData(data, sampleIndex)

% ------------------------------------------------------------------------
% Method      : detectPeaksInData()
% Description : runs the peak detection NN to detect all peaks in the 
% specified sample, then runs the peak fitting NN to fit all peaks and
% calculate their areas; stores all peak info in the peakList struct
% ------------------------------------------------------------------------

peaks = peakfindNN(data(sampleIndex).time, ...
    data(sampleIndex).intensity(:, 1));

peakList = [];

for i=1:length(peaks)
    fittedPeakStruct = peakfitNN(data(sampleIndex).time, ...
        data(sampleIndex).intensity(:, 1), peaks(i, 1));
    fittedPeakStruct.peakCenterX = peaks(i, 1);
    fittedPeakStruct.peakCenterY = peaks(i, 2);
    peakList = [peakList, fittedPeakStruct];
end

data(sampleIndex).peaks = peakList;