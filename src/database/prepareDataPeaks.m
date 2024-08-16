function data = prepareDataPeaks(database, data, sampleRow, library)

% ------------------------------------------------------------------------
% Method      : prepareDataPeaks()
% Description : prepares the passed in data to be added to the peaks
% table in the SQL database by creating a copy with the correct field
% names
% ------------------------------------------------------------------------

db = [];
data = addChecksum(data);
data = performSpectralMatch(data, library);
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
    fieldFour = 'compound_retention_index';
    
    if isempty(data(sampleRow).peaks(i).library_match)
        
        query = [sprintf('%s', ...
            'SELECT COUNT(*) ', ...
            'FROM ', table)];
        count = fetch(conn, query);
        db(i).library_id = count{1,1} + 1;
        db(i).match_score = 0;
        % EXPORTNIST() TO ADD THIS PEAK TO THE LIBRARY

    else

        ret_time = sprintf('%.6f', data(sampleRow).peaks(i).library_match.(fieldThree));

        query = [sprintf('%s', ...
            'SELECT ', id,  ...
            ' FROM ', table, ...
            ' WHERE ', fieldOne, '=''', char(data(sampleRow).peaks(i).library_match.(fieldOne)),'''', ...
            ' AND ', fieldTwo, '=''', char(data(sampleRow).peaks(i).library_match.(fieldTwo)),'''', ...
            ' AND ', fieldThree, '=''', string(ret_time),'''', ...
            ' AND ', fieldFour, '=''', string(data(sampleRow).peaks(i).library_match.(fieldFour)), '''')];

        match = fetch(conn, query); 

        db(i).library_id = match{1,1};
        db(i).match_score = data(sampleRow).peaks(i).match_score;

    end

end

data(sampleRow).peaks = db;
close(conn);

% upload library match as a new entry (only if it doesn't exist),
% and then link it to the peak (library has no foreign keys)
