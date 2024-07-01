% Unit test placeholder

% lookupTimeIndex
data = ImportAgilent('file', './examples/data/Ketones Mix 100ngmL.D');

%% lookupTimeIndex (3 tests)

% Test case 1
testInput = 0.334133333333333;
expectedOutput = 86;

actualOutput = lookupTimeIndex(data(1).time, testInput);
assert(actualOutput == expectedOutput);

% Test case 2


% Test case 3


%% getAverageSpectraOfTimeRange (3 tests)

% Test the length of # columns averaged spectra is correct, and 1 row



%% cropDataByTimeRange (3 tests)

% Assert start time is correct 

% Assert end time is correct 


%% preprocessData (1 tests)

% Limit to 1 test

% save the num col before preproccesing, then assert that after centroiding
% num of cols is less than before

% assert the time ranges are correct

% assert baseline is present





