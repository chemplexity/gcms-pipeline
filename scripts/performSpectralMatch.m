function data = performSpectralMatch(data, library, varargin)
% ------------------------------------------------------------------------
% Method      : performSpectralMatch
% Description : Match peak mass spectra against library spectra
% ------------------------------------------------------------------------
%
% ------------------------------------------------------------------------
% Syntax
% ------------------------------------------------------------------------
%   data = performSpectralMatch(data, library)
%   data = performSpectralMatch( __ , Name, Value)
%
% ------------------------------------------------------------------------
% Input (Required)
% ------------------------------------------------------------------------
%   data -- data with peaks field
%       struct
%
%   library -- NIST formatted library (from ImportNIST function)
%       struct
%
% ------------------------------------------------------------------------
% Input (Name, Value)
% ------------------------------------------------------------------------
%   'minScore' -- minimum required match score (0 to 100)
%       80 | number
%
%   'minMz' -- minimum m/z to perform spectral matching
%       empty (default) | number
%
%   'maxMz' -- maximum m/z to perform spectral matching
%       empty (default) | number
%
%   'mzStep' -- m/z resolution to perform spectral matching
%       1 (default) | number
%
%   'startIndex' -- start index in data to process
%       1 (default) | number
%
%   'endIndex' -- end index in data to process
%       length(data) (default) | number
%
% ------------------------------------------------------------------------
% Examples
% ------------------------------------------------------------------------
%   data = SpectralMatch(data, library)
%   data = SpectralMatch(data, library, 'min_score', 90)

% ---------------------------------------
% Defaults
% ---------------------------------------
default.minScore = 80;
default.minMz = [];
default.maxMz = [];
default.mzStep = 1;
default.startIndex = 1;
default.endIndex = length(data);

% ---------------------------------------
% Input
% ---------------------------------------
p = inputParser;

addOptional(p, 'minScore', default.minScore);
addOptional(p, 'minMz', default.minMz);
addOptional(p, 'maxMz', default.maxMz);
addOptional(p, 'mzStep', default.mzStep);
addOptional(p, 'startIndex', default.startIndex);
addOptional(p, 'endIndex', default.endIndex);

parse(p, varargin{:});

% ---------------------------------------
% Parse
% ---------------------------------------
options.minScore   = p.Results.minScore;
options.minMz      = p.Results.minMz;
options.maxMz      = p.Results.maxMz;
options.mzStep     = p.Results.mzStep;
options.startIndex = p.Results.startIndex;
options.endIndex   = p.Results.endIndex;

% ---------------------------------------
% Validate
% ---------------------------------------

% Input: data
if numel(data) <= 0
    fprintf('[ERROR] Data is empty...\n');
    return
end

if ~isfield(data, 'peaks')
    fprintf('[ERROR] Data does not contain "peaks" field...\n');
end

for i = options.startIndex:options.endIndex
    if isempty(data(i).peaks)
        continue
    end

    if ~isfield(data(i).peaks, 'mz')
        fprintf('[ERROR] Peaks does not contain "mz" field...\n');
        return
    end
    
    if ~isfield(data(i).peaks, 'intensity')
        fprintf('[ERROR] Peaks does not contain "intensity" field...\n');
        return
    end
end

% Input: library
if numel(library) <= 0
    fprintf('[ERROR] Library is empty...\n');
    return
end

if ~isfield(library, 'mz')
    fprintf('[ERROR] Library does not contain "mz" field...\n');
    return
end

if ~isfield(library, 'intensity')
    fprintf('[ERROR] Library does not contain "intensity" field...\n');
    return
end

% Parameter: 'minScore'
if options.minScore < 0
options.minScore = 0;
end

% Parameter: 'minMz'
if ~isempty(options.minMz) && options.minMz < 0
    options.minMz = [];
end

% Parameter: 'maxMz'
if ~isempty(options.maxMz) && options.maxMz < 0
    options.maxMz = [];
end

% Parameter: 'mzStep'
if options.mzStep < 0
    options.mzStep = 1;
end

% Parameter: 'startIndex'
if isempty(options.startIndex)
    options.startIndex = default.startIndex;
end

if options.startIndex <= 0 || options.startIndex > length(data)
    options.startIndex = default.startIndex;
end

% Parameter: 'endIndex'
if isempty(options.endIndex)
    options.endIndex = default.endIndex;
end

