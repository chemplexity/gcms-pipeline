% -----------------------------------------------
% GC/MS Pipeline (v0.9.1.20240917)
% https://github.com/chemplexity/gcms-pipeline
% -----------------------------------------------

% Paste path of GC/MS files to import
filePath = {};

% Import data files
data = ImportAgilent('file', filePath, 'depth', 3);

% Validate data (remove non-MS and invalid files)
data = validateData(data);

% Preprocess data
data = preprocessData(data, ...
    'startIndex', [], ...
    'endIndex', [], ...
    'applyTimeCrop', false, ...
    'applyCentroid', true, ...
    'applyBaseline', false, ...
    'timeStart', [], ...
    'timeEnd', [], ...
    'baselineSmoothness', 1E7, ...
    'baselineAsymmetry', 1E-4);

% Detect chromatographic peaks and save peak mass spectra
data = detectPeaksInData(data, ...
    'startIndex', [], ...
    'endIndex', [], ...
    'minMz', 40, ...
    'maxMz', 700, ...
    'maxError', 50, ...
    'minPeakHeight', 1E4, ...
    'minPeakWidth', 0.01, ...
    'minIonIntensity', 0.02, ...
    'minSignalToNoise', 2, ...
    'maxPeakOverlap', 0.5, ...
    'peakSensitivity', 250);

% Perform spectral matching on peaks (create new library from peak data)
[data, library] = performSpectralMatch(data, ...
    'startIndex', [], ...
    'endIndex', [], ...
    'minMz', 40, ...
    'maxMz', 700, ...
    'minScore', 70, ...
    'minPoints', 5, ...
    'addUnknownPeaksToLibrary', true, ...
    'overrideExistingMatches', true, ...
    'requireRetentionTimeMatch', true, ...
    'retentionTimeTolerance', 0.1);

% Convert peaks data to user-friendly data structure
peaksData = reformatPeaksData(data);

%% Save data to SQL database
updateDatabase(data, 'initialLibrary', library);