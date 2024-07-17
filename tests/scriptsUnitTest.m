cd ..
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

assert(abs(expStartTime - actStartTime) < 1E-15);
assert(abs(expEndTime - actEndTime) < 1E-15);

% Test case 2
croppedData = cropDataByTimeRange(data(1), 0.1210, 0.1310);
expStartTime = 0.122000000000000;
expEndTime = 0.130733333333333;

actStartTime = croppedData.start_time;
actEndTime = croppedData.end_time;

assert(abs(expStartTime - actStartTime) < 1E-15);
assert(abs(expEndTime - actEndTime) < 1E-15);

% Test case 3
croppedData = cropDataByTimeRange(data(1), 0.107466666666667, 0.107466666666667);
expStartTime = 0.107466666666667;
expEndTime = 0.107466666666667;

actStartTime = croppedData(1).start_time;
actEndTime = croppedData(1).end_time;

assert(abs(expStartTime - actStartTime) < 1E-15);
assert(abs(expEndTime - actEndTime) < 1E-15);

%% preprocessData (1 tests)

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
assert(abs(startTime - actStartTime) < 1E-15);
assert(abs(endTime - actEndTime) < 1E-15);
assert(isfield(processedData, 'baseline'));

%% convertSpectraToText (3 tests)

% Test case 1
chanArray = [0, 14.9000000000000, 15, 15.1000000000000, 15.2000000000000, 15.3000000000000];
intArray = [676507, 0, 0, 0, 0, 0, 0, 0, 0];

expChanString = '0.0000, 14.9000, 15.0000, 15.1000, 15.2000, 15.3000';
expIntString = '676507, 0, 0, 0, 0, 0, 0, 0, 0';

[actChanString, actIntString] = convertSpectraToText(chanArray, intArray);

assert(strcmp(expChanString, actChanString));
assert(strcmp(expIntString, actIntString));

% Test case 2
chanArray = [1.0000000, 2.00000000, 3.33333333, 4.444444];
intArray = [0, 0, 0, 13, 0, 0];

expChanString = '1.0000, 2.0000, 3.3333, 4.4444';
expIntString = '0, 0, 0, 13, 0, 0';

[actChanString, actIntString] = convertSpectraToText(chanArray, intArray);

assert(strcmp(expChanString, actChanString));
assert(strcmp(expIntString, actIntString));

% Test case 3
chanArray = [0, 10, 10.1000000000000, 10.2000000000000, 10.3000000000000, 10.4000000000000];
intArray = [666362, 0, 0, 4, 0, 0, 4];

expChanString = '0.0000, 10.0000, 10.1000, 10.2000, 10.3000, 10.4000';
expIntString = '666362, 0, 0, 4, 0, 0, 4';

[actChanString, actIntString] = convertSpectraToText(chanArray, intArray);

assert(strcmp(expChanString, actChanString));
assert(strcmp(expIntString, actIntString));