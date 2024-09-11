function peaks = getAllPeaksWithId(data, peakId)

peaks = [];

if ~isfield(data, 'peaks')
    return
end

for i = 1:length(data)

    if ~isfield(data(i).peaks, 'library_match')
        continue
    end

    library_match = [data(i).peaks.library_match];
    peak_match = data(i).peaks(strcmpi(peakId, {library_match.db_id}));
    
    if isempty(peak_match)
        continue
    end
    
    for j = 1:length(peak_match)
        peak_match(j).sampleIndex = i;
    end

    peaks = [peaks; peak_match];

end

end