if options.endIndex <= 0 || options.endIndex > length(data)
    options.endIndex = default.endIndex;
end

if options.endIndex < options.startIndex
    options.endIndex = options.startIndex;
end

% ---------------------------------------
% Status
% ---------------------------------------
fprintf(['\n', repmat('-',1,50), '\n']);
fprintf(' SPECTRAL MATCHING');
fprintf(['\n', repmat('-',1,50), '\n']);

fprintf([' OPTIONS  startIndex : ', num2str(options.startIndex), '\n']);
fprintf([' OPTIONS  endIndex   : ', num2str(options.endIndex), '\n']);
fprintf([' OPTIONS  minScore   : ', num2str(options.minScore), '\n']);
fprintf([' OPTIONS  minMz      : ', num2str(options.minMz), '\n']);
fprintf([' OPTIONS  maxMz      : ', num2str(options.maxMz), '\n\n']);

fprintf([' STATUS  Library contains ', num2str(length(library)), ' entries...\n']);
fprintf([' STATUS  Matching peaks in ', num2str(options.endIndex - options.startIndex + 1), ' files...', '\n\n']);

totalProcessTime = tic;
totalPeaks = 0;
totalMatches = 0;

for i = options.startIndex:options.endIndex

    m = num2str(i);
    n = num2str(options.endIndex);
    sampleName = strrep(data(i).sample_name, '%', '');

    fprintf([' [', [repmat('0', 1, length(n) - length(m)), m], '/', n, ']']);
    fprintf([' ', sampleName, ': START\n']);
    matchTime = tic;

    % -----------------------------------------
    % Check data
    % -----------------------------------------
    if isempty(data(i).peaks)
        fprintf([' [', [repmat('0', 1, length(n) - length(m)), m], '/', n, ']']);
        fprintf([' ', sampleName, ': END (no peaks...)\n\n']);
        continue
    end

    totalPeaks = totalPeaks + length(data(i).peaks);
    peaksMz = {data(i).peaks.mz};
    peaksIntensity = {data(i).peaks.intensity};

    % -----------------------------------------
    % Perform spectral matching on peaks
    % -----------------------------------------
    fprintf([' [', [repmat('0', 1, length(n) - length(m)), m], '/', n, ']']);
    fprintf([' ', sampleName, ': finding matches for ', num2str(length(peaksMz)), ' peaks...\n']);

    matches = SpectralMatch( ...
        peaksMz, ...
        peaksIntensity, ...
        library, ...
        'num_matches', 5, ...
        'min_score', options.minScore, ...
        'min_mz', options.minMz, ...
        'max_mz', options.maxMz, ...
        'mz_step', options.mzStep);
    
    % -----------------------------------------
    % Update data with matches
    % -----------------------------------------
    numPeaksWithMatches = sum(cellfun(@(x) length(x), matches) > 0);
    totalMatches = totalMatches + numPeaksWithMatches;

    fprintf([' [', [repmat('0', 1, length(n) - length(m)), m], '/', n, ']']);
    fprintf([' ', sampleName, ': found library matches for ', num2str(numPeaksWithMatches), ' peaks...\n']);

    for j = 1:length(matches)
        if isempty(matches{j})
            data(i).peaks(j).library_match = [];
            data(i).peaks(j).match_score = 0;
        else
            data(i).peaks(j).library_match = matches{j}(1);
            data(i).peaks(j).match_score = matches{j}(1).score;
        end
    end

    fprintf([' [', [repmat('0', 1, length(n) - length(m)), m], '/', n, ']']);
    fprintf([' ', sampleName, ': END (', parsetime(toc(matchTime)), ')\n\n']);

end

totalPeaks = num2str(totalPeaks);
totalMatches = num2str(totalMatches);
totalProcessTime = toc(totalProcessTime);

fprintf([' STATUS  Total peaks   : ', totalPeaks, '\n']);
fprintf([' STATUS  Total matches : ', totalMatches, '\n']);
fprintf([' STATUS  Total time    : ', parsetime(totalProcessTime), '\n']);

fprintf([repmat('-',1,50), '\n']);
fprintf(' EXIT');
fprintf(['\n', repmat('-',1,50), '\n']);

end

% ---------------------------------------
% Format time string
% ---------------------------------------
function str = parsetime(x)

if x > 60
    str = [num2str(x/60, '%.1f'), ' min'];
else
    str = [num2str(x, '%.1f'), ' sec'];
end

end