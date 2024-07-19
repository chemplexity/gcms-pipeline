function [input,output] = concatenateTrainingData(trainingData)

% ------------------------------------------------------------------------
% Method      : concatenateTrainingData
% Description : concatenates all of the cells in trainingData into 
% one array with several rows
% ------------------------------------------------------------------------

input = vertcat(trainingData.yn);
output = vertcat(trainingData.yt);

end

