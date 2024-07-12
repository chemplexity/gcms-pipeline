function CreateDatabase(varargin)

% ------------------------------------------------------------------------
% Method      : CreateDatabase
% Description : creates a SQL database that includes a peaks table and 
% a samples file
% ------------------------------------------------------------------------

p = inputParser;

addParameter(p, 'filename', './src/database/GCMS_Database.db');

parse(p, varargin{:});

dbfile = p.Results.filename;
conn = sqlite(dbfile, 'create');

samplesTextArray = readlines('./src/database/samples_table_sql.txt');
samplesText = strjoin(samplesTextArray);
sqlquery = samplesText;
execute(conn, sqlquery);

close(conn)