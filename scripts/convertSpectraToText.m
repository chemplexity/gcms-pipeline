function [channelString, intensityString] = convertSpectraToText(channelArray, intensityArray)

% ------------------------------------------------------------------------
% Method      : convertSpectraToText
% Description : converts channelArray and intensityArray each to a comma
% separated text string
% ------------------------------------------------------------------------

channelString = strjoin(compose("%.4f", channelArray), ", ");

intensityString = strjoin(compose("%.0f", intensityArray), ", ");