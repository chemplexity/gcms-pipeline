function textArray = convertDoubleArrayToText(doubleArray, precision)

% ------------------------------------------------------------------------
% Method      : convertDoubleArrayToText()
% Description : converts the passed in double array to a comma
% separated text string
% ------------------------------------------------------------------------

textArray = strjoin(compose(precision, doubleArray), ", ");


% precisions: .4f for channel, .0 for intensity, .6f for time