function status = UpdateDatabasePeaks(db, peaksData, varargin)

% ------------------------------------------------------------------------
% Method      : UpdateDatabasePeaks()
% Description : connects to the SQL .db file, formats the data in a table,
% and adds it to the peaks table in the SQL database
% ------------------------------------------------------------------------

conn = sqlite(db);

if ~isempty(varargin) && islogical(varargin{1})
    skipDuplicateCheck = varargin{1};
else
    skipDuplicateCheck = false;
end

table = 'peaks';
field = 'peak_time';
index = [];
inputDups = [];

if ~skipDuplicateCheck
    
    fprintf('Checking for Duplicates\n');
    
    for i = 1:length(peaksData)

        if i > length(peaksData)
            fprintf(['[' num2str(i), ' was removed as a duplicate] \n']);
            break
        end 
       
        fprintf(['[', num2str(i), '/', num2str(length(peaksData)), '] \n']);
       
        query = [sprintf('%s', ...
            'SELECT COUNT(*)', ...
            'FROM ', table, ' ', ...
            'WHERE ', field, '=', char(peaksData(i).(field)), '')];
        
        if isempty(peaksData(i).(field))
            data{1} = 1;
        else
            data = fetch(conn, query);
        end
        
        if istable(data) && data{1,1} ~= 0
            index(end+1) = i;
            fprintf('[DUPLICATE IN DATABASE] ');
            fprintf(['peak row: ' num2str(i) '\n']);
        end 
           
        for j = 1:length(peaksData)
            if j > length(peaksData)
                break   
            elseif i~=j && strcmp(peaksData(i).(field), peaksData(j).(field))
                inputDups(end+1) = j;
                fprintf('[DUPLICATE IN INPUT DATA] ')
                fprintf(['peak row: ' num2str(j), '\n']);
                peaksData(j) = [];
            end
        end 
    end
    
    if ~isempty(index)
        peaksData(index) = [];
        fprintf(['[IGNORE] ' num2str(length(index) + length(inputDups)), '\n']);
    else
        fprintf('[OK] \n');
    end
    
    if isempty(peaksData)
        status = 'no data';
        fprintf('[ERROR] No peaks to add\n');
        return
    end
    
end

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

