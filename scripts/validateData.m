function data = validateData(data, varargin)

% ------------------------------------------------------------------------
% Method      : validateData
% Description : check data files are valid and remove any non-MS data 
% files from data, compute file checksums
% ------------------------------------------------------------------------

% -----------------------------------------
% Status
% -----------------------------------------
fprintf(['\n', repmat('-',1,50), '\n']);
fprintf(' VALIDATE DATA');
fprintf(['\n', repmat('-',1,50), '\n']);

fprintf([' STATUS  Validating ', num2str(length(data)), ' files...', '\n\n']);

% -----------------------------------------
% Validate data
% -----------------------------------------
removeIndex = [];

for i = 1:size(data,1)

    m = num2str(i);
    n = num2str(size(data,1));

    % Get file name and extension
    [~, fileName , fileExtension] = fileparts(data(i).file_name);
    [~, seqName , ~] = fileparts(data(i).file_path);
    fileBase = strrep(data(i).file_name, '\', '/');
    fileBase = strrep(fileBase, '%', '');

    % -----------------------------------------
    % Check if file extension is .MS
    % -----------------------------------------
    if ~strcmpi(fileExtension, '.ms')
        fprintf([' [', [repmat('0', 1, length(n) - length(m)), m], '/', n, ']']);
        fprintf([' ', seqName, '/', fileBase, ': invalid file (', fileExtension, ')\n']);
        removeIndex(end+1) = i;
        continue
    end

    % -----------------------------------------
    % Check if file name is DATASIM.MS
    % -----------------------------------------
    if strcmpi(fileName, 'datasim')
        fprintf([' [', [repmat('0', 1, length(n) - length(m)), m], '/', n, ']']);
        fprintf([' ', seqName, '/', fileBase, ': invalid file (DATASIM.MS)\n']);
        removeIndex(end+1) = i;
        continue
    end

    % -----------------------------------------
    % Check if data is SIM mode
    % -----------------------------------------
    if mean(diff(data(i).channel(2:end))) > 2
        fprintf([' [', [repmat('0', 1, length(n) - length(m)), m], '/', n, ']']);
        fprintf([' ', seqName, '/', fileBase, ': invalid file (SIM Mode)\n']);
        removeIndex(end+1) = i;
        continue
    end

    % -----------------------------------------
    % Check if file name is SNAPSHOT.MS
    % -----------------------------------------
    if strcmpi(fileName, 'snapshot')
        fprintf([' [', [repmat('0', 1, length(n) - length(m)), m], '/', n, ']']);
        fprintf([' ', seqName, '/', fileBase, ': invalid file (SNAPSHOT.MS)\n']);
        removeIndex(end+1) = i;
        continue
    end

    % -----------------------------------------
    % Check if channel data is empty
    % -----------------------------------------
    if isempty(data(i).channel)
        fprintf([' [', [repmat('0', 1, length(n) - length(m)), m], '/', n, ']']);
        fprintf([' ', seqName, '/', fileBase, ': invalid file (channel data is missing)\n']);
        removeIndex(end+1) = i;
        continue
    end

    % -----------------------------------------
    % Check if data is BSB (vendor baseline)
    % -----------------------------------------
    if any(cellfun(@any, regexpi(data(i).operator, {'\[BSB'})))
        matchIndex = find(strcmpi(data(i).datetime, {data.datetime}));
        matchIndex(matchIndex == i) = [];

        isDuplicate = true;
        checkFields = {'file_size', 'sample_name', 'method_name', 'dir_offset'};
        
        % Check if BSB file is duplicate
        if length(matchIndex) >= 1
            for j = 1:length(matchIndex)
                for k = 1:length(checkFields)
                    if ischar(data(i).(checkFields{k}))
                        if all(~strcmpi({data(matchIndex).(checkFields{k})}, data(i).(checkFields{k})))
                            isDuplicate = false;
                            break;
                        end
                    elseif all([data(matchIndex).(checkFields{k})] ~= data(i).(checkFields{k}))
                        isDuplicate = false;
                        break;
                    end
                end
            end
        end

        if isDuplicate
            fprintf([' [', [repmat('0', 1, length(n) - length(m)), m], '/', n, ']']);
            fprintf([' ', seqName, '/', fileBase, ': duplicate file (BSB)\n']);
            removeIndex(end+1) = i;
            continue
        end
    end

    % -----------------------------------------
    % Check if sample name is empty
    % -----------------------------------------
    if isempty(data(i).sample_name)
        [~, data(i).sample_name, ~] = fileparts(fileparts(data(i).file_name));
    end

    % -----------------------------------------
    % File is OK
    % -----------------------------------------
    fprintf([' [', [repmat('0', 1, length(n) - length(m)), m], '/', n, ']']);
    fprintf([' ', seqName, '/', fileBase, ': OK\n']);

end

% -----------------------------------------
% Remove invalid files
% -----------------------------------------
data(removeIndex) = [];

% -----------------------------------------
% Sort files by datetime
% -----------------------------------------
fileDatetime = [];

for i = 1:length(data)
    fileDatetime(end+1) = datenum(data(i).datetime, 'yyyy-mm-ddTHH:MM:SS');
end

[~, idx] = sort(fileDatetime);
data = data(idx);

% -----------------------------------------
% Get MD5 checksums for files
% -----------------------------------------
fprintf(['\n STATUS  Caclulating MD5 checksums for ', num2str(length(data)), ' files...\n']);
data = addChecksum(data);
fprintf(' STATUS  Caclulating MD5 checksums complete!\n\n');

fprintf([' STATUS  Invalid files : ', num2str(length(removeIndex)), '\n']);
fprintf([' STATUS  Valid files   : ', num2str(length(data)), '\n']);

fprintf([repmat('-',1,50), '\n']);
fprintf(' EXIT');
fprintf(['\n', repmat('-',1,50), '\n']);