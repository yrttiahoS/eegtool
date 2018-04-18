function [filename, EEG,  ALLEEG, event_validity, urevent_validity, removed_epochs, vinfo] = loadMatFile(file)
% load EEGDATA-struct from file
%
% Parameters:
%  file             = full path of the mat-file
%
% Returns:
%  filename         = original filename-string
%  EEG              = Eeglab's EEG-struct (continuous signal)
%  ALLEEG           = an array of epoched EEG-structs
%  event_validity   = event-validity information (containers.Map)
%  urevent_validity = original event_validity
%  removed_epochs   = containers.Map on event removal information
%                     (keys:event ids)
%  vinfo            = video-information struct (empty if no video)

disp('Loading EEGDATA-file structure from .mat file...');
load(file, 'EEGDATA');

filename = EEGDATA.filename;
EEG = EEGDATA.EEG;
ALLEEG = EEGDATA.ALLEEG;
event_validity = EEGDATA.event_validity;
urevent_validity = EEGDATA.urevent_validity;
removed_epochs = EEGDATA.removed_epochs;

vinfo = [];

if isfield(EEGDATA, 'vinfo')% truth value to validate if video-object is available
    vinfo = EEGDATA.vinfo;
end

disp('Loaded.');