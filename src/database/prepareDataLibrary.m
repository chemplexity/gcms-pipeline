function db = prepareDataLibrary(data)

% ------------------------------------------------------------------------
% Method      : prepareDataLibrary
% Description : prepares the passed in data to be added to the library
% table in the SQL database by creating a copy with the correct field names
% ------------------------------------------------------------------------

db = [];

for i=1:length(data)

    db(i).file_path = data(i).file_path;
    db(i).file_name = data(i).file_name;
    db(i).file_size = data(i).file_size;
    db(i).compound_name = data(i).compound_name;
    db(i).compound_synonym = data(i).compound_synonym;
    db(i).compound_formula = data(i).compound_formula;
    db(i).compound_mw = data(i).compound_mw;
    db(i).compound_exact_mass = data(i).compound_exact_mass;
    db(i).compound_retention_time = data(i).compound_retention_time;
    db(i).compound_retention_index = data(i).compound_retention_index;
    db(i).cas_id = data(i).cas_id;
    db(i).nist_id = data(i).nist_id;
    db(i).db_id = data(i).db_id;
    db(i).smiles = data(i).smiles;
    db(i).inchikey = data(i).inchikey;
    db(i).ion_mode = data(i).ion_mode;
    db(i).collision_energy = data(i).collision_energy;
    db(i).comments = data(i).comments;
    db(i).num_peaks = data(i).num_peaks;

    % should be 2:end?
    [mz, intensity] = convertSpectraToText(data(i).mz, data(i).intensity)

    db(i).mz = mz;
    db(i).intensity = intensity;
    db(i).date_created = datestr(now(), 'yyyy-mm-ddTHH:MM:SS');

end