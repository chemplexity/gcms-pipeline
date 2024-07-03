function data = addChecksum(data)

% ------------------------------------------------------------------------
% Method      : addChecksum(data)
% Description : calls GetFileChesksum with an MD5 hash and adds the file
% checksum as a field in each row of data
% ------------------------------------------------------------------------

for i=1: size(data, 1)

    data(i).checksum = GetFileChecksum(data(i).file_path, 'hash', 'MD5');
    
end

end