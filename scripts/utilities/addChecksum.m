function data = addChecksum(data)

% ------------------------------------------------------------------------
% Method      : addChecksum(data)
% Description : calls GetFileChesksum with an MD5 hash and adds the file
% checksum as a field in each row of data
% ------------------------------------------------------------------------

for i = 1:size(data, 1)

    % Get full file name
    fullFileName = strcat(data(i).file_path, filesep, data(i).file_name);
    
    % Get MD5 checksum
    data(i).checksum = GetFileChecksum(fullFileName, ...
        'hash', 'MD5',...
        'verbose', false);
    
end

end