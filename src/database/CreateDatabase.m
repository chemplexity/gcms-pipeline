function CreateDatabase(varargin)

% ------------------------------------------------------------------------
% Method      : CreateDatabase
% Description : creates a SQL database that includes a peaks table and 
% a samples file
% ------------------------------------------------------------------------

p = inputParser;
addParameter(p, 'filename', './src/database/GCMS_Database.db');
parse(p, varargin{:});

[~, name, ~] = fileparts(cd);
if ~strcmp(name, 'gcms-pipeline')
    fprintf('Please navigate to the gcms-pipeline directory\n')
    return
end

if isfile(p.Results.filename)
    fprintf('Database file already exists\n')
    return
end

dbfile = p.Results.filename;
conn = sqlite(dbfile, 'create');

samplesTextArray = readlines('./src/database/tables/samples_table_sql.txt');
samplesText = strjoin(samplesTextArray);
sqlquery = samplesText;
execute(conn, sqlquery);

close(conn)
fprintf("Database created: " + p.Results.filename + "\n");