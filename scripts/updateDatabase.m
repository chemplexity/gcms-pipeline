function updateDatabase(data, varargin)

% ---------------------------------------
% Defaults
% ---------------------------------------
default.filename = [];
default.initialLibrary = [];

% ---------------------------------------
% Input
% ---------------------------------------
p = inputParser;
addOptional(p, 'filename', default.filename);

parse(p, varargin{:});

% ---------------------------------------
% Parse
% ---------------------------------------
options.filename = p.Results.filename;

% ---------------------------------------
% Update Database
% ---------------------------------------
% Create database (if none exists)
if isempty(options.filename) 
    db = CreateDatabase();
else
    db = options.filename;
end

% Update samples table
samplesData = prepareDataSamples(data);
UpdateDatabaseSamples(db, samplesData);

% Update library table
for i=1:length(data)
    count = 0;
    fprintf(['[', num2str(i), '/', num2str(length(data)), '] Adding unmatched peaks to Library\n']);
    for j=1: length(data(i).peaks)
        peak = data(i).peaks(j);
        % if peak does not have a library match
        match = peak.library_match;
        if isempty(match)
            nist_peak = ExportNIST(data(i), j);
            lib_peak = prepareDataLibrary(nist_peak);
            UpdateDatabaseLibrary(db, lib_peak)
            data(i).peaks(j).library_match = nist_peak;
            count = count + 1;
        end
    end
    fprintf(['[FINISH] ', num2str(count), ' peaks added to Library\n\n'])
end

% Update peaks table (adds all peaks)
for i=1:length(samplesData)
    data = prepareDataPeaks(db, data, i);
    UpdateDatabasePeaks(db, data(i).peaks);
end
