function peaks = performSpectralMatch(varargin)
% ------------------------------------------------------------------------
% Method      : performSpectralMatch
% Description : Match peak mass spectra against library spectra
% ------------------------------------------------------------------------
%
% ------------------------------------------------------------------------
% Syntax
% ------------------------------------------------------------------------
%   peaks = performSpectralMatch(peaks, library)
%   peaks = performSpectralMatch( __ , Name, Value)
%
% ------------------------------------------------------------------------
% Input (Required)
% ------------------------------------------------------------------------
%   peaks -- peaks data
%       struct
%
%   library -- NIST formatted library (from ImportNIST function)
%       struct
%
% ------------------------------------------------------------------------
% Input (Name, Value)
% ------------------------------------------------------------------------
%   'min_score' -- minimum required match score (0 to 100)
%       80 | number
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
default.min_score = 80;
default.min_mz = [];
default.max_mz = [];
default.mz_step = 1;

% ---------------------------------------
% Input
% ---------------------------------------
p = inputParser;

addRequired(p, 'peaks', @isstruct);
addRequired(p, 'library', @isstruct);

addParameter(p, 'min_score', default.min_score);
addParameter(p, 'min_mz', default.min_mz);
addParameter(p, 'max_mz', default.max_mz);
addParameter(p, 'mz_step', default.mz_step);

parse(p, varargin{:});

% ---------------------------------------
% Parse
% ---------------------------------------
peaks   = p.Results.peaks;
library = p.Results.library;

options.min_score   = p.Results.min_score;
options.min_mz      = p.Results.min_mz;
options.max_mz      = p.Results.max_mz;
options.mz_step     = p.Results.mz_step;

% ---------------------------------------
% Validate
% ---------------------------------------

% Input: peaks
if numel(peaks) <= 0
    fprintf('[ERROR] Peaks is empty...\n');
    return
end

if ~isfield(peaks, 'mz')
    fprintf('[ERROR] Peaks does not contain "mz" field...\n');
end

if ~isfield(peaks, 'mz')
    fprintf('[ERROR] Peaks does not contain "intensity" field...\n');
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
% Spectral matching
% ---------------------------------------
fprintf(['\n', repmat('-',1,50), '\n']);
fprintf(' Spectral Matching');
fprintf(['\n', repmat('-',1,50), '\n\n']);

fprintf(['[STATUS] Library contains ', num2str(length(library)), ' entries...\n']);
fprintf(['[STATUS] Performing spectral matching on ', num2str(length(peaks)), ' peaks...\n\n']);

for i = 1:length(peaks)

    fprintf(['[STATUS] Peak #', num2str(i), ' calculating...\n']);
    tic;

    matches = SpectralMatch( ...
        peaks(i).mz, ...
        peaks(i).intensity, ...
        library, ...
        'num_matches', 5, ...
        'min_score', options.min_score, ...
        'min_mz', options.min_mz, ...
        'max_mz', options.max_mz, ...
        'mz_step', options.mz_step);

    if isempty(matches)
        peaks(i).library_match = [];
        peaks(i).match_score = 0;
    else
        peaks(i).library_match = matches(1);
        peaks(i).match_score = matches(1).score;
    end

    fprintf([ ...
        '[STATUS] Peak #', num2str(i), ...
        ', Top Match: ', num2str(peaks(i).match_score), ...
        ', Compute Time: ', num2str(round(toc,2)), ' sec.\n']);

end

