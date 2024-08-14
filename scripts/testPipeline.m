%% Load library
libraryFile = './examples/library/GCMS DB-Public-KovatsRI-VS3.msp';
library = ImportNIST('file', libraryFile);

%% Cleanup library
library = CleanupLibrary(library, ...
    'min_points', 5, ...
    'min_mz', 50, ...
    'max_mz', 600);

%% Import data
data = ImportAgilent();

%% Validate data (remove non-MS files)
data = validateData(data);

%% Plot TIC data (initialize)
idx = 1;

plot(data(idx).time, data(idx).intensity(:,1));

%% Plot TIC data (increment index)
idx = idx + 1;

if idx > length(data)
    idx = 1;
end

plot(data(idx).time, data(idx).intensity(:,1));
fprintf([num2str(idx), ': ', data(idx).sample_name, '\n']);

%% Preprocess data
startIndex = [];
endIndex = [];

data = preprocessData(data, ...
    'startIndex', startIndex, ...
    'endIndex', endIndex);

%% Detect peaks
data = detectPeaksInData(data, ...
    'startIndex', startIndex, ...
    'endIndex', endIndex, ...
    'minPeakHeight', 2E4);

%% Plot peaks (initialize)
idx = 1;

plotPeaksInData(data, idx);

%% Plot peaks (increment index)
idx = idx + 1;

if idx > length(data)
    idx = 1;
end

plotPeaksInData(data, idx);

%% Perform spectral matching
startIndex = [];
endIndex = [];

data = performSpectralMatch(data, library,...
    'minScore', 70, ...
    'startIndex', startIndex, ...
    'endIndex', endIndex, ...
    'minMz', 50, ...
    'maxMz', 600);

%% Convert all peaks data to user-friendly data structure
peaksData = reformatPeaksData(data);

%% Plot mass spectra of matches (initialize)
idx = 1;
jdx = 1;

plotMassSpectraMatch(data, idx, jdx);

%% Plot mass spectra of matches (manual increment) 
jdx = jdx + 1;

if jdx > length(data(idx).peaks)
    jdx = 1;
    idx = idx + 1;
end

if idx > length(data)
    idx = 1;
end

if isempty(data(idx).peaks(jdx).library_match)
    fprintf(['[ERROR] No match at sample index: ', num2str(idx), ', peak index: ', num2str(jdx), '\n']);
end

plotMassSpectraMatch(data, idx, jdx, 50);

%% Plot mass spectra of matches (auto) 
while true
    jdx = jdx + 1;
    
    if jdx > length(data(idx).peaks)
        jdx = 1;
        idx = idx + 1;
    end
    
    if idx > length(data)
        idx = 1;
    end
    
    if isempty(data(idx).peaks(jdx).library_match)
        fprintf(['[ERROR] No match at sample index: ', num2str(idx), ', peak index: ', num2str(jdx), '\n']);
        continue;
    end

    plotMassSpectraMatch(data, idx, jdx, 50);

    pause(2);
end