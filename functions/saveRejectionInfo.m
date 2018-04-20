function saveRejectionInfo(dpath, fname, stimid, rejepochs, urev_val)
% Save information of manual rejections to a file. Each time this function
% is called it appends the information to the end of the file or starts a
% new one with column headers if no file exists.
%
% Parameters:
%  dpath     = directory path to where to save the file (string)
%  fname     = filename of the original EEG-file (string)
%  stimid    = stimulus id (sting)
%  rejepochs = vector of rejected epoch numbers
%  urev_val  = original event validity of that participant/stimulus [nchan nepoch]

rejfile = [dpath filesep 'EEG_manual_rejection_info.csv'];

% if no file yet
if exist(rejfile, 'file') == 2 
    firsttime = 0;
else
    firsttime = 1;
end

% write
fid = fopen(rejfile, 'a+');

if(fid == -1)
    % do nothing
    warning('Could not open the file to write EEG-statistics.');
    return;
end

if firsttime
    fprintf(fid, 'sep=,\n');
    fprintf(fid, 'file,stim,trial,rejected\n');
end

[row, col] = size(urev_val);

for i=1:col
    if isempty(find(rejepochs == i, 1))
        rej = 0;
    else 
        rej = 1;
    end
    
    fprintf(fid, [fname ',' stimid ',' num2str(i) ',' num2str(rej) '\n']);
end

fclose(fid);