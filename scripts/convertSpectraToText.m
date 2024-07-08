function [channelString, intensityString] = convertSpectraToText(channelArray, intensityArray)

% ------------------------------------------------------------------------
% Method      : convertSpectraToText
% Description : converts channelArray and intensityArray each to a comma
% separated text string
% ------------------------------------------------------------------------

channelString = strjoin(compose("%.13f", channelArray), ",");

intensityString = strjoin(compose("%.13f", intensityArray), ",");