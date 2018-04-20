function ERPAnalysis(dpath, filenames_to_analyze)
    % Calculate erp for each file and display the results on GUI.
    % Extracting samples can be done withing the GUI.
    %
    % Parameters:
    %  dpath                = path to folder where files are (string)
    %  filenames_to_analyze = cell-table of filenames as strings

    hwait = waitbar(0, 'Calculating ERP...');
    disp('Calculating ERP...');

    for i=1:length(filenames_to_analyze)
        % avg will be i=1, so start from 2

        filename = filenames_to_analyze{i};

        % load one file
        EEG = pop_loadset(strcat(dpath, filename));

        fnames{i} = filename;
        condition{i} = EEG.setname;

        disp(['Calculating ERP for ' filename '...']);

        [datamatrix{i}, eventcount{i}] = calcERP(EEG.data);
        xdata{i} = EEG.times;

        waitbar((i)/(length(filenames_to_analyze)+1), hwait);
    end

    disp('Calculation complete.');
    waitbar((i)/(length(filenames_to_analyze)+1), hwait);
    close(hwait);

    % open visualizing & extraction function
    visualize1d(fnames, condition, datamatrix, xdata, eventcount, ...
                EEG.chanlocs, 'ERP', [-50 50], {'Time', 'uV'});