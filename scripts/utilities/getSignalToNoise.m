function data = getSignalToNoise(data, sampleIndex)

if ~isfield(data, 'peaks')
    return
end

x = data(sampleIndex).time;
y = data(sampleIndex).intensity(:,1);

peaks = data(sampleIndex).peaks;

noiseX = x;
noiseY = y;

for i = 1:length(peaks)
    noiseFilter = noiseX >= peaks(i).xmin & noiseX <= peaks(i).xmax;
    noiseX(noiseFilter) = [];
    noiseY(noiseFilter) = [];
end

for i = 1:length(peaks)

    noiseWindow = peaks(i).width * 20;

    % Left side noise
    noiseStart = peaks(i).xmin - noiseWindow;
    noiseEnd = peaks(i).xmin;

    noiseFilter = noiseX >= noiseStart & noiseX <= noiseEnd;
    noiseLeftX = noiseX(noiseFilter);
    noiseLeftY = noiseY(noiseFilter);

    if length(noiseLeftX) > 1
        p = polyfit(noiseLeftX, noiseLeftY, 1);
        noiseLeftCenterX = peaks(i).time;
        noiseLeftCenterY = p(1) * noiseLeftCenterX + p(2);
        peaks(i).snr =  peaks(i).ymax / noiseLeftCenterY;
    else
        peaks(i).snr = 0;
    end

    % Right side noise
    noiseStart = peaks(i).xmax;
    noiseEnd = peaks(i).xmax + noiseWindow;

    noiseFilter = noiseX >= noiseStart & noiseX <= noiseEnd;
    noiseRightX = noiseX(noiseFilter);
    noiseRightY = noiseY(noiseFilter);

    if length(noiseRightX) > 1
        p = polyfit(noiseRightX, noiseRightY, 1);
        noiseRightCenterX = peaks(i).time;
        noiseRightCenterY = p(1) * noiseRightCenterX + p(2);
        peaks(i).snr = max([(peaks(i).ymax / noiseRightCenterY), peaks(i).snr]);
    end

    if peaks(i).snr == 0
        peaks(i).snr = peaks(i).ymax / peaks(i).ymin;
    end
    
    if peaks(i).snr < 0
        peaks(i).snr = 0;
    end
    
end

data(sampleIndex).peaks = peaks;

