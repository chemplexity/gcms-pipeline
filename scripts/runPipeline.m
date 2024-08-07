function data = runPipeline(timeStart, timeEnd, db)

% ------------------------------------------------------------------------
% Method      : runPipeline()
% Description : allows the user to import data using the ImportAgilent()
% gui, creates a SQL database with the passed in db name (or prints that
% the database already exists), preprocesses the data, detects peaks in the
% data, prepares the samples and peaks data, and updates the samples and
% peaks tables in the database
% ------------------------------------------------------------------------

data = ImportAgilent();
CreateDatabase('filename', db);
data = preprocessData(data(1), timeStart, timeEnd);
data = detectPeaksInData(data);

preppedDataSamples = prepareDataSamples(data);
UpdateDatabaseSamples(db, preppedDataSamples);

for i=1:length(data)

    preppedDataPeaks = prepareDataPeaks(db, data, i);
    UpdateDatabasePeaks(db, preppedDataPeaks(i).peaks);

end
