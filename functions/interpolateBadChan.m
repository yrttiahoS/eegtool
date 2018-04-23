function [interpd_EEG, interpd_ev_val] = interpolateBadChan(EEG, ev_val)
    % Function takes input an epoched EEG-dataset and 2-dimensional
    % ev_val-matrix. Ev_val indicates which epochs are good and which are
    % bad and therefore should be interpolated.
    % 
    % Parameters:
    % EEG                 =  eeglab EEG-dataset (epoched)
    % ev_val              =  matrix of values [channel epoch] containing
    %                        values 0-9: 0 good,
    %                        1 bad, 9 interpolated
    %
    % Returns:
    % interpolated_EEG    = EEG after interpolation
    % interpolated_ev_val = updated ev_val after interpolation

    disp('Interpolating bad channels...');

    for k=1:EEG.trials
        % roll throught all the events for interpolation

        % create temporary ALLEEG-dataset epoched -> continuous with just
        % datapoints of one epoch, epoch number i
        % [temp_ALLEEG, event_indices] = 
        % pop_selectevent(ALLEEG, 'event', i);
        % decided to do this with my own conversion because it proved to
        % be easier
        temp_EEG = EEG;

        % set trials value to be 1 etc.
        temp_EEG.trials = 1;
        temp_EEG.epoch = [];
        temp_EEG.event = [];

        % make it so that it has only 1 epoch data in data-section
        temp_EEG.data = temp_EEG.data(:,:,k);

        badchans = find(ev_val(:,k));

        % mark channels on event_validity as interpolated (bad)
        ev_val(badchans,k) = 9;

        % display event name and epoch number, just for future
        % logging/debugging
        if(~isempty(badchans))
            disp(strcat('Event: ', EEG.setname, ' epoch: ', num2str(k))); 
        end

        % interpolate bad channels
        temp_EEG = eeg_interp(temp_EEG, badchans);
        EEG.data(:,:,k) = temp_EEG.data;
    end

    interpd_EEG = EEG;
    interpd_ev_val = ev_val;