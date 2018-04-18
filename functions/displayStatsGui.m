function displayStatsGui(advicestring, setname, eventids, removed_epochs)
% Function generates a GUI which displays the statistics of removed epochs.
%
% Parameters: 
%  advice_string  = hint string to give user info
%  setname        = string of filename to generate copystring
%  eventids       = event ids (cell-vector of strings)
%  removed_epochs = cell-vector of vectors containing numbers of removed
%                   epochs for corresponding event ids

% generate figure and switch off unneeded figure controls
h.fig = figure('position', [400 400 200 250], 'menubar', 'none', ...
               'numbertitle', 'off', 'color', 'white');	

% move gui to the center of the screen
movegui(gcf, 'center');

fc=[];
sc=[];
for i=1:length(eventids)
    rows{i}=[eventids{i} ': [' num2str(removed_epochs{i}) ']' ];
    fc = [fc char(39) eventids{i} char(39) ', '];
    sc = [sc '[' num2str(removed_epochs{i}) '], '];
end

% remove unnecessary trail
fc = fc(1:end-2);
sc = sc(1:end-2);

% parse copystring
copystring = [ 'eegtoolPreprocess(d_path, d_output_path, ' char(39) setname char(39) ', save_mode, continuous_procedure, {' fc '}, epoch_limits, {' sc '}, epoch_procedure);'];


% define ui elements
h.vectortext = uicontrol('Style', 'text', 'string', advicestring, 'position', [10 200 180 40]);

h.vectoredit = uicontrol('Style', 'listbox', 'string', rows, 'position', [10 70 180 125]);

h.readyb = uicontrol('Style', 'pushbutton', 'string', 'Close', ...
                   'horizontalalignment', 'center', 'position', [10 10 180 25], 'callback', @(a,b) (close));

h.copyb = uicontrol('Style', 'pushbutton', 'string', 'Copy summary to clipboard', ...
                   'horizontalalignment', 'center', 'position', [10 40 180 25], 'callback', {@copy_callback, copystring});

function copy_callback(~, ~, copystring)

 clipboard('copy', copystring);