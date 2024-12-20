%% Load library
libraryFile = './examples/library/GCMS DB-Public-KovatsRI-VS3.msp';
library = ImportNIST('file', libraryFile);

%% Cleanup library
library = CleanupLibrary(library, ...
    'min_points', 5, ...
    'min_mz', 40, ...
    'max_mz', 600);

%% Import data
data = ImportAgilent('depth', 5);

%% Validate data (remove non-MS files)
data = validateData(data);

%% Remove samples containing target string (e.g. solvent blanks)
removeIndex = [];
removeNames = {'dcm', 'blank'};

% Remove DCM and Blanks
for i = 1:length(data)
    if isempty(data(i).sample_name)
        [~, sampleName, ~] = fileparts(fileparts(data(i).file_name));
        data(i).sample_name = sampleName;
    end

    for j = 1:length(removeNames)
        if contains(lower(data(i).sample_name), removeNames{j})
            removeIndex(end+1) = i;
            break
        end
    end
end

data(removeIndex) = [];

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
    'minPeakHeight', 2E4, ...
    'minSignalToNoise', 2, ...
    'maxError', 50, ...
    'minMz', 40, ...
    'maxMz', 700);

%% Perform spectral matching
[data, library] = performSpectralMatch(data, library,...
    'minScore', 80, ...
    'minPoints', 5, ...
    'startIndex', startIndex, ...
    'endIndex', endIndex, ...
    'minMz', 40, ...
    'maxMz', 700, ...
    'addUnknownPeaksToLibrary', true);

%% Convert all peaks data to user-friendly data structure
peaksData = reformatPeaksData(data);

%% Plot mass spectra of matches (initialize)
idx = 1;
jdx = 1;

plotMassSpectraMatch(data, idx, jdx, 40);

%% Plot mass spectra of matches (manual increment) 
jdx = jdx + 1;

if jdx > length(data(idx).peaks) || isempty(data(idx).peaks)
    jdx = 1;
    idx = idx + 1;
end

if idx > length(data)
    idx = 1;
end

if isempty(data(idx).peaks(jdx).library_match)
    fprintf(['[ERROR] No match at sample index: ', num2str(idx), ', peak index: ', num2str(jdx), '\n']);
end

plotMassSpectraMatch(data, idx, jdx, 40);

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

    plotMassSpectraMatch(data, idx, jdx, 40);
    pause(2);
end

%% Plot chromatogram with library match labels (initialize)
idx = 1;

plotType = {'compound_name', 'compound_ontology'};
plotChromatogramWithLibraryMatches(data, idx, plotType{2});

%% Plot mass spectra of matches (manual increment) 
idx = idx + 1;

if idx > length(data)
    idx = 1;
end

plotType = {'compound_name', 'compound_ontology'};
plotChromatogramWithLibraryMatches(data, idx, plotType{2});

%% Plot mass spectra of matches (auto) 
while true
    idx = idx + 1;
    
    if idx > length(data)
        idx = 1;
    end
    
    plotType = {'compound_name', 'compound_ontology'};
    plotChromatogramWithLibraryMatches(data, idx, plotType{1});
    pause(3);
end