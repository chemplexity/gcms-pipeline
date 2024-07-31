% load data, process data, detect peaks, and update database

function data = runPipeline(timeStart, timeEnd, db)

data = ImportAgilent();

data = preprocessData(data, timeStart, timeEnd);
peaks = detectPeaksInData(data, 1);

preppedDataSamples = prepareDataSamples(data);
UpdateDatabaseSamples(db, preppedDataSamples);

preppedDataPeaks = prepareDataPeaks(db, peaks, 1);
UpdateDatabasePeaks(db, preppedDataPeaks);
