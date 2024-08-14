function plotMassSpectraMatch(data, sampleIndex, peakIndex)

options.xlimits = [50, 600];

peakMz = data(sampleIndex).peaks(peakIndex).mz;
peakIntensity = Normalize(data(sampleIndex).peaks(peakIndex).intensity);

if isempty(data(sampleIndex).peaks(peakIndex).library_match)
    return
end

matchMz = data(sampleIndex).peaks(peakIndex).library_match(1).mz;
matchIntensity = Normalize(data(sampleIndex).peaks(peakIndex).library_match(1).intensity);

[peakMz, peakIntensity] = addZeroPadding(peakMz, peakIntensity, options, 0.1);
[matchMz, matchIntensity] = addZeroPadding(matchMz, matchIntensity, options, 0.1);

cla;
plot(peakMz, peakIntensity, 'color', 'black', 'linewidth', 1);
hold all;
plot(matchMz, -matchIntensity, 'color', 'red', 'linewidth', 1);

compoundName = strsplit(data(sampleIndex).peaks(peakIndex).library_match(1).compound_name, ';');
compoundName = compoundName{1};

plotTitle = [compoundName, ' - ', num2str(round(data(sampleIndex).peaks(peakIndex).match_score),3)]; 
title(plotTitle);

end

function [mz, y] = addZeroPadding(mz, y, options, mzStep)

% Get average distance between mz points
if mean(diff(mz)) < 1 && length(mz) >= 100
    return
end

if isempty(options.xlimits)
    minMz = mz(1);
    maxMz = mz(end);
else
    minMz = min([mz(1), options.xlimits(1)]);
    maxMz = max([mz(end), options.xlimits(2)]);
end

mz0 = [];
y0 = [];
idx = 1;

% Fill in resampled arrays with zeros
for i = minMz:mzStep:maxMz
   
    if idx > length(mz) || i < mz(idx)
        mz0(end+1) = i;
        y0(end+1) = 0;
    end

    while idx <= length(mz) && i >= mz(idx)
        mz0(end+1) = mz(idx);
        y0(end+1) = y(idx);
        idx = idx + 1;
    end
end

mz = mz0;
y = y0;

end
