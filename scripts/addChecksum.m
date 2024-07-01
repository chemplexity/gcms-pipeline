function data = addChecksum(data)

% call GetFileChecksum with MD5 hash

% for loop to add checksum column to each row of data

% data(i).checksum = ....


for i=1: size(data, 1)
    data(i).checksum = GetFileChecksum(data(i).file_path, 'hash', 'MD5');
end
end