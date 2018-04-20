function impedancevector = loadImpedanceFile(filename)
    % Loads a file representing impedances. Returns an array of impedance
    % values in the order of channels. This specific file is suited on the
    % needs of our lab because the file might be different elsewhere.
    %
    % Parameters:
    %  filename =  string indicating filename
    %
    % Returns:
    %  impedancevector = vector of impedances (size of channelcount)


    str = fileread(filename);

    C = textscan(str, '%s %f', 'HeaderLines',3, 'Delimiter', ':');

    all_impedances = C{2};

    ids = C{1};

    for i = 1:length(ids)
        b = str2num(ids{i});
        if ~isempty(b)
            channelvector(i) = b;
            impedancevector(i) = all_impedances(i);
        end
    end