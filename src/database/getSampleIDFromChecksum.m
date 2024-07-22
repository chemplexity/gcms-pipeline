function sampleID = getSampleIDFromChecksum(db, checksum)

% ------------------------------------------------------------------------
% Method      : getSampleIDFromChecksum()
% Description : given the checksum of a peak, returns the sampleID of
% the corresponding sample in order to link the sample and peak SQL tables
% ------------------------------------------------------------------------

conn = sqlite(db);

selectedField = 'sample_id';
table = 'samples';
field = 'md5_checksum';


query = [sprintf('%s', ...
            'SELECT ', selectedField, ' ', ...
            'FROM ', table, ' ', ...
            'WHERE ', field, '=''', char(checksum), '''')];

data = fetch(conn, query);
sampleID = string(table2cell(data(1, 1)));

end

