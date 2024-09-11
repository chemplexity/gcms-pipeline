function data = CleanupLibrary(varargin)
% ------------------------------------------------------------------------
% Method      : CleanupLibrary
% Description : Remove errors and incorrect items from NIST library
% ------------------------------------------------------------------------
%
% ------------------------------------------------------------------------
% Syntax
% ------------------------------------------------------------------------
%   library = CleanupLibrary(library)
%   library = CleanupLibrary( __ , Name, Value)
%
% ------------------------------------------------------------------------
% Input (Required)
% ------------------------------------------------------------------------
%   library -- NIST formatted library (from ImportNIST function...)
%       struct
%
% ------------------------------------------------------------------------
% Input (Name, Value)
% ------------------------------------------------------------------------
%   'min_points' -- minimum number of points in a compound mass spectra
%       5 (default) | number
%
%   'min_mz' -- minimum m/z in library spectra
%       empty (default) | number
%
%   'max_mz' -- maximum m/z in library spectra
%       empty (default) | number
%
% ------------------------------------------------------------------------
% Examples
% ------------------------------------------------------------------------
%   library = CleanupLibrary(library)
%   library = CleanupLibrary(library, 'min_points', 10)

% ---------------------------------------
% Defaults
% ---------------------------------------
default.min_points    = 5;
default.min_mz        = [];
default.max_mz        = [];
default.min_intensity = 0.01;

% ---------------------------------------
% Input
% ---------------------------------------
p = inputParser;

addRequired(p, 'library', @isstruct);

addParameter(p, 'min_points', default.min_points, @isscalar);
addParameter(p, 'min_mz', default.min_mz, @isscalar);
addParameter(p, 'max_mz', default.max_mz, @isscalar);
addParameter(p, 'min_intensity', default.min_intensity, @isscalar);

parse(p, varargin{:});

% ---------------------------------------
% Parse
% ---------------------------------------
library = p.Results.library;

options.min_points    = p.Results.min_points;
options.min_mz        = p.Results.min_mz;
options.max_mz        = p.Results.max_mz;
options.min_intensity = p.Results.min_intensity;

% ---------------------------------------
% Validate
% ---------------------------------------

% Input: library
if isfield(library, 'library')
    library = library.library;
end

if numel(library) <= 0
    return
end

if ~isfield(library, 'mz')
    fprintf('[ERROR] Library does not contain "mz" field');
end

if ~isfield(library, 'intensity')
    fprintf('[ERROR] Library does not contain "intensity" field');
end

% Parameter: 'min_points'
if options.min_points < 0
    options.min_points = 1;
end

% Parameter: 'min_mz'
if ~isempty(options.min_mz) && options.min_mz < 0
    options.min_mz = [];
end

% Parameter: 'max_mz'
if ~isempty(options.max_mz) && options.max_mz < 0
    options.max_mz = [];
end

% Parameter: 'min_intensity'
if isempty(options.min_intensity)
    options.min_intensity = default.min_intensity;
end

if options.min_intensity >= 100
    options.min_intensity = options.min_intensity / 100;
end

% ---------------------------------------
% Filter library entries by m/z
% ---------------------------------------
for i = 1:length(library)

    if isempty(library(i).mz)
        continue
    elseif isempty(options.min_mz) && isempty(options.max_mz)
        break
    end
    
    if ~isempty(options.min_mz) && ~isempty(options.max_mz)
        filter = library(i).mz >= options.min_mz(1) & library(i).mz <= options.max_mz(1);
    elseif ~isempty(xmin)
        filter = library(i).mz >= options.min_mz(1); 
    elseif ~isempty(xmax)
        filter = library(i).mz <= options.max_mz(1);
    else
        filter(1:length(library(i).mz)) = true;
    end
   
    library(i).mz = library(i).mz(filter);
    library(i).intensity = library(i).intensity(filter);
end

% ---------------------------------------
% Remove library entries by # of points
% ---------------------------------------
fprintf(['\n', repmat('-',1,50), '\n']);
fprintf(' CLEANUP LIBRARY');
fprintf(['\n', repmat('-',1,50), '\n']);

fprintf('[STATUS] Validating entries...\n\n');

delete_index = [];

for i = 1:length(library)
    
    % Remove any points < min_intensity
    intensityFilter = library(i).intensity ./ max(library(i).intensity) >= options.min_intensity;
    library(i).mz = library(i).mz(intensityFilter);
    library(i).intensity = library(i).intensity(intensityFilter);

    % Remove any spectra < min_points
    if length(library(i).mz) < options.min_points
        delete_index(end+1) = i;
        fprintf(['[STATUS] Removing row #', num2str(i), ' (NumPoints: ', num2str(length(library(i).mz)),')\n']);
    end
    
    % Remove any spectra with NaN values
    if any(isnan(library(i).mz))
        delete_index(end+1) = i;
        fprintf(['[STATUS] Removing row #', num2str(i), ' (NaN)\n']);
    end

    % Remove any spectra with invalid names
    invalidNames = {'Z artifact'};

    if any(strcmpi(library(i).compound_formula, invalidNames))
        delete_index(end+1) = i;
        fprintf(['[STATUS] Removing row #', num2str(i), ' (', library(i).compound_formula, ')\n']);
    end

    % Remove any spectra with invalid formula
    invalidFormula = {'SMILES: N/A', 'NA', 'Like tag compound', 'Labeled compound', 'Contaminated compound'};

    if any(strcmpi(library(i).compound_formula, invalidFormula))
        delete_index(end+1) = i;
        fprintf(['[STATUS] Removing row #', num2str(i), ' (', library(i).compound_formula, ')\n']);
    end

    % Create new uuid for item if none exists
    if isempty(library(i).db_id)
        library(i).db_id = char(java.util.UUID.randomUUID.toString);
    end
end

library(delete_index) = [];

fprintf(['\n[STATUS] Total rows removed: ', num2str(length(delete_index)), '\n']);

% Output format
data = struct();
data.library = library;
data.min_mz = options.min_mz;
data.max_mz = options.max_mz;
data.min_points = options.min_points;
data.min_intensity = options.min_intensity;

fprintf([repmat('-',1,50), '\n']);
fprintf(' EXIT');
fprintf(['\n', repmat('-',1,50), '\n']);
