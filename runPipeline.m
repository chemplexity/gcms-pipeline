function data = runPipeline(db, library, varargin)

% ------------------------------------------------------------------------
% Method      : runPipeline()
% Description : allows the user to import data using the ImportAgilent()
% gui, creates a SQL database with the passed in db name (or prints that
% the database already exists), preprocesses the data, detects peaks in the
% data, prepares the samples and peaks data, and updates the samples and
% peaks tables in the database
% ------------------------------------------------------------------------

% ---------------------------------------
% Defaults
% ---------------------------------------
default.fileName = [];
default.timeStart = [];
default.timeEnd = [];

% ---------------------------------------
% Input
% ---------------------------------------
p = inputParser;

addOptional(p, 'fileName', default.fileName);
addOptional(p, 'timeStart', default.timeStart);
addOptional(p, 'timeEnd', default.timeEnd);

parse(p, varargin{:});

% ---------------------------------------
% Parse
% ---------------------------------------
options.fileName = p.Results.fileName;
options.timeStart = p.Results.timeStart;
options.timeEnd = p.Results.timeEnd;

% -----------------------------------------
% Import and Prepare Data
% -----------------------------------------
if isempty(options.fileName)
    data = ImportAgilent();
else
    data = ImportAgilent('file', options.fileName);
end

CreateDatabase('filename', db);
data = preprocessData(data, options.timeStart, options.timeEnd);
data = addChecksum(data);
data = detectPeaksInData(data);
data = performSpectralMatch(data, library);

% -----------------------------------------
% Update SQL Databases
% -----------------------------------------

preppedDataSamples = prepareDataSamples(data);
UpdateDatabaseSamples(db, preppedDataSamples);

% for sample reprocessing, we'll want to delete all the peaks associated
% with the sample & upload the new peak table

for i=1:length(data)

    preppedDataPeaks = prepareDataPeaks(db, data, i);
    UpdateDatabasePeaks(db, preppedDataPeaks(i).peaks);

end