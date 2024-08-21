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

% Test case 1 (checks for duplicate data)
duplicateData = ImportAgilent('file', {'./examples/data/Ketones Mix 100ngmL.D', ...
    './examples/data/Ketones Mix 100ngmL.D'});
preppedDuplicates = prepareDataSamples(duplicateData);

delete('./src/database/GCMS_Database.db');
CreateDatabase();

dupResult = UpdateDatabaseSamples('./src/database/GCMS_Database.db', ...
    preppedDuplicates);
assert(strcmp(dupResult, 'added samples: 1'));

% Test case 2 (general case)
delete('./src/database/GCMS_Database.db');
CreateDatabase();

preppedData = prepareDataSamples(data);
result = UpdateDatabaseSamples('./src/database/GCMS_Database.db', ...
    preppedData);
assert(strcmp(result, 'added samples: 2'));

%% getSampleIDFromChecksum

% Test case 1 (checksum doesn't exist)
delete('./src/database/GCMS_Database.db');
CreateDatabase();

ketonesMix = ImportAgilent('file', './examples/data/Ketones Mix 100ngmL.D');
preppedKetones = prepareDataSamples(ketonesMix);
UpdateDatabaseSamples('./src/database/GCMS_Database.db', preppedKetones);

sampleID = getSampleIDFromChecksum('./src/database/GCMS_Database.db', ...
    '282AD5F24A6B62D10100AD28347B2A1');
assert(isempty(sampleID));

% Test case 2 (checksum does exist)
sampleID = getSampleIDFromChecksum('./src/database/GCMS_Database.db', ...
    '2B82AD5F24A6B62D10100AD28347B2A1');
assert(strcmp("1", sampleID));

%% detectPeaksInData

% Test case 1
data = ImportAgilent('file', './examples/data/Ketones Mix 100ngmL.D');
data = detectPeaksInData(data, 1);
assert(isfield(data, 'peaks'));
assert(length(data(1).peaks) == 157);

% Test case 2
data = ImportAgilent('file', './examples/data/Ketones_Aldehydes_Mix 100 ngmL.D');
data = detectPeaksInData(data, 1);
assert(isfield(data, 'peaks'));
assert(length(data(1).peaks) == 166);

%% prepareDataPeaks

% Test case 1 
db = './src/database/GCMS_Database.db';
delete(db);
CreateDatabase();

data = ImportAgilent('file', './examples/data/Ketones Mix 100ngmL.D');
preppedSamples = prepareDataSamples(data);
UpdateDatabaseSamples(db, preppedSamples);
data = detectPeaksInData(data, 1);

preppedData = prepareDataPeaks(db, data, 1);
assert(length(fieldnames(preppedData)) == 15);
assert(isfield(preppedData, 'sample_id'));

%% UpdateDatabasePeaks

% Test case 1
db = './src/database/GCMS_Database.db';
delete(db);
CreateDatabase();

data = ImportAgilent('file', './examples/data/Ketones Mix 100ngmL.D');
preppedSamples = prepareDataSamples(data);
UpdateDatabaseSamples(db, preppedSamples);
data = detectPeaksInData(data, 1);

preppedData = prepareDataPeaks(db, data, 1);
result = UpdateDatabasePeaks('./src/database/GCMS_Database.db', ...
    preppedData);
assert(strcmp(result, 'added peaks: 157'));

%% PrepareDataLibrary

% Test case 1
library = ImportNIST('file', ...
    './examples/library/GCMS DB-Public-KovatsRI-VS3.msp');
preppedLibrary = prepareDataLibrary(library);

assert(length(fieldnames(preppedLibrary)) == 22);
assert(ischar(preppedLibrary(1).mz));
assert(ischar(preppedLibrary(1).intensity));

%% UpdateDatabaseLibrary

% Test case 1
db = './src/database/GCMS_Database.db';
delete(db);
CreateDatabase();

library = ImportNIST('file', ...
    './examples/library/GCMS DB-Public-KovatsRI-VS3.msp');
preppedLibrary = prepareDataLibrary(library(1:100));
result = UpdateDatabaseLibrary(db, preppedLibrary);

% assert(strcmp(result, 'added compounds: 100'));
