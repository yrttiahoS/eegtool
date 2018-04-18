function [ev_val, disp_val] = artefactDetection(EEG, type, treshold)
% Performs artefact detection to datavector according to the parameters
% returns rating for the input vector.
%
% Parameters:
% data          =  1-dimensional vector containing EEG-data points
% treshold      =  A comparison value to the analysis: function(data) smaller than this -> marked good.                        
%
% Output:
% ev_val        =  array [channel epoch] with score 0 if detected 
%                  good, other values for detected errors
% disp_val      =  vector of all values of current type

disp(['Detecting artefacts with method: ' type '...']);

ev_val = zeros(EEG.nbchan, length(EEG.epoch));

counter = 1;
% for each stimulus type
for i=1:EEG.nbchan
    % for each channel

    for j=1:EEG.trials %length(EEG.epoch)
        % for each epoch
        
        data = EEG.data(i, :, j);
        data_rating = 0;

        switch type
            case 'Treshold'
                % if curve goes beyond or above treshold
                val = max(abs(data));

            case 'Max difference'
                % if the difference between min and max of data exceeds treshold
                val = max(data) - min(data);

            case 'RMS'
                % RMS-test
                val = calculateRMS(data);
        end
        
        % compare val from the sample to treshold
        if val > treshold
            data_rating = 1;
        end

        ev_val(i, j) = data_rating;

        disp_val(counter) = val;
        counter = counter + 1;
    end
end