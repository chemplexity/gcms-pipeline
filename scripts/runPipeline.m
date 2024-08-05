% load data, process data, detect peaks, and update database

function data = runPipeline(db)

data = ImportAgilent();
CreateDatabase('filename', db);

% data = preprocessData(data, timeStart, timeEnd)

data = detectPeaksInData(data);

preppedDataSamples = prepareDataSamples(data);
UpdateDatabaseSamples(db, preppedDataSamples);

for i=1: length(data)

    preppedDataPeaks = prepareDataPeaks(db, data, i);
    UpdateDatabasePeaks(db, preppedDataPeaks);

end
