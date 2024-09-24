% -----------------------------------------------
% GC/MS Pipeline Setup Script
% https://github.com/chemplexity/gcms-pipeline
% -----------------------------------------------

% Press the green 'Run' button in the Matlab editor to complete setup
% If 'setup.m' is not found in the current folder or on the Matlab path, select 'Change Folder'
projectPath = fileparts(mfilename("fullpath"));

% This code adds the project directory to the current path in order to run
addpath(genpath(projectPath));
savepath();