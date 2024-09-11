function [data, library] = performSpectralMatch(data, varargin)
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
% ------------------------------------------------------------------------
% Input (Optional)
% ------------------------------------------------------------------------
%   library -- NIST formatted library (from ImportNIST function)
%       struct
%
% ------------------------------------------------------------------------
% Input (Name, Value)
% ------------------------------------------------------------------------
%   'startIndex' -- start index in data to process
%       1 (default) | number
%
%   'endIndex' -- end index in data to process
%       length(data) (default) | number
%
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
%   'minPoints' -- minimum number of points in peak spectrum to perform spectral matching
%       5 (default) | number
%
%   'addUnknownPeaksToLibrary' -- add peaks with no matches to library
%       false (default) | bool
%
%   'overrideExistingMatches' -- overwrite and ignore any existing matches
%       true (default) | bool
%
%   'requireRetentionTimeMatch' -- require matches to also be within the retention time tolerance
%       false (default) | bool
%
%   'retentionTimeTolerance' -- retention time tolerance window for matches
%       0.1 (default) | float
%
% ------------------------------------------------------------------------
% Examples
% ------------------------------------------------------------------------
%   [data, library] = performSpectralMatch(data, library);
%   [data, library] = performSpectralMatch(data, library, 'minScore', 70);

% ---------------------------------------
% Defaults
% ---------------------------------------
default.startIndex                = 1;
default.endIndex                  = -1;
default.minMz                     = [];
default.maxMz                     = [];
default.minScore                  = 80;
default.mzStep                    = 1;
default.minPoints                 = 5;
default.addUnknownPeaksToLibrary  = false;
default.overrideExistingMatches   = true;
default.requireRetentionTimeMatch = false;
default.retentionTimeTolerance    = 0.1;

% ---------------------------------------
% Input
% ---------------------------------------
p = inputParser;

addRequired(p, 'data', @isstruct);
addOptional(p, 'library', getLibraryStructure(), @isstruct);

addParameter(p, 'startIndex', default.startIndex);
addParameter(p, 'endIndex', default.endIndex);
addParameter(p, 'minMz', default.minMz);
addParameter(p, 'maxMz', default.maxMz);
addParameter(p, 'minScore', default.minScore);
addParameter(p, 'mzStep', default.mzStep);
addParameter(p, 'minPoints', default.minPoints);
addParameter(p, 'addUnknownPeaksToLibrary', default.addUnknownPeaksToLibrary);
addParameter(p, 'overrideExistingMatches', default.overrideExistingMatches);
addParameter(p, 'requireRetentionTimeMatch', default.requireRetentionTimeMatch);
addParameter(p, 'retentionTimeTolerance', default.retentionTimeTolerance);

parse(p, data, varargin{:});

% ---------------------------------------
% Parse
% ---------------------------------------
library                           = p.Results.library;
options.startIndex                = p.Results.startIndex;
options.endIndex                  = p.Results.endIndex;
options.minMz                     = p.Results.minMz;
options.maxMz                     = p.Results.maxMz;
options.minScore                  = p.Results.minScore;
options.mzStep                    = p.Results.mzStep;
options.minPoints                 = p.Results.minPoints;
options.addUnknownPeaksToLibrary  = p.Results.addUnknownPeaksToLibrary;
options.overrideExistingMatches   = p.Results.overrideExistingMatches;
options.requireRetentionTimeMatch = p.Results.requireRetentionTimeMatch;
options.retentionTimeTolerance    = p.Results.retentionTimeTolerance;

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
    return
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
if isfield(library, 'library')
    library = library.library;
end

if numel(library) <= 0
    library = getLibraryStructure();
end

if numel(library) > 0 && ~isfield(library, 'mz')
    fprintf('[ERROR] Library does not contain "mz" field...\n');
    return
end

if numel(library) > 0 && ~isfield(library, 'intensity')
    fprintf('[ERROR] Library does not contain "intensity" field...\n');
    return
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

if options.endIndex == -1
    options.endIndex = length(data);
end

if options.endIndex < options.startIndex
    options.endIndex = options.startIndex;
end

% Parameter: 'minMz'
if ~isempty(options.minMz) && options.minMz < 0
    options.minMz = [];
end

% Parameter: 'maxMz'
if ~isempty(options.maxMz) && options.maxMz < 0
    options.maxMz = [];
end

% Parameter: 'minScore'
if options.minScore < 0
    options.minScore = 0;
end

% Parameter: 'mzStep'
if options.mzStep < 0
    options.mzStep = 1;
end

% ---------------------------------------
% Status
% ---------------------------------------
fprintf(['\n', repmat('-',1,50), '\n']);
fprintf(' SPECTRAL MATCHING');
fprintf(['\n', repmat('-',1,50), '\n']);

