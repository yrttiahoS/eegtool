function EEG = detrendEEG(EEG)
% Function that performs detrending to an EEG struct.
%
% Parameters:
%  EEG =  eeglab EEG-struct (epoched)
%
% Returns:
%  EEG =  look up

disp(['Removing trendlines from epochs ' EEG.setname '...']);

% for each stimulus type
 for i=1:EEG.nbchan
     % for each channel

     for j=1:size(EEG.data, 3)
         % for each epoch
         EEG.data(i, :, j) = detrend(EEG.data(i, :, j));
     end
 end
 
 disp('Done.');