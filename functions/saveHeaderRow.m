function saveHeaderRow(fid, chanlocs, opt1, opt2, opt3, opt4)
% Saves header row to a file identified by fid.
% Header row includes column headers (for other data and channels)
%
% Parameters:
%  fid      = file identifier (handle)
%  chanlocs = channel-locations struct from EEG-struct
%  opt1     = optional field 'name' 1 (string)
%  opt2     = optional field 'name' 2 (string)
%  opt3     = optional field 'name' 3 (string)
%  opt4     = optional field 'name' 4 (string)

% get column headers to cell-vector
for i=1:length(chanlocs)
    headerRow{i} = chanlocs(i).labels;
end

desc = sprintf('%s,%s,%s,%s,%s,%s,%s,%s,%s,', 'setID', ...
               'Processing date','type','epochs','atype', ...
               opt1,opt2,opt3,opt4);

fprintf(fid, 'sep=,\n');
% append to file: the column row
writeRow(fid, desc, headerRow);