function database = loadPeaksFromDatabase(db)

% ------------------------------------------------------------------------
% Method      : loadPeaksFromDatabase()
% Description : loads the Peaks table from the SQL database into 
% the Matlab workspace and converts the concatenated strings for peak mz,
% peak intensity, peak fit x, and peak fit y into string arrays
% ------------------------------------------------------------------------

conn = sqlite(db);

query = ['SELECT * ' ...
        'FROM peaks ' ...
        'LEFT JOIN samples ON peaks.sample_id = samples.sample_id'];

database = fetch(conn, query);
database.sample_id_1 = [];
database = table2struct(database);

for i=1:length(database)

    database(i).peak_mz = split(database(i).peak_mz, ", ");
    database(i).peak_intensity = split(database(i).peak_intensity, ", ");
    database(i).fit_x = split(database(i).fit_x, ", ");
    database(i).fit_y = split(database(i).fit_y, ", ");

end 

close(conn);