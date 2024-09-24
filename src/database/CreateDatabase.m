function databaseFileName = CreateDatabase(varargin) 

% ------------------------------------------------------------------------
% Method      : CreateDatabase
% Description : creates a SQL database that includes a peaks table and 
% a samples file
% ------------------------------------------------------------------------

% Get path of default database
functionFileName = mfilename("fullpath");
functionFilePath = fileparts(functionFileName);


% ---------------------------------------
% Defaults
% ---------------------------------------
defaultDatabaseFile = [functionFilePath, filesep, 'GCMS_Database.db'];
default.verbose = 'on';

tablesPath = [functionFilePath, filesep, 'tables'];
samplesTableFile = [tablesPath, filesep, 'samples_table_sql.txt'];
peaksTableFile   = [tablesPath, filesep, 'peaks_table_sql.txt'];
libraryTableFile = [tablesPath, filesep, 'library_table_sql.txt'];

% ---------------------------------------
% Parse
% ---------------------------------------
p = inputParser;
addParameter(p, 'filename', defaultDatabaseFile);
addParameter(p, 'verbose', default.verbose, @ischar);
parse(p, varargin{:});

% ---------------------------------------
% Options
% ---------------------------------------
option.filename    = p.Results.filename;
option.verbose   = p.Results.verbose;

% Get database file name
status(option.verbose, 'create_db');
databaseFileName = option.filename;
if isfile(databaseFileName)
    fprintf('Database file already exists\n')
    return
end

% Create SQL database
dbfile = databaseFileName;
conn = sqlite(dbfile, 'create');
status(option.verbose, 'create', databaseFileName);

% Create samples table
samplesTextArray = readlines(samplesTableFile);
samplesText = strjoin(samplesTextArray);
sqlquery = samplesText;
execute(conn, sqlquery);
status(option.verbose, 'samples');

% Create peaks table
peaksTextArray = readlines(peaksTableFile);
peaksText = strjoin(peaksTextArray);
sqlquery = peaksText;
execute(conn, sqlquery);
status(option.verbose, 'peaks');

% Create library table
libraryTextArray = readlines(libraryTableFile);
libraryText = strjoin(libraryTextArray);
sqlquery = libraryText;
execute(conn, sqlquery);
status(option.verbose, 'library');

% Close database
close(conn)

databaseFileName = strrep(databaseFileName, '\', '\\');
status(option.verbose, 'created', databaseFileName)
status(option.verbose, 'exit');

% ---------------------------------------
% Status
% ---------------------------------------
function status(varargin)

if ~varargin{1}
    return
end

switch varargin{2}
    
    case 'exit'
        fprintf([repmat('-',1,50), '\n']);
        fprintf(' EXIT');
        fprintf(['\n', repmat('-',1,50), '\n']);
        
    case 'default_db'
        fprintf([' STATUS  Existing database: ', varargin{3},'...\n']);

    case 'create'
        fprintf([' STATUS  Creating database: ', varargin{3},'...\n']);

    case 'created'
        fprintf([' STATUS  Database created: ', varargin{3}, '\n'])

    case 'duplicate'
        fprintf([' STATUS  File ', varargin{3}, 'already exists...', '\n']);

    case 'samples'
        fprintf([' STATUS  Creating samples table...', '\n']);
        
    case 'peaks'
        fprintf([' STATUS  Creating peaks table...', '\n']);

    case 'library'
        fprintf([' STATUS  Creating library table...', '\n']);

    case 'create_db'
        fprintf(['\n', repmat('-',1,50), '\n']);
        fprintf(' CREATE DATABASE');
        fprintf(['\n', repmat('-',1,50), '\n']);
          
end

end

end