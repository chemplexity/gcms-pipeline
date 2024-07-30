function status = UpdateDatabasePeaks(db, peaksData)

% ------------------------------------------------------------------------
% Method      : UpdateDatabasePeaks()
% Description : connects to the SQL .db file, formats the data in a table,
% and adds it to the peaks table in the SQL database
% ------------------------------------------------------------------------

conn = sqlite(db);

table = 'peaks';

cols = fields(peaksData)';
colNames = {strjoin(cols)};
rows = {};

for i = 1:length(peaksData)
    
    for j = 1:length(cols)
        rows{i,j} = peaksData(i).(cols{j}); 
    end

end

fprintf(['[INSERT] ' num2str(length(rows(:,1))), ' peaks\n']);
fprintf('[INSERT] please wait....\n');

data = cell2table(rows, 'VariableNames', cols);

sqlwrite(conn, table, data);

status = ['added peaks: ', num2str(length(rows(:,1)))];

fprintf('[FINISH] Database update complete!\n');

close(conn);

end

