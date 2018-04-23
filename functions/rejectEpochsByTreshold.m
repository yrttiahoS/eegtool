function [new_EEG, new_ev_val, removed_trials_ur] = ...
          rejectEpochsByTreshold(EEG, ev_val, treshold)
    % Reject epochs from epoched EEG-dataset and 2-dimensional
    % ev_val-matrix. Ev_val indicates which epochs are good and which are
    % bad.
    % 
    % Parameters:
    %  EEG        =  eeglab EEG-dataset (epoched)
    %  ev_val     =  matrix of values [channel epoch] containing values
    %                0-9: 0 good,
    %                1 bad, 9 interpolated
    %  treshold   =  what is the maximum count of bad channels in one
    %                epoch. If exceeded -> epoch removed. 
    % Returns:
    %  new_EEG    =  Same EEG-struct as parameter but without epochs that
    %                contained more than treshold of bad epochs
    %  new_ev_val =  New ev_val containing updated information after epoch
    %                removal

    disp(['Rejecting epochs with treshold ' num2str(treshold) '...']);

    rejected_epochs = [];
    removed_trials_ur = [];


    for k=1:EEG.trials
        % roll throught all the events for detecting whether there are
        % "bad" epochs

        badchans = find(ev_val(:, k));

        % if the user selects "reject epoch, append the epoch number to
        % 'rejected_epochs'
        if length(badchans) > treshold
            rejected_epochs = [rejected_epochs k];
            removed_trials_ur = [removed_trials_ur EEG.epoch(k).urepoch];
        end
    end

    % remove the selected epochs from this event
    [new_EEG, new_ev_val] = removeEpoch(EEG, ev_val, rejected_epochs);