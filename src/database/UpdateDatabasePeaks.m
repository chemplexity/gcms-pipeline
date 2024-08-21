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
fieldOne = 'peak_time';
fieldTwo = 'sample_id';
index = [];

if ~skipDuplicateCheck
    
    fprintf('Checking for Duplicates\n');
    
    for i = 1:length(peaksData)
       
        fprintf(['[', num2str(i), '/', num2str(length(peaksData)), '] \n']);
       
        query = [sprintf('%s', ...
            'SELECT COUNT(*)', ...
            'FROM ', table, ' ', ...
            'WHERE ', fieldOne, '=''', char(peaksData(i).(fieldOne)), '''', ...
            'AND ', fieldTwo, '=''', char(peaksData(i).(fieldTwo)), '''')];
        
        if isempty(peaksData(i).(fieldOne)) | ...
            isempty(peaksData(i).(fieldTwo))
            data{1,1} = 0;
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
            elseif i~=j && strcmp(peaksData(i).(fieldOne), peaksData(j). ...
                    (fieldOne)) && strcmp(peaksData(i).(fieldTwo), ...
                    peaksData(j).(fieldTwo))
                index(end+1) = j;
                fprintf('[DUPLICATE IN INPUT DATA] ')
                fprintf(['peak row: ' num2str(j), '\n']);
            end
        end 
    end
    
    if ~isempty(index)
        peaksData(index) = [];
        fprintf(['[IGNORE] ' num2str(length(index)), '\n']);
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