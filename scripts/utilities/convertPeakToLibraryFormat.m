function libraryItem = convertPeakToLibraryFormat(data, sampleIndex, peakIndex)

% Check for errors
if ~isfield(data, 'peaks')
    fprintf(' ERROR  Data has no field ''peaks''...\n');
    return
end

if sampleIndex > length(data)
    fprintf(' ERROR  sampleIndex is out of range of data...\n');
    return
end

if peakIndex > length(data(sampleIndex).peaks)
    fprintf(' ERROR  peakIndex is out of range of peaks...\n');
    return
end

% Get library data fields
libraryItem = getLibraryStructure();

% Get peak
peak = data(sampleIndex).peaks(peakIndex);

% Set unique id for peak
libraryItem(1).db_id = char(java.util.UUID.randomUUID.toString);

% Set library fields for peak
libraryItem.file_path = data(sampleIndex).file_path;
libraryItem.file_name = fileparts(data(sampleIndex).file_name);
libraryItem.file_size = data(sampleIndex).file_size;

libraryItem.compound_retention_time = peak.time;
libraryItem.num_peaks = length(peak.mz);
libraryItem.mz = peak.mz;
libraryItem.intensity = peak.intensity;

% Set compound name for peak
[~, seqName , ~] = fileparts(data(sampleIndex).file_path);
fileName = strrep(fileparts(data(sampleIndex).file_name), '\', '/');
fileName = strrep(fileName, '%', '');
peakTime = num2str(round(peak.time, 3));

libraryItem.compound_name = upper([seqName, '/', fileName '/', peakTime]);
libraryItem.compound_ontology = 'Custom';

% Set comments
if isfield(data, 'checksum')
    libraryItem.comments = ['FileChecksum: ', data(sampleIndex).checksum];
end

end