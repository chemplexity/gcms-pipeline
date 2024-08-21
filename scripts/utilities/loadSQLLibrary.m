function library = loadSQLLibrary(db)

% ------------------------------------------------------------------------
% Method      : loadSQLLibrary()
% Description : loads the Library table from the SQL database into 
% the Matlab workspace 
% ------------------------------------------------------------------------

conn = sqlite(db);

query = ['SELECT * ' ...
        'FROM library'];

library = fetch(conn, query);
library.library_id = [];
library.date_created = [];
library = table2struct(library);

for i=1:length(library)

    library(i).mz = split(library(i).mz, ", ");
    library(i).mz = str2double(library(i).mz);
    library(i).mz = round(library(i).mz);
    library(i).mz = library(i).mz.';
    library(i).intensity = split(library(i).intensity, ", ");
    library(i).intensity = str2double(library(i).intensity);
    library(i).intensity = library(i).intensity.';

    fields = fieldnames(library);
    fields = string(fields);

    for j=1:length(fields)

        field = string(fields(j));
        if ismissing(library(i).(field))
            library(i).(field) = [];
        end

    end

end