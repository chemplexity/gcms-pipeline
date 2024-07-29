function db = prepareDataPeaks(database, data, sampleRow)

% ------------------------------------------------------------------------
% Method      : prepareDataPeaks()
% Description : prepares the passed in data to be added to the peaks
% table in the SQL database by creating a copy with the correct field
% names
% ------------------------------------------------------------------------

db = [];
data = addChecksum(data);

for i=1:length(data(sampleRow).peaks)

    db(i).peak_time = data(sampleRow).peaks(i).time;
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
    % confirm these
    db(i).input_x = data(sampleRow).peaks(i).peakCenterX;
    db(i).input_y = data(sampleRow).peaks(i).peakCenterY;

    db(i).date_created = datestr(now(), 'yyyy-mm-ddTHH:MM:SS');
    db(i).sample_id = getSampleIDFromChecksum(database, ...
        data(sampleRow).checksum);
end