fprintf([' OPTIONS  startIndex                : ', num2str(options.startIndex), '\n']);
fprintf([' OPTIONS  endIndex                  : ', num2str(options.endIndex), '\n']);
fprintf([' OPTIONS  minMz                     : ', num2str(options.minMz), '\n']);
fprintf([' OPTIONS  maxMz                     : ', num2str(options.maxMz), '\n']);
fprintf([' OPTIONS  minScore                  : ', num2str(options.minScore), '\n']);
fprintf([' OPTIONS  minPoints                 : ', num2str(options.minPoints), '\n']);
fprintf([' OPTIONS  addUnknownPeaksToLibrary  : ', bool2str(options.addUnknownPeaksToLibrary), '\n']);
fprintf([' OPTIONS  overrideExistingMatches   : ', bool2str(options.overrideExistingMatches), '\n']);
fprintf([' OPTIONS  requireRetentionTimeMatch : ', bool2str(options.requireRetentionTimeMatch), '\n']);
fprintf([' OPTIONS  retentionTimeTolerance    : ', num2str(options.retentionTimeTolerance), '\n\n']);

fprintf([' STATUS  Library contains ', num2str(length(library)), ' entries...\n']);
fprintf([' STATUS  Matching peaks in ', num2str(options.endIndex - options.startIndex + 1), ' files...', '\n\n']);

totalProcessTime = tic;
totalPeaks = 0;
totalMatches = 0;
totalNewLibraryItems = 0;

% -----------------------------------------
% Spectral matching
% -----------------------------------------
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

    % Check if fields exist
    if ~isfield(data(i).peaks, 'match_score') || options.overrideExistingMatches
        for j = 1:length(data(i).peaks)
            data(i).peaks(j).library_match = [];
            data(i).peaks(j).match_score = 0;
        end
    end

    totalPeaks = totalPeaks + length(data(i).peaks);
    peaksMz = {data(i).peaks.mz};
    peaksIntensity = {data(i).peaks.intensity};

    % -----------------------------------------
    % Perform spectral matching on peaks
    % -----------------------------------------
    if ~isempty(library)

        fprintf([' [', [repmat('0', 1, length(n) - length(m)), m], '/', n, ']']);
        fprintf([' ', sampleName, ': finding matches for ', num2str(length(peaksMz)), ' peaks...\n']);
    
        matches = SpectralMatch( ...
            peaksMz, ...
            peaksIntensity, ...
            library, ...
            'num_matches', 10, ...
            'min_score', options.minScore, ...
            'minPoints', options.minPoints, ...
            'min_mz', options.minMz, ...
            'max_mz', options.maxMz, ...
            'mz_step', options.mzStep);

        % -----------------------------------------
        % Validate matches (no self-matching)
        % -----------------------------------------
        for j = 1:length(matches)

            if ~isfield(data, 'checksum')
                break
            end

            if isempty(matches{j,1})
                continue
            end

            % Validate checksum does not match current file
            fileChecksums = regexp({matches{j,1}.comments}, '(?:FileChecksum[:]\W)(\w*)', 'match');
            removeIndex = [];

            for k = 1:length(fileChecksums)

                if isempty(fileChecksums{k})
                    continue
                end

                fileChecksum = strsplit(fileChecksums{k}{1}, ': ');
                fileChecksum = fileChecksum{end};

                if strcmpi(data(i).checksum, fileChecksum)
                    removeIndex(end+1) = k;
                end
            end

            % Remove self matches 
            matches{j,1}(removeIndex) = [];
        end

        % -----------------------------------------
        % Check if retention time is required
        % -----------------------------------------
        if options.requireRetentionTimeMatch
            
            % Remove any matches without a retention time
            for j = 1:length(matches)
                removeIndex = [];

                for k = 1:length(matches{j,1})
                    if isempty(matches{j,1}(k).compound_retention_time)
                        removeIndex(end+1) = k;
                    elseif matches{j,1}(k).compound_retention_time < 0
                        removeIndex(end+1) = k;
                    end
                end

                matches{j,1}(removeIndex) = [];
            end
        end

        % -----------------------------------------
        % Boost matches close in retention time
        % -----------------------------------------
        for j = 1:length(matches)

            if isempty(matches{j,1})
                continue
            end

            targetTime = data(i).peaks(j).time;
            matchIndex = [];

            for k = 1:length(matches{j,1})
                
                if isempty(matches{j,1}(k).compound_retention_time)
                    continue;
                end

                if abs(matches{j,1}(k).compound_retention_time - targetTime) <= options.retentionTimeTolerance
                    matchIndex(end+1) = k;
                end

            end

            % Sort retention time matches by score
            timeMatches = matches{j,1}(matchIndex);
            [~, scoreIndex] = sort([timeMatches.score], 'descend');
            timeMatches = timeMatches(scoreIndex);

            % Add closest retention time matches to top of stack
            if options.requireRetentionTimeMatch
                matches{j,1} = timeMatches;

                if isempty(matches{j,1})
                    matches{j,1} = [];
                end
            else
                matches{j,1}(matchIndex) = [];
                matches{j,1} = [timeMatches, matches{j,1}];
            end
        end

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

    end

    % -----------------------------------------
    % Add peaks without any matches to library
    % -----------------------------------------
    if options.addUnknownPeaksToLibrary == true
        
        % Count number of peaks without matches
        numPeaksWithoutMatches = sum([data(i).peaks.match_score] == 0);

        if numPeaksWithoutMatches > 0
            
            % Get index of peaks without matches
            peakIndex = find([data(i).peaks.match_score] == 0);
            libraryItems = [];

            % Convert peak to library format
            for j = 1:length(peakIndex)
                libraryItem = convertPeakToLibraryFormat(data, i, peakIndex(j));
                libraryItems = [libraryItems; libraryItem];

                % Update peak data with self match
                data(i).peaks(peakIndex(j)).library_match = libraryItem;
                data(i).peaks(peakIndex(j)).library_match.score = 100;
                data(i).peaks(peakIndex(j)).match_score = 100;
            end

            % Check if each new entry is a duplicate
            libraryItems = checkLibraryForDuplicates(library, libraryItems);
            
            % Add new items to library
            library = [library; libraryItems];
            totalNewLibraryItems = totalNewLibraryItems + length(libraryItems);

            if ~isempty(libraryItems)
                fprintf([' [', [repmat('0', 1, length(n) - length(m)), m], '/', n, ']']);
                fprintf([' ', sampleName, ': added new library entries for ', num2str(length(libraryItems)), ' peaks...\n']);    
            end
        end
    end

    fprintf([' [', [repmat('0', 1, length(n) - length(m)), m], '/', n, ']']);
    fprintf([' ', sampleName, ': END (', parsetime(toc(matchTime)), ')\n\n']);

