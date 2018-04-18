function saveMatFile(file, setid, EEG, ALLEEG, event_validity, ...
                     urevent_validity, removed_epochs, vinfo)
% Saves EEG-study as a .mat-file for full Eegtool-support (EEGDATA-struct)
%
% Parameters:
%  file             = path and filename for the file to be saved
%  EEG              = EEGLAB EEG-struct
%  ALLEEG           = cell array of epoched EEG-structs
%  event_validity   = cell-matrix describing validity of events after artefact
%                    detection and manual correction
%  urevent_validity = original event_validity matrix
%  removed_epochs   = containers.Map on event removal information
%                     (keys:event ids)
%  vinfo            = video-info-struct extracted from the eegmplayer-object
%                    (optional, if no video use only 7 arguments)

disp(['Saving EEGDATA-file ' file '...']);

% matlab file -> form and save EEGDATA
EEGDATA.filename = setid;
EEGDATA.EEG = EEG;
EEGDATA.event_validity = event_validity;
EEGDATA.urevent_validity = urevent_validity;
EEGDATA.removed_epochs = removed_epochs;

EEGDATA.ALLEEG = ALLEEG;

if nargin == 8
   % truth value to validate if video-object is available
    EEGDATA.vinfo = vinfo;
end

save(file, 'EEGDATA');
disp('Done.');