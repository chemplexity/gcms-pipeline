function status = UpdateDatabaseSamples(conn, db, varargin)
 
% ------------------------------------------------------------------------
% Method      : UpdateDatabaseSamples()
% Description : connets to the SQL .db file, checks for dulpicate files
% in the passed in data, formats the data in a table, and adds it to 
% the SQL database
% ------------------------------------------------------------------------

if ~isopen(conn)
    status = 'connection is closed';
    return
end

if ~isempty(varargin) && islogical(varargin{1})
    skipDuplicateCheck = varargin{1};
else
    skipDuplicateCheck = false;
end

table = 'samples';
field = 'md5_checksum';
index = [];

if length(unique(string({db.(field)}))) < length(db)
    status = 'remove duplicate files from input and try again';
    return
end

if ~skipDuplicateCheck
    
    fprintf('Checking for Duplicates\n');
    
    for i = 1:length(db)
        
        fprintf(['[', num2str(i), '/', num2str(length(db)), '] ']);
       
        query = [sprintf('%s', ...
            'SELECT COUNT(*)', ...
            'FROM ', table, ' ', ...
            'WHERE ', field, '=''', char(db(i).(field)), '''')];
        
        if isempty(db(i).(field))
            data{1} = 1;
        elseif isopen(conn)
            data = fetch(conn, query);
        else
            data{1} = 1;
        end
        
        if iscell(data) && data{1} ~= 0
            index(end+1) = i;
            fprintf('[DUPLICATE] ');
            disp(db(i).file_path);
        else
            fprintf('[OK] \n');
        end
        
    end
    
    if ~isempty(index)
        db(index) = [];
        fprintf(['[IGNORE] ' num2str(length(index)), '\n']);
    end
    
    if isempty(db)
        status = 'no data';
        fprintf('[ERROR] No samples to add\n');
        return
    end
    
end

cols = fields(db)';
colNames = {strjoin(cols)};
rows = {};

for i = 1:length(db)
    
    for j = 1:length(cols)
        rows{i,j} = db(i).(cols{j}); 
    end

end

fprintf(['[INSERT] ' num2str(length(rows(:,1))), ' samples\n']);
fprintf('[INSERT] please wait....\n');

data = cell2table(rows, 'VariableNames', cols);

sqlwrite(conn, table, data);

status = ['added samples: ', num2str(length(rows(:,1)))];

fprintf('[FINISH] Database update complete!\n');

end