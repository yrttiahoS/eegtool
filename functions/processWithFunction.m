function EEG = processWithFunction(fun_name, EEG)
% Wrapper for eval-function to 

disp(['Applying function ' fun_name ' to ' EEG.setname '...']);

% for each stimulus type
 for i=1:EEG.nbchan
     % for each channel

     for j=1:size(EEG.data, 3)
         % for each epoch
         EEG.data(i, :, j) = eval([fun_name '(EEG.data(i, :, j))']);
     end
 end
 
 disp('Done.');