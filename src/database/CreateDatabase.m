function CreateDatabase(varargin)

% ------------------------------------------------------------------------
% Method      : CreateDatabase
% Description : creates a SQL database that includes a peaks table and 
% a samples file
% ------------------------------------------------------------------------

p = inputParser;

addParameter(p, 'filename', './src/database/GCMS_Database.sql');

parse(p, varargin{:});

%% Create database
dbfile = p.Results.filename;
edit(dbfile);
conn = sqlite(dbfile, 'create');

%% Create table in database

%requires Text Analytics Toolbox
samplesText = extractFileText('./src/database/samples_table_sql.txt');
sqlquery = samplesText;
execute(conn, sqlquery);

peaksText = extractFileText('./src/database/peaks_table_sql.txt');
execute(conn, peaksText);

%% Close connection
close(conn)