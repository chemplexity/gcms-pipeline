function status = UpdateDatabaseLibrary(db, libraryData, varargin)

% ------------------------------------------------------------------------
% Method      : UpdateDatabaseLibrary()
% Description : connects to the SQL .db file, checks for dulpicate files
% in the passed in data, formats the data in a table, and adds it to 
% the library table in the SQL database
% ------------------------------------------------------------------------

conn = sqlite(db);

if ~isempty(varargin) && islogical(varargin{1})
    skipDuplicateCheck = varargin{1};
else
    skipDuplicateCheck = false;
end

table = 'library';
fieldOne = 'file_path';
fieldTwo = 'file_name';
fieldThree = 'compound_retention_time';
index = [];

if ~skipDuplicateCheck

    fprintf('Checking for Duplicates\n');

    for i = 1:length(libraryData)

        if i > length(libraryData)
            fprintf(['[' num2str(i), ' was removed as a duplicate] \n']);
            break
        end 

        fprintf(['[', num2str(i), '/', num2str(length(libraryData)), '] \n']);

        query = [sprintf('%s', ...
            'SELECT COUNT(*)', ...
            'FROM ', table, ' ', ...
            'WHERE ', fieldOne, '=''', char(libraryData(i).(fieldOne)),'''', ...
            ' AND ', fieldTwo, '=''', char(libraryData(i).(fieldTwo)),'''', ...
            ' AND ', fieldThree, '=', string(libraryData(i).(fieldThree)), '')];
     
        
        % should we automatically count it as a duplicate
        % if the field is missing?
        if isempty(libraryData(i).(fieldOne)) ...
                | isempty(libraryData(i).(fieldTwo)) ...
                | isempty(libraryData(i).(fieldThree))
            data{1} = 1;
        else
            data = fetch(conn, query);
        end

        if istable(data) && data{1,1} ~= 0
            index(end+1) = i;
            fprintf('[DUPLICATE IN DATABASE] ');
            disp(libraryData(i).file_path);
        end 

        for j = 1:length(libraryData)
            if j > length(libraryData)
                break  
            elseif i~=j && strcmp(libraryData(i).(fieldOne), ...
                    libraryData(j).(fieldOne)) && strcmp(libraryData(i).(fieldTwo), ...
                    libraryData(j).(fieldTwo)) && strcmp(libraryData(i).(fieldThree), ...
                    libraryData(j).(fieldThree))
                index(end+1) = j;
                fprintf('[DUPLICATE IN INPUT DATA] ')
                disp(libraryData(j).file_path);
            end
        end 
    end

    if ~isempty(index)
        libraryData(index) = [];
        fprintf(['[IGNORE] ' num2str(length(index)), '\n']);
    else
        fprintf('[OK] \n');
    end

    if isempty(libraryData)
        status = 'no data';
        fprintf('[ERROR] No samples to add\n');
        return
    end

end

cols = fields(libraryData)';
colNames = {strjoin(cols)};
rows = {};

for i = 1:length(libraryData)

    for j = 1:length(cols)
        rows{i,j} = libraryData(i).(cols{j}); 
    end

end

fprintf(['[INSERT] ' num2str(length(rows(:,1))), ' compounds\n']);
fprintf('[INSERT] please wait....\n');

data = cell2table(rows, 'VariableNames', cols);

sqlwrite(conn, table, data);

status = ['added compounds: ', num2str(length(rows(:,1)))];

fprintf('[FINISH] Database update complete!\n');

close(conn);

end