function data = getSignalToNoise(data, sampleIndex)

if ~isfield(data, 'peaks')
    return
end

minPoints = 10;
windowMultiplier = 20;
minWindowSize = 0.02 * windowMultiplier;

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

    peaks(i).snr = [];
    noiseWindow = peaks(i).width * windowMultiplier;

    if noiseWindow < minWindowSize
        noiseWindow = minWindowSize;
    end
    
    % Left side noise
    noiseStart = peaks(i).xmin - noiseWindow;
    noiseEnd = peaks(i).xmin;

    noiseFilter = noiseX >= noiseStart & noiseX <= noiseEnd;
    noiseLeftX = noiseX(noiseFilter);
    noiseLeftY = noiseY(noiseFilter);

    if length(noiseLeftX) >= minPoints
        p = polyfit(noiseLeftX, noiseLeftY, 1);
        
        % Get peak signal value
        peakLeftBaseline = p(1) * peaks(i).time + p(2);
        peakSignal = peaks(i).ymax - peakLeftBaseline;

        % Get noise value
        noiseLeft = (max(noiseLeftY) - min(noiseLeftY)) / 2;
        
        % Get signal to noise ration
        peaks(i).snr(end+1) = peakSignal / noiseLeft;
    end

    % Right side noise
    noiseStart = peaks(i).xmax;
    noiseEnd = peaks(i).xmax + noiseWindow;

    noiseFilter = noiseX >= noiseStart & noiseX <= noiseEnd;
    noiseRightX = noiseX(noiseFilter);
    noiseRightY = noiseY(noiseFilter);

    if length(noiseRightX) >= minPoints
        p = polyfit(noiseRightX, noiseRightY, 1);

        % Get peak signal value
        peakRightBaseline = p(1) * peaks(i).time + p(2);
        peakSignal = peaks(i).ymax - peakRightBaseline;
        noiseRight = (max(noiseRightY) - min(noiseRightY)) / 2;

        peaks(i).snr(end+1) = peakSignal / noiseRight;
    end

    peaks(i).snr = max(peaks(i).snr);

    if isempty(peaks(i).snr)
        peaks(i).snr = 0;
    end

    if peaks(i).snr < 0
        peaks(i).snr = 0;
    end
    
end

data(sampleIndex).peaks = peaks;

