function data = validateData(data, varargin)

% ------------------------------------------------------------------------
% Method      : validateData
% Description : check data files are valid and remove any non-MS data 
% files from data
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
    % Check if file name is SNAPSHOT.MS
    % -----------------------------------------
    if strcmpi(fileName, 'snapshot')
        fprintf([' [', [repmat('0', 1, length(n) - length(m)), m], '/', n, ']']);
        fprintf([' ', seqName, '/', fileBase, ': invalid file (SNAPSHOT.MS)\n']);
        removeIndex(end+1) = i;
        continue
    end

    % -----------------------------------------
    % Check if channel data is non-empty
    % -----------------------------------------
    if isempty(data(i).channel)
        fprintf([' [', [repmat('0', 1, length(n) - length(m)), m], '/', n, ']']);
        fprintf([' ', seqName, '/', fileBase, ': invalid file (channel data is missing)\n']);
        removeIndex(end+1) = i;
        continue
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

fprintf(['\n STATUS  Invalid files : ', num2str(length(removeIndex)), '\n']);
fprintf([' STATUS  Valid files   : ', num2str(length(data)), '\n']);

fprintf([repmat('-',1,50), '\n']);
fprintf(' EXIT');
fprintf(['\n', repmat('-',1,50), '\n']);