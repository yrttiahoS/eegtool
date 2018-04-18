function saveSet(dpath, filename, EEG, ev_val, urev_val)
% Save data from Eegtool as a set file. Transform data from Eegtool
% to set-form.
%
% Parameters:
%  dpath    = directory path to save the set-file to (string)
%  filename = filename of the set-file (string)
%  EEG      = Eeglab epoched EEG-struct
%  ev_val   = ev_val matrix that indicates good/bad epochs [nchan nepochs]
%  urev_val = original ev_val


% remove the 'non-eeglab standard' field 'urepoch' from each
% epoch (if present)
if isfield(EEG.epoch, 'urepoch')
    epoch = rmfield(EEG.epoch, 'urepoch');
    EEG.epoch=epoch;
end

% form filename by combaining stim identifier to input filename
[a, b, c] = fileparts(filename);
filename2 = [b '_' EEG.setname c];

% save set-file
pop_saveset(EEG, 'filename', [dpath filesep filename2], 'check', 'on', 'savemode', 'onefile');

% save EEG-error statistics to a file
% calc

for k=1:size(ev_val,2)
   interpolated_per_column(k) = length(find(ev_val(:,k)==9));
end

errorfile = [dpath filesep 'EEG_error_statistics.csv'];

% if no file yet
if exist(errorfile, 'file') == 2 
    firsttime = 0;
else
    firsttime = 1;
end

% write
fid = fopen(errorfile, 'a+');

if(fid == -1)
    % do nothing
   warning('Could not open the file to write EEG-statistics.');
   return;
end

if firsttime
    fprintf(fid, 'sep=,\n');
    fprintf(fid, 'file,rejected epochs,accepted epochs,max channels interpolated,mean channels interpolated\n');
end
    
fprintf(fid, [filename2 ',' num2str(size(urev_val, 2)-length(interpolated_per_column)) ...
        ',' num2str(length(interpolated_per_column)) ',' num2str(max(interpolated_per_column)) ...
        ',' num2str(mean(interpolated_per_column)) '\n']);
fclose(fid);

end