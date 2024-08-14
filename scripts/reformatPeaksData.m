function peaksData = reformatPeaksData(data)

% Define struct fields
peaksFields = {
    'file_path', 'file_name', 'file_size', 'sample_name', 'sample_info',...
    'method_name', 'operator', 'instrument', 'vial', 'sampling_rate', ...
    'time', 'width', 'height', 'area', 'areaOf', 'fit', 'error', ...
    'xmin', 'xmax', 'ymin', 'ymax', 'runtime', 'model', 'revision', ...
    'peakCenterX', 'peakCenterY', 'mz', 'intensity', 'match_score', ...
    'match_file_name', 'match_compound_name', 'match_compound_formula',...
    'match_compound_exact_mass', 'match_num_peaks', 'match_mz', 'match_intensity'};

peaksData = struct();

for i = 1:length(peaksFields)
    peaksData.(peaksFields{i}) = 0;
end

% Add data to new struct
for i = 1:length(data)
    
    if isempty(data(i).peaks)
        continue
    end
    
    for j = 1:length(data(i).peaks)
        
        % Add sample data
        peaksData(end+1,1).file_path = data(i).file_path;
        peaksData(end,1).file_name = data(i).file_name;
        peaksData(end,1).file_size = data(i).file_size;
        peaksData(end,1).sample_name = data(i).sample_name;
        peaksData(end,1).sample_info = data(i).sample_info;
        peaksData(end,1).method_name = data(i).method_name;
        peaksData(end,1).operator = data(i).operator;
        peaksData(end,1).instrument = data(i).instrument;
        peaksData(end,1).vial = data(i).vial;
        peaksData(end,1).sampling_rate = data(i).sampling_rate;

        % Add peaks data
        peaksData(end,1).time = data(i).peaks(j).time;
        peaksData(end,1).width = data(i).peaks(j).width;
        peaksData(end,1).height = data(i).peaks(j).height;
        peaksData(end,1).area = data(i).peaks(j).area;
        peaksData(end,1).areaOf = data(i).peaks(j).areaOf;
        peaksData(end,1).fit = data(i).peaks(j).fit;
        peaksData(end,1).error = data(i).peaks(j).error;
        peaksData(end,1).xmin = data(i).peaks(j).xmin;
        peaksData(end,1).xmax = data(i).peaks(j).xmax;
        peaksData(end,1).ymin = data(i).peaks(j).ymin;
        peaksData(end,1).ymax = data(i).peaks(j).ymax;
        peaksData(end,1).runtime = data(i).peaks(j).runtime;
        peaksData(end,1).model = data(i).peaks(j).model;
        peaksData(end,1).revision = data(i).peaks(j).revision;
        peaksData(end,1).peakCenterX = data(i).peaks(j).peakCenterX;
        peaksData(end,1).peakCenterY = data(i).peaks(j).peakCenterY;
        peaksData(end,1).mz = data(i).peaks(j).mz;
        peaksData(end,1).intensity = data(i).peaks(j).intensity;
        peaksData(end,1).match_score = data(i).peaks(j).match_score;
        
        % Add match data
        if isempty(data(i).peaks(j).library_match)
            continue
        end

        peaksData(end,1).match_file_name = data(i).peaks(j).library_match(1).file_name;
        peaksData(end,1).match_compound_name = data(i).peaks(j).library_match(1).compound_name;
        peaksData(end,1).match_compound_formula = data(i).peaks(j).library_match(1).compound_formula;
        peaksData(end,1).match_compound_exact_mass = data(i).peaks(j).library_match(1).compound_exact_mass;
        peaksData(end,1).match_num_peaks = data(i).peaks(j).library_match(1).num_peaks;
        peaksData(end,1).match_mz = data(i).peaks(j).library_match(1).mz;
        peaksData(end,1).match_intensity = data(i).peaks(j).library_match(1).intensity;

        % Fix compound name
        compoundName = strsplit(peaksData(end,1).match_compound_name, ';');
        peaksData(end,1).match_compound_name = upper(compoundName{1});
    end
end

peaksData(1) = [];

end