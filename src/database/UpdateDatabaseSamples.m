function stat = UpdateDatabaseSamples(db, samplesData, varargin)
 
% ------------------------------------------------------------------------
% Method      : UpdateDatabaseSamples()
% Description : connects to the SQL .db file, checks for dulpicate files
% in the passed in data, formats the data in a table, and adds it to 
% the samples table in the SQL database
% ------------------------------------------------------------------------

conn = sqlite(db);

if ~isempty(varargin) && islogical(varargin{1})
    skipDuplicateCheck = varargin{1};
else
    skipDuplicateCheck = false;
end

table = 'samples';
field = 'md5_checksum';
index = [];

if ~skipDuplicateCheck
    
    fprintf('Checking for Duplicates\n');
    
    for i = 1:length(samplesData)

        if i > length(samplesData)
            fprintf(['[' num2str(i), ' was removed as a duplicate] \n']);
            break
        end 
       
        fprintf(['[', num2str(i), '/', num2str(length(samplesData)), '] \n']);
       
        query = [sprintf('%s', ...
            'SELECT COUNT(*)', ...
            'FROM ', table, ' ', ...
            'WHERE ', field, '=''', char(samplesData(i).(field)), '''')];
        
        if isempty(samplesData(i).(field))
            data{1,1} = 1;
        else
            data = fetch(conn, query);
        end
        
        if istable(data) && data{1,1} ~= 0
            index(end+1) = i;
            fprintf('[DUPLICATE IN DATABASE] ');
            disp(samplesData(i).file_path);
        end 
           
        for j = 1:length(samplesData)
            if i~=j && strcmp(samplesData(i).(field), samplesData(j).(field))
                index(end+1) = j;
                fprintf('[DUPLICATE IN INPUT DATA] ')
                disp(samplesData(j).file_path);
            end
        end 
    end
    
    if ~isempty(index)
        samplesData(index) = [];
        fprintf(['[IGNORE] ' num2str(length(index)), '\n']);
    else
        fprintf('[OK] \n');
    end
    
    if isempty(samplesData)
        stat = 'no data';
        fprintf('[ERROR] No samples to add\n');
        return
    end
    
end

cols = fields(samplesData)';
colNames = {strjoin(cols)};
rows = {};

for i = 1:length(samplesData)
    
    for j = 1:length(cols)
        rows{i,j} = samplesData(i).(cols{j}); 
    end

end

fprintf(['[INSERT] ' num2str(length(rows(:,1))), ' samples\n']);
fprintf('[INSERT] please wait....\n');

data = cell2table(rows, 'VariableNames', cols);

sqlwrite(conn, table, data);

stat = ['added samples: ', num2str(length(rows(:,1)))];

fprintf('[FINISH] Database update complete!\n');

close(conn);

% ---------------------------------------
% Status
% ---------------------------------------
function status(varargin)

switch varargin{1}
    
    case 'exit'
        fprintf([repmat('-',1,50), '\n']);
        fprintf(' EXIT');
        fprintf(['\n', repmat('-',1,50), '\n']);
        
    case 'samples'
        fprintf([' STATUS  Samples prepared: ', varargin{2},'\n']);

    case 'preparing_samples'
        fprintf(['\n', repmat('-',1,50), '\n']);
        fprintf(' PREPARE SAMPLES DATA');
        fprintf(['\n', repmat('-',1,50), '\n']);
          
end

end

end