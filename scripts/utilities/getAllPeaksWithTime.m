function peaks = getAllPeaksWithTime(data, time, timeTolerance)

peaks = [];

if ~isfield(data, 'peaks')
    return
end

for i = 1:length(data)

    peak_match = [];

    for j = 1:length(data(i).peaks)
        if abs(data(i).peaks(j).time - time) <= timeTolerance
            peak_match = [peak_match; data(i).peaks(j)];
        end
    end

    if isempty(peak_match)
        continue
    end
    
    for j = 1:length(peak_match)
        peak_match(j).sampleIndex = i;

        if ~isempty(peak_match(j).library_match)
            peak_match(j).db_id = peak_match(j).library_match.db_id;
        else
            peak_match(j).db_id = '';
        end
    end

    peaks = [peaks; peak_match];

end

end