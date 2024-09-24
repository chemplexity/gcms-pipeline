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
addOptional(p, 'initialLibrary', default.initialLibrary);

parse(p, varargin{:});

% ---------------------------------------
% Parse
% ---------------------------------------
options.filename = p.Results.filename;
options.initialLibrary = p.Results.initialLibrary;

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

% Update peaks table
for i=1:length(samplesData)
    data = prepareDataPeaks(db, data, i, 'initialLibrary', options.initialLibrary);
    UpdateDatabasePeaks(db, data(i).peaks);
end