end

totalMatchesPercent = num2str(totalMatches/totalPeaks, '%.3f');
totalPeaks = num2str(totalPeaks);
totalMatches = num2str(totalMatches);
totalNewLibraryItems = num2str(totalNewLibraryItems);
totalProcessTime = toc(totalProcessTime);

if options.addUnknownPeaksToLibrary == true
    fprintf([' STATUS  Library contains ', num2str(length(library)), ' entries...\n']);
    fprintf([' STATUS  Added ', totalNewLibraryItems, ' new items to library...\n\n']);
end

fprintf([' STATUS  Total peaks   : ', totalPeaks, '\n']);
fprintf([' STATUS  Total matches : ', totalMatches, ' (', totalMatchesPercent, ')\n']);
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

% ---------------------------------------
% Convert boolean to string
% ---------------------------------------
function str = bool2str(bool)

if bool
    str = 'true';
else
    str = 'false';
end

end


% ---------------------------------------
% Check library for duplicate entry
% ---------------------------------------
function libraryItems = checkLibraryForDuplicates(library, libraryItems)

if isempty(library)
    return
end

removeIndex = [];

% Find and remove duplicates
for i = 1:length(libraryItems)

    % Check for matches in num_peaks first
    potentialMatches = libraryItems(i).num_peaks == [library.num_peaks];
    potentialMatches = library(potentialMatches);

    % Check other fields for exact matches
    isDuplicate = false;

    for j = 1:length(potentialMatches)
        
        % Check file_name
        if ~strcmpi(libraryItems(i).file_name, potentialMatches(j).file_name)
            continue
        end

        % Check file_size
        if libraryItems(i).file_size ~= potentialMatches(j).file_size
            continue
        end

        % Check compound_name
        if ~strcmpi(libraryItems(i).compound_name, potentialMatches(j).compound_name)
            continue
        end

        % Check compound_retention_time
        if libraryItems(i).compound_retention_time ~= potentialMatches(j).compound_retention_time
            continue
        end

        % Check mz
        if length(libraryItems(i).mz) ~= length(potentialMatches(j).mz)
            continue
        end

        if ~all(libraryItems(i).mz == potentialMatches(j).mz)
            continue
        end

        % Check intensity
        if length(libraryItems(i).intensity) ~= length(potentialMatches(j).intensity)
            continue
        end

        if ~all(libraryItems(i).intensity == potentialMatches(j).intensity)
            continue
        end

        % Item is a duplicate
        isDuplicate = true;
        break
    end

    if isDuplicate
        removeIndex(end+1) = i;
    end
end

libraryItems(removeIndex) = [];

end