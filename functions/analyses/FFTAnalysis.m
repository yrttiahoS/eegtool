function FFTAnalysis(dpath, filenames_to_analyze)
    % Calculate FFT for each file and displays the results on GUI.
    % Extracting samples can be done withing the GUI.
    %
    % Parameters:
    %  dpath                = path to folder where files are (string)
    %  filenames_to_analyze = cell-table of filenames as strings

    hwait = waitbar(0, 'Calculating FFT...');
    disp('Calculating FFT...');

    for i=1:length(filenames_to_analyze)
        % avg will be i=1, so start from 2

        filename = filenames_to_analyze{i};

        % load one file
        EEG = pop_loadset(strcat(dpath, filename));

        fnames{i} = filename;
        condition{i} = EEG.setname;

        disp(['Calculating FFT for ' filename '...']);

        % 3. parameter 0 = no window, 1 = hann windowing
        % xdata = frequency
        [datamatrix{i},xdata{i},eventcount{i}] = calculateFFT(EEG.data, ...
                                                              EEG.srate,1);

        waitbar((i)/(length(filenames_to_analyze)+1), hwait);
    end

    disp('Calculation complete.');
    waitbar((i)/(length(filenames_to_analyze)+1), hwait);
    close(hwait);

    % open visualizing & extraction function
    visualize1d(fnames, condition, datamatrix, xdata, eventcount, ...
                EEG.chanlocs, 'FFT', [0 10], {'Frequency (Hz)', '|Y(f)|'});