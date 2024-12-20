function data = prepareDataPeaks(database, data, sampleRow, varargin)

% ------------------------------------------------------------------------
% Method      : prepareDataPeaks()
% Description : prepares the passed in data to be added to the peaks
% table in the SQL database by creating a copy with the correct field
% names
% ------------------------------------------------------------------------

% ---------------------------------------
% Defaults
% ---------------------------------------
default.initialLibrary = [];

% ---------------------------------------
% Input
% ---------------------------------------
p = inputParser;
addOptional(p, 'initialLibrary', default.initialLibrary);

parse(p, varargin{:});

% ---------------------------------------
% Parse
% ---------------------------------------
options.initialLibrary = p.Results.initialLibrary;

% ---------------------------------------
% Prepare Data
% ---------------------------------------
db = [];

if ~isfield(data, 'checksum')
    fprintf('[ERROR] Missing Checksum Field \n')
    return
end

if ~isfield(data, 'peaks')
    fprintf('[ERROR] Missing Peaks Data \n')
    return
end

if ~isfield(data(sampleRow).peaks, 'library_match')
    fprintf('[ERROR] Missing Library Match \n')
    return
end

if ~isempty(options.initialLibrary)
    lib = prepareDataLibrary(options.initialLibrary);
    UpdateDatabaseLibrary(database, lib);
end

conn = sqlite(database);

for i=1:length(data(sampleRow).peaks)

    db(i).peak_time = sprintf('%.6f', data(sampleRow).peaks(i).time);
    db(i).peak_area = data(sampleRow).peaks(i).area;
    db(i).peak_width = data(sampleRow).peaks(i).width;
    db(i).peak_height = data(sampleRow).peaks(i).height;
    db(i).area_Of = data(sampleRow).peaks(i).areaOf;
    db(i).error = data(sampleRow).peaks(i).error;
    db(i).model = data(sampleRow).peaks(i).model;
    db(i).x_min = data(sampleRow).peaks(i).xmin;
    db(i).x_max = data(sampleRow).peaks(i).xmax;
    db(i).y_min = data(sampleRow).peaks(i).ymin;
    db(i).y_max = data(sampleRow).peaks(i).ymax;
    db(i).input_x = data(sampleRow).peaks(i).peakCenterX;
    db(i).input_y = data(sampleRow).peaks(i).peakCenterY;
    db(i).date_created = datestr(now(), 'yyyy-mm-ddTHH:MM:SS');
    db(i).sample_id = getSampleIDFromChecksum(database, ...
        data(sampleRow).checksum);
    
    indexOfPeakTime = lookupTimeIndex(data(sampleRow).time, ...
        data(sampleRow).peaks(i).time);

    mz = convertDoubleArrayToText(data(sampleRow).channel(1, 2:end), '%.4f');
    intensity = convertDoubleArrayToText(data(sampleRow).intensity ...
        (indexOfPeakTime, 2:end),'%.0f' );

    db(i).peak_mz = mz;
    db(i).peak_intensity = intensity;
    db(i).fit_x = convertDoubleArrayToText(data(sampleRow). ...
        peaks(i).fit(:, 1), '%.6f');
    db(i).fit_y = convertDoubleArrayToText(data(sampleRow). ...
        peaks(i).fit(:, 2), '%.0f');

% ---------------------------------------
% Perform Spectral Matching
% ---------------------------------------
    
    id = 'library_id';
    table = 'library';
    fieldOne = 'file_path';
    fieldTwo = 'file_name';
    fieldThree = 'compound_retention_time';
    
    if ~isfield(data(sampleRow).peaks(i), 'library_match')... 
        || isempty(data(sampleRow).peaks(i).library_match) 
        
        query = [sprintf('%s', ...
            'SELECT MAX(', id, ') ', ...
            'FROM ', table)];
        max = fetch(conn, query);
        db(i).library_id = max{1,1} + 1;
        db(i).match_score = 0;
        
        data(sampleRow).peaks(i).date_created = datestr(now(), 'yyyy-mm-ddTHH:MM:SS');
        peak = ExportNIST(data(sampleRow), i);
        peak = prepareDataLibrary(peak);
        UpdateDatabaseLibrary(database, peak);

    else

        ret_time = sprintf('%.6f', data(sampleRow).peaks(i).library_match.(fieldThree));

        query = [sprintf('%s', ...
            'SELECT ', id,  ...
            ' FROM ', table, ...
            ' WHERE ', fieldOne, '=''', char(data(sampleRow).peaks(i).library_match.(fieldOne)),'''', ...
            ' AND ', fieldTwo, '=''', char(data(sampleRow).peaks(i).library_match.(fieldTwo)),'''', ...
            ' AND ', fieldThree, '=''', string(ret_time),'''')];

        match = fetch(conn, query); 

        db(i).library_id = match{1,1};
        db(i).match_score = data(sampleRow).peaks(i).match_score;

    end

end

data(sampleRow).peaks = db;
close(conn);