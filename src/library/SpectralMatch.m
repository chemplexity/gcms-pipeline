function matches = SpectralMatch(varargin)
% ------------------------------------------------------------------------
% Method      : SpectralMatch
% Description : Match a mass spectra against a library of mass spectra
% ------------------------------------------------------------------------
%
% ------------------------------------------------------------------------
% Syntax
% ------------------------------------------------------------------------
%   matches = SpectralMatch(mz, intensity, library)
%   matches = SpectralMatch( __ , Name, Value)
%
% ------------------------------------------------------------------------
% Input (Required)
% ------------------------------------------------------------------------
%   mz -- mass values
%       array
%
%   intensity -- intensity values
%       array
%
%   library -- NIST formatted library (from ImportNIST function)
%       struct
%
% ------------------------------------------------------------------------
% Input (Name, Value)
% ------------------------------------------------------------------------
%   'num_matches' -- number of matches to return
%       5 (default) | number
%
%   'min_score' -- minimum required match score (0 to 100)
%       0 | number
%
%   'min_mz' -- minimum m/z to perform spectral matching
%       empty (default) | number
%
%   'max_mz' -- maximum m/z to perform spectral matching
%       empty (default) | number
%
%   'mz_step' -- m/z resolution to perform spectral matching
%       1 (default) | number
%
% ------------------------------------------------------------------------
% Examples
% ------------------------------------------------------------------------
%   matches = SpectralMatch(mz, intensity, library)
%   matches = SpectralMatch(mz, intensity, library, 'num_matches', 10)
%   matches = SpectralMatch(mz, intensity, library, 'min_score', 90)

% ---------------------------------------
% Defaults
% ---------------------------------------
default.num_matches = 5;
default.min_score = 0;
default.min_mz = [];
default.max_mz = [];
default.mz_step = 1;

% ---------------------------------------
% Input
% ---------------------------------------
p = inputParser;

addRequired(p, 'mz', @ismatrix);
addRequired(p, 'intensity', @ismatrix);
addRequired(p, 'library', @isstruct);

addParameter(p, 'num_matches', default.num_matches);
addParameter(p, 'min_score', default.min_score);
addParameter(p, 'min_mz', default.min_mz);
addParameter(p, 'max_mz', default.max_mz);
addParameter(p, 'mz_step', default.mz_step);

parse(p, varargin{:});

% ---------------------------------------
% Parse
% ---------------------------------------
mz        = p.Results.mz;
intensity = p.Results.intensity;
library   = p.Results.library;

options.num_matches = p.Results.num_matches;
options.min_score   = p.Results.min_score;
options.min_mz      = p.Results.min_mz;
options.max_mz      = p.Results.max_mz;
options.mz_step     = p.Results.mz_step;

% ---------------------------------------
% Validate
% ---------------------------------------

% Input: mz
if numel(mz) <= 0
    fprintf('[ERROR] mz is empty...\n');
    return
end

% Input: intensity
if numel(intensity) <= 0
    fprintf('[ERROR] intensity is empty...\n');
    return
end

if length(mz) ~= length(intensity)
    fprintf('[ERROR] mz and intensity are different lengths...\n');
    return
end

% Input: library
if numel(library) <= 0
    fprintf('[ERROR] Library is empty...\n');
    return
end

if ~isfield(library, 'mz')
    fprintf('[ERROR] Library does not contain "mz" field...\n');
end

if ~isfield(library, 'intensity')
    fprintf('[ERROR] Library does not contain "intensity" field...\n');
end

% Parameter: 'num_matches'
if options.num_matches < 0
    options.num_matches = 1;
end

% Parameter: 'min_score'
if options.min_score < 0
    options.min_score = 0;
end

% Parameter: 'min_mz'
if ~isempty(options.min_mz) && options.min_mz < 0
    options.min_mz = [];
end

% Parameter: 'max_mz'
if ~isempty(options.max_mz) && options.max_mz < 0
    options.max_mz = [];
end

% Parameter: 'mz_step'
if options.mz_step < 0
    options.mz_step = 1;
end

