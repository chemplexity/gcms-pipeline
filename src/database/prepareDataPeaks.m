function data = prepareDataPeaks(database, data, sampleRow)

% ------------------------------------------------------------------------
% Method      : prepareDataPeaks()
% Description : prepares the passed in data to be added to the peaks
% table in the SQL database by creating a copy with the correct field
% names
% ------------------------------------------------------------------------

db = [];
data = addChecksum(data);

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

    if isfield(data(sampleRow).peaks(i), 'match_score')
        db(i).match_score = data(sampleRow).peaks(i).match_score;
    else
        db(i).match_score = 0;
    end

    % confirm 6 decimal places
    db(i).fit_x = convertDoubleArrayToText(data(sampleRow). ...
        peaks(i).fit(:, 1), '%.6f');
    db(i).fit_y = convertDoubleArrayToText(data(sampleRow). ...
        peaks(i).fit(:, 2), '%.6f');

    % change this later
    db(i).library_id = 0;

end

data(sampleRow).peaks = db;
