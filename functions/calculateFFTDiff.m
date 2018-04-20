function [datamatrix, xdata, eventcount] = calculateFFTDiff(EEG)
    % Calculates average difference spectrum of input EEG file. 
    % The pre-stimulus time-window must be of the same length 
    % as the post-stimulus time-window.
    %
    % Parameters:
    %  EEG        =  Eeglab's EEG-datastructure
    %
    % Returns:
    %  datamatrix =  [channels datapoints] where datapoints are values of
    %                fft(after)-fft(before)
    %  xdata      =  vector of values for the x-axis
    %  eventcount =  over how many epochs have been calculated 

    % find indexes of the data before and after stimulus
    zeroloc = find(EEG.times==0);
    indbefore = 1:zeroloc-1;
    indafter = zeroloc:zeroloc+length(EEG.times(zeroloc:end))-1;

    % check that pre- and afterstimulus times are of equal
    % length
    if length(indbefore) ~= length(indafter)
        if nargin == 3
            close(hwait);
        end
        error('Pre- and after-stimulus times are not of equal length.');
    end

    % calc fft's
    [databefore, ~, ~] = calculateFFT(EEG.data(:, indbefore, :), ...
                                      EEG.srate, 1);
    [dataafter, xdata, eventcount] = calculateFFT(EEG.data(:, indafter, :), ...
                                                  EEG.srate, 1);

    % calc fft-difference
    datamatrix = dataafter - databefore;