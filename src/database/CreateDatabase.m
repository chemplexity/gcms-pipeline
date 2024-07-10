function CreateDatabase(varargin)

% ------------------------------------------------------------------------
% Method      : CreateDatabase
% Description : creates a SQL database that includes a peaks table and 
% a samples file
% ------------------------------------------------------------------------

p = inputParser;

addParameter(p, 'filename', './src/database/GCMS_Database.db');

parse(p, varargin{:});

%% Create database
dbfile = p.Results.filename;
conn = sqlite(dbfile, 'create');

%% Create table in database

%requires Text Analytics Toolbox
% samplesText = extractFileText('./src/database/samples_table_sql.txt');
samplesTextArray = readlines('./src/database/samples_table_sql.txt');
samplesText = strjoin(samplesTextArray);
sqlquery = samplesText;
execute(conn, sqlquery);
% 
% peaksText = extractFileText('./src/database/peaks_table_sql.txt');
% execute(conn, peaksText);

%% Close connection
close(conn)