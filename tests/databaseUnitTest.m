cd ..
data = ImportAgilent('file', './examples/data');
cd tests
%% CreateDatabase

% Test case 1 (check wrong directory)

% assumes you're starting in the tests directory, run using
% runtests()
CreateDatabase();
assert(0 == isfile('./src/database/GCMS_Database.db'));

% Test case 2 (check existing database)
cd ..
CreateDatabase();
numFiles = length(dir('./src/database'));
CreateDatabase();
currNumFiles = length(dir('./src/database'));
assert(numFiles == currNumFiles);

% Test case 3 (general case)
delete './src/database/GCMS_Database.db'
CreateDatabase()
assert(1 == isfile('./src/database/GCMS_Database.db'));

%% prepareDataSamples

% Test case 1
preppedData = prepareDataSamples(data);
assert(length(fieldnames(preppedData)) == 23);
assert(isfield(preppedData, 'md5_checksum'));
assert(length({preppedData.md5_checksum}) == length(preppedData));

%% UpdateDatabaseSamples

% Test case 1 (checks for closed connection)
conn = sqlite('/Users/isabella/Desktop/gcms-pipeline/src/database/GCMS_Database.db');
close(conn);
preppedData = prepareDataSamples(data);
result = UpdateDatabaseSamples(conn, preppedData);
assert(strcmp(result, 'connection is closed'));

% Test case 2 (checks for duplicate data)
duplicateData = ImportAgilent('file', {'./examples/data/Ketones Mix 100ngmL.D', ...
    './examples/data/Ketones Mix 100ngmL.D'});

conn = sqlite('./src/database/GCMS_Database.db');
preppedDuplicates = prepareDataSamples(duplicateData);
dupResult = UpdateDatabaseSamples(conn, preppedDuplicates);
assert(strcmp(dupResult, 'remove duplicate files from input and try again'));

% Test case 3 (general case)
conn = sqlite('./src/database/GCMS_Database.db');
preppedData = prepareDataSamples(data);
result = UpdateDatabaseSamples(conn, preppedData);
assert(strcmp(result, 'added samples: 2'));