% ---------------------------------------
% Filter library data by m/z
% ---------------------------------------
removeIndex = [];

for i = 1:length(library)

    if isempty(library(i).mz)
        continue
    elseif isempty(options.min_mz) && isempty(options.max_mz)
        break
    end
    
    if ~isempty(options.min_mz) && ~isempty(options.max_mz)
        filter = library(i).mz >= options.min_mz(1) & library(i).mz <= options.max_mz(1);
    elseif ~isempty(options.min_mz)
        filter = library(i).mz >= options.min_mz(1); 
    elseif ~isempty(options.max_mz)
        filter = library(i).mz <= options.max_mz(1);
    else
        filter(1:length(library(i).mz)) = false;
    end
   
    library(i).mz = library(i).mz(filter);
    library(i).intensity = library(i).intensity(filter);

    if isempty(library(i).mz)
        removeIndex(end+1) = i;
    end
end

library(removeIndex) = [];

% ---------------------------------------
% Prepare library data
% ---------------------------------------
min_mz = min(cellfun(@(x) min(x), {library.mz}));
max_mz = max(cellfun(@(x) max(x), {library.mz}));
mz_span = max_mz - min_mz + 1;

library_mz = min_mz : options.mz_step : max_mz;
library_intensity = zeros(length(library(:,1)), mz_span);

% Fill in library intensity
for i = 1:length(library(:,1))
    
    % Get index for each m/z value
    for j = 1:length(library(i).mz)
        index = round(library(i).mz(j)) - min_mz + 1;
        library_intensity(i, index) = library(i).intensity(j);
    end
end

% Normalize library entries intensity
ymin = min(library_intensity,[],2);
ymax = max(library_intensity,[],2);

library_intensity = bsxfun(@rdivide,...
    bsxfun(@minus, library_intensity, ymin),...
    bsxfun(@minus, ymax, ymin));

% ---------------------------------------
% Filter user data by m/z
% ---------------------------------------
user_filter = mz >= min_mz & mz <= max_mz;
mz = mz(user_filter);
intensity = intensity(user_filter);

% ---------------------------------------
% Prepare user data
% ---------------------------------------
user_intensity = zeros(1, length(library_mz));

% Bin user data by m/z
for i = 1:length(mz(1,:))
    
    % Get index to transfer intensity value to
    index = find(library_mz == round(mz(1,i)));
    
    % Sum intensity values if both are same m/z bin
    user_intensity(1, index) = user_intensity(1, index) + intensity(1,i);
end

% Normalize user intensity
user_intensity = (user_intensity - min(user_intensity)) / (max(user_intensity) - min(user_intensity));

% ---------------------------------------
% Perform spectral matching
% ---------------------------------------
spectral_match_1 = sum((user_intensity .* library_intensity) .^ 0.5, 2);
spectral_match_2 = (sum(library_intensity, 2) .* sum(user_intensity)) .^ 0.5;
spectral_match = spectral_match_1 ./ spectral_match_2 .* 100;

% ---------------------------------------
% Get top matches
% ---------------------------------------
top_match = sort(unique(spectral_match(spectral_match >= options.min_score)), 'descend');
top_match_index = 1;

matches = fieldnames(library)';
matches{end+1} = 'score';
matches{2,1} = {};
matches = struct(matches{:});

if isempty(top_match)
    return
end

% Populate output with top matches (w/ no duplicates)
while length(matches) < options.num_matches
    if top_match_index > length(top_match)
        break
    end

    match_index = find(spectral_match == top_match(top_match_index));
    
    % Check for duplicates
    if isscalar(match_index)
        match = library(match_index);
        match.score = top_match(top_match_index);
        matches(end+1) = match;
    else
        match_mz = unique(cell2mat({library(match_index).compound_exact_mass}));
        
        for i = 1:length(match_index)
            match = library(match_index(i));
            match.score = top_match(top_match_index);

            if any(match.compound_exact_mass == match_mz)
                matches(end+1) = match;
                match_mz(match_mz == match.compound_exact_mass) = [];
            end

            if isempty(match_mz) 
                break
            end
        end
    end
    
    top_match_index = top_match_index + 1;
end

