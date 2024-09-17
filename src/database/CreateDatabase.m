function databaseFileName = CreateDatabase(varargin) 

% ------------------------------------------------------------------------
% Method      : CreateDatabase
% Description : creates a SQL database that includes a peaks table and 
% a samples file
% ------------------------------------------------------------------------

% Get path of default database
functionFileName = mfilename("fullpath");
functionFilePath = fileparts(functionFileName);
defaultDatabaseFile = [functionFilePath, filesep, 'GCMS_Database.db'];

% Set paths to table definitions
tablesPath = [functionFilePath, filesep, 'tables'];

samplesTableFile = [tablesPath, filesep, 'samples_table_sql.txt'];
peaksTableFile   = [tablesPath, filesep, 'peaks_table_sql.txt'];
libraryTableFile = [tablesPath, filesep, 'library_table_sql.txt'];

p = inputParser;
addParameter(p, 'filename', defaultDatabaseFile);
parse(p, varargin{:});

% Get database file name
databaseFileName = p.Results.filename;

if isfile(databaseFileName)
    fprintf('Database file already exists\n')
    return
end

% Create SQL database
dbfile = databaseFileName;
conn = sqlite(dbfile, 'create');

% Create samples table
samplesTextArray = readlines(samplesTableFile);
samplesText = strjoin(samplesTextArray);
sqlquery = samplesText;
execute(conn, sqlquery);

% Create peaks table
peaksTextArray = readlines(peaksTableFile);
peaksText = strjoin(peaksTextArray);
sqlquery = peaksText;
execute(conn, sqlquery);

% Create library table
libraryTextArray = readlines(libraryTableFile);
libraryText = strjoin(libraryTextArray);
sqlquery = libraryText;
execute(conn, sqlquery);

% Close database
close(conn)

databaseFileName = strrep(databaseFileName, '\', '\\');
fprintf(['Database created: ', databaseFileName, '\n']);