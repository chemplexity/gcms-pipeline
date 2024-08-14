%% Import data
data = ImportAgilent();

%% Validate data (remove non-MS files)
data = validateData(data);

%% Plot data (initialize)
idx = 1;

plot(data(idx).time, data(idx).intensity(:,1));

%% Plot data (increment index)
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

%% Load library
libraryFile = './examples/library/GCMS DB-Public-KovatsRI-VS3.msp';
library = ImportNIST('file', libraryFile);

%% Cleanup library
library = CleanupLibrary(library, ...
    'min_points', 5, ...
    'min_mz', 50, ...
    'max_mz', 600);

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
