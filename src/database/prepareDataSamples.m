function db = prepareDataSamples(data)

% ------------------------------------------------------------------------
% Method      : prepareDataSamples()
% Description : prepares the passed in data to be added to the samples
% table in the SQL database by creating a copy with the correct field names
% and adding the md5 checksum to allow duplicate checking
% ------------------------------------------------------------------------

db = [];
data = addChecksum(data);

for i=1:length(data)
    
    db(i).file_path = data(i).file_path;
    db(i).file_name = data(i).file_name;
    db(i).file_name = strrep(db(i).file_name, '/', '\');
    
    if ~isempty(data(i).file_name)
        [~, ~, db(i).file_extension] = fileparts(data(i).file_name);
    end
    
    db(i).file_size = data(i).file_size;
    
    if ~isempty(data(i).file_version) 
        db(i).file_version = data(i).file_version;
    else
        db(i).file_version = '0';
    end
    
    db(i).md5_checksum     = data(i).checksum;
    db(i).sample_name      = data(i).sample_name;    
    db(i).operator         = data(i).operator;
    db(i).instrument       = data(i).instrument;
    db(i).instr_model      = data(i).instmodel;
    db(i).inlet            = data(i).inlet;
    db(i).method_name      = data(i).method_name;
    db(i).sequence_index   = data(i).seqindex;
    db(i).vial             = data(i).vial;
    db(i).replicate        = data(i).replicate;
    db(i).start_time       = data(i).start_time;
    db(i).end_time         = data(i).end_time;
    db(i).time_units       = data(i).time_units;
    db(i).intensity_units  = data(i).intensity_units;
    db(i).channel_units    = data(i).channel_units;
    db(i).sampling_rate    = data(i).sampling_rate;
    db(i).sample_datetime  = data(i).datetime;
    db(i).sample_info      = '';
    db(i).injvol           = 0;
    db(i).date_created     = datestr(now(), 'yyyy-mm-ddTHH:MM:SS');

end

end