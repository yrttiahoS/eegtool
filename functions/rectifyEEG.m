function EEG = rectifyEEG(EEG)
% Function that calculates absolute values from each corresponding signal
% in EEG struct.
%
% Parameters:
%  EEG =  eeglab EEG-struct (epoched)
%
% Returns:
%  EEG =  look up

disp(['Rectifying EEG-signals from epochs ' EEG.setname '...']);

% for each stimulus type
 for i=1:EEG.nbchan
     % for each channel

     for j=1:size(EEG.data, 3)
         % for each epoch
         EEG.data(i, :, j) = abs(EEG.data(i, :, j));
     end
 end
 
 disp('Done.');