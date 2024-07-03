% Unit test placeholder
data = ImportAgilent('file', './examples/data/Ketones Mix 100ngmL.D');

%% lookupTimeIndex (3 tests)

% Test case 1
testInput = 0.334133333333333;
expectedOutput = 86;

actualOutput = lookupTimeIndex(data(1).time, testInput);
assert(actualOutput == expectedOutput);

% Test case 2
testInput = 0.5510;
expectedOutput = 161;

actualOutput = lookupTimeIndex(data(1).time, testInput);
assert(actualOutput == expectedOutput);

% Test case 3
testInput = 40.0000;
expectedOutput = 13041;

actualOutput = lookupTimeIndex(data(1).time, testInput);
assert(actualOutput == expectedOutput);


%% getAverageSpectraOfTimeRange (3 tests)

% For all test cases
expectedNumColumns = 5235; 
expectedNumRows = 1;

% Test case 1
avgSpectra = getAverageSpectraOfTimeRange(data(1).time, data(1).intensity, ...
    0.0916166666666667, 0.113283333333333);

actualNumColumns = size(avgSpectra, 2);
actualNumRows = size(avgSpectra, 1);

assert(expectedNumColumns == actualNumColumns);
assert(expectedNumRows == actualNumRows);

% Test case 2
avgSpectra = getAverageSpectraOfTimeRange(data(1).time, data(1).intensity, ...
    0.0916166666666667, 37.9920333333333);

actualNumColumns = size(avgSpectra, 2);
actualNumRows = size(avgSpectra, 1);

assert(expectedNumColumns == actualNumColumns);
assert(expectedNumRows == actualNumRows);

% Test case 3
avgSpectra = getAverageSpectraOfTimeRange(data(1).time, data(1).intensity, ...
    0, 0.1);

actualNumColumns = size(avgSpectra, 2);
actualNumRows = size(avgSpectra, 1);

assert(expectedNumColumns == actualNumColumns);
assert(expectedNumRows == actualNumRows);


%% cropDataByTimeRange (3 tests)

% Test case 1
croppedData = cropDataByTimeRange(data(1), 0.0916166666666667, 0.110383333333333);
expStartTime = 0.0916166666666667;
expEndTime = 0.110383333333333;

actStartTime = croppedData.start_time;
actEndTime = croppedData.end_time;

assert(abs(expStartTime - actStartTime) < 0.000000000000001);
assert(abs(expEndTime - actEndTime) < 0.000000000000001);

% Test case 2
croppedData = cropDataByTimeRange(data(1), 0.1210, 0.1310);
expStartTime = 0.122000000000000;
expEndTime = 0.130733333333333;

actStartTime = croppedData.start_time;
actEndTime = croppedData.end_time;

assert(abs(expStartTime - actStartTime) < 0.000000000000001);
assert(abs(expEndTime - actEndTime) < 0.000000000000001);

% Test case 3
croppedData = cropDataByTimeRange(data(1), 0.107466666666667, 0.107466666666667);
expStartTime = 0.107466666666667;
expEndTime = 0.107466666666667;

actStartTime = croppedData(1).start_time;
actEndTime = croppedData(1).end_time;

assert(abs(expStartTime - actStartTime) < 0.000000000000001);
assert(abs(expEndTime - actEndTime) < 0.000000000000001);


%% preprocessData (1 tests)
% save the num col before preproccesing, then assert that after centroiding
% num of cols is less than before

% assert the time ranges are correct

% assert baseline is present

numChanCol = size(data(1).channel, 2);
numIntCol = size(data(1).intensity, 2);

processedData = preprocessData(data(1), 0.0916166666666667, 0.104566666666667);
startTime = 0.0916166666666667;
endTime = 0.104566666666667;

newNumChanCol = size(processedData(1).channel, 2);
newNumIntCol = size(processedData(1).intensity, 2);

actStartTime = processedData(1).start_time;
actEndTime = processedData(1).end_time;

assert(numChanCol > newNumChanCol);
assert(numIntCol > newNumIntCol);
assert(abs(startTime - actStartTime) < 0.000000000000001);
assert(abs(endTime - actEndTime) < 0.000000000000001);
assert(isfield(processedData, 'baseline'));

