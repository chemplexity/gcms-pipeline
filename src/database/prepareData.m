function db = PrepareData(data)

db = [];

for i = 1:length(data)
    
    db(i).file_path = data(i).file_path;
    db(i).file_name = data(i).file_name;
    db(i).file_name = strrep(db(i).file_name, '/', '\');
    
    if ~isempty(data(i).file_name)
        [~, ~, db(i).file_extension] = fileparts(data(i).file_name);
    end
    
    db(i).file_size = data(i).file_size;
    
    if ~isempty(data(i).file_version) && ~isnan(str2double(data(i).file_version))
        db(i).file_version = str2double(data(i).file_version);
    else
        db(i).file_version = 0;
    end
    
    db(i).md5_checksum = data(i).file_checksum;
    db(i).sample_name  = data(i).sample_name;
    
    if ~isempty(data(i).datetime)
        db(i).sample_datetime = strrep(data(i).datetime, 'T', ' ');
    end
    
    db(i).operator_name    = data(i).operator;
    db(i).instrument_name  = data(i).instrument;
    db(i).instrument_model = data(i).instmodel;
    db(i).instrument_inlet = data(i).inlet;
    db(i).method_name      = data(i).method_name;
    db(i).sequence_path    = data(i).sequence_path;
    db(i).sequence_name    = data(i).sequence_name;
    db(i).sequence_index   = data(i).seqindex;
    db(i).vial_index       = data(i).vial;
    db(i).replicate_index  = data(i).replicate;
    db(i).start_time       = data(i).start_time;
    db(i).end_time         = data(i).end_time;
    db(i).time_units       = data(i).time_units;
    db(i).intensity_units  = data(i).intensity_units;
    db(i).channel_units    = data(i).channel_units;
    db(i).date_created     = datestr(now(), 'yyyy-mm-dd HH:MM:SS');
end

end