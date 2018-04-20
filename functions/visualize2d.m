function  visualize2d(fnames, condition, datamatrix, xdata, ydata, ...
                      channels, eventcount, chanlocs)
% Displays two-dimensional ERP's on a GUI. Various outputs can be taken
% out of the function such as mean, max or min.
%
% Parameters:
%  fnames     = cell table with i cells. i:th cell identifiers of i:th row in datamatrix and xdata
%  condition  = cell table with i cells. i:th cell is the condition for
%               i:th file. This allows grouping by condition. 
%  datamatrix = cell table with i cells. Cell i is the datamatrix for fnames{i}
%  xdata      = x-axis pointvector for the i:th datamatrix
%  eventcount = vector of event counts for each file
%  ydata      = y-axis pointvector for the i:th datamatrix
%  channels   = cell table with vector content of channels to plot for the i:th datamatrix 
%  chanlocs   = channel locations struct (eeglab-format)

% draw the head-background gui and store figure handle
h.visualize2d = headGui('Eegtool - TF-analysis');

% define gui elements

%%%%%%%%%%%%%%%%%%%%% upper area %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h.subjtext = uicontrol('Style', 'text', 'string', 'File', ...
                       'units', 'normalized', 'position', [0.01 0.955 0.03 0.03], 'horizontalalignment', 'left');

h.subjpopup = uicontrol('Style', 'popupmenu', 'string', 'All', ...
                        'horizontalalignment', 'center', 'units', 'normalized', 'position', [0.05 0.96 0.15 0.03]);

h.group_fname_button = uicontrol('Style', 'pushbutton', 'string', 'Group by filename', ...
                                 'units', 'normalized', 'position', [0.01 0.91 0.15 0.03], ...
                                 'tooltipstring', 'Form subject group-averages for visualization (not saved).');

h.group_condition_button = uicontrol('Style', 'pushbutton', 'string', 'Group by condition', ...
                                     'units', 'normalized', 'position', [0.01 0.87 0.15 0.03], ...
                                     'tooltipstring', 'Form subject group-averages for visualization (not saved).');

h.group_view_button = uicontrol('Style', 'togglebutton', 'string', 'Group view', 'Enable', 'off',...
                                'units', 'normalized', 'position', [0.01 0.83 0.15 0.03], ...
                                'tooltipstring', 'Form subject group-averages for visualization (not saved).');
                                 
%%%%%%%%%%%%%%%%%%%%% lower area %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


h.cranget = uicontrol('Style', 'text', 'string', 'Color limits', ...
                      'horizontalalignment', 'center', 'units', 'normalized', 'position', [0.01 0.05 0.06 0.03]);

h.cmaxe = uicontrol('Style', 'edit', 'string', '10', ...
                    'horizontalalignment', 'center', 'units', 'normalized', 'position', [0.16 0.05 0.05 0.03]);

h.cmine = uicontrol('Style', 'edit', 'string', '-10', ...
                    'horizontalalignment', 'center', 'units', 'normalized', 'position', [0.10 0.05 0.05 0.03]);

h.eventtext = uicontrol('Style', 'text', 'string', 'Choose sample type', ...
                        'units', 'normalized', 'position', [0.01 0.01 0.10 0.03]);

sampletypes = {'mean', 'max', 'min', 'max_lat', 'min_lat'};

h.samplepopup = uicontrol('Style', 'popupmenu', 'string', sampletypes, ...
                          'units', 'normalized', 'position', [0.12 0.01 0.09 0.03]);

h.ranget = uicontrol('Style', 'text', 'string', 'Range (ms)', ...
                     'units', 'normalized', 'position', [0.22 0.01 0.08 0.03]);

h.freqranget = uicontrol('Style', 'text', 'string', 'Range (Hz)', ...
                         'horizontalalignment', 'center', 'units', 'normalized', 'position', [0.22 0.05 0.08 0.03]);

h.ymaxe = uicontrol('Style', 'edit', 'string', '40', ...
                    'horizontalalignment', 'center', 'units', 'normalized', 'position', [0.39 0.05 0.05 0.03]);
    
h.ymine = uicontrol('Style', 'edit', 'string', '10', ...
                    'horizontalalignment', 'center', 'units', 'normalized', 'position', [0.32 0.05 0.05 0.03]);               
               
h.xmine = uicontrol('Style', 'edit', 'string', 'min', ...
                    'units', 'normalized', 'position', [0.32 0.01 0.05 0.03]);

h.xmaxe = uicontrol('Style', 'edit', 'string', 'max', ...
                    'units', 'normalized', 'position', [0.39 0.01 0.05 0.03]);
                 
h.save_results_button = uicontrol('Style', 'pushbutton', 'string', 'Extract', ...
                                  'units', 'normalized', 'position', [0.85 0.01 0.13 0.03]);

% set some background elements white
hChildren = get(gcf, 'Children');
set(hChildren(strcmp(get(hChildren, 'style'), 'text')), 'backgroundcolor', [1 1 1]);
set(hChildren(strcmp(get(hChildren, 'style'), 'checkbox')), 'backgroundcolor', [1 1 1]);                  
                              
% generate the list of subjects for the event box
set(h.subjpopup, 'String', fnames);

axdim = [0.05 0.04];

% draw axes to their righteous places
%%%%%%%%%%% wrong parameters -> known
h.haxes = drawTopoAxis(h.visualize2d, chanlocs, axdim, 'Time(ms)', 'Frequency(Hz)');

set(h.group_view_button, 'callback', {@group_view_callback, h, fnames, datamatrix, xdata, ydata, channels, chanlocs});
set(h.group_fname_button, 'callback', {@group_fname_callback, h, fnames, datamatrix, xdata, ydata, channels, chanlocs});
set(h.group_condition_button, 'callback', {@group_condition_callback, h, condition, datamatrix, xdata, ydata, channels, chanlocs});
set(h.subjpopup, 'callback', {@edit_callback, h, datamatrix, xdata, ydata, channels, chanlocs});
set(h.cmine, 'callback', {@edit_callback, h, datamatrix, xdata, ydata, channels, chanlocs});
set(h.cmaxe, 'callback', {@edit_callback, h, datamatrix, xdata, ydata, channels, chanlocs});
set(h.save_results_button, 'callback', {@save_results_callback, h, fnames, datamatrix, xdata, ydata, channels, eventcount, chanlocs});

h.group_view_button.userdata.groupview = {};

%PLOT
drawTf(h, datamatrix{1}, xdata{1}, ydata{1}, channels{1}, chanlocs);

% get xmin and xmax values
e.xmin = floor(min(xdata{1}));
e.xmax = round(max(xdata{1}));

% get ymin and ymax values
k.ymin = min(ydata{1});
k.ymax = max(ydata{1});

set(h.xmine, 'string', num2str(e.xmin));
set(h.xmaxe, 'string', num2str(e.xmax));
set(h.ymine, 'string', num2str(k.ymin));
set(h.ymaxe, 'string', num2str(k.ymax));

h.xmine.UserData = e;
h.xmaxe.UserData = e;
h.ymine.UserData = k;
h.ymaxe.UserData = k;


function edit_callback(~, ~, h, datamatrix, xdata, ydata, channels, chanlocs)
% callback-function for the re-referencing-button and rereferencing-edit

% get subject
subj = get(h.subjpopup, 'Value');

istoggled = get(h.group_view_button, 'value');

if istoggled
    % group view
    combined = getappdata(gcf, 'combined');
    
    for i = 1:length(combined)
        cdatamatrix{i} = combined(i).datamatrix;
        cxdata{i} = combined(i).xdata;
        cydata{i} = combined(i).ydata;
        cchannels{i} = combined(i).channels;
        cchanlocs = combined(i).chanlocs;
    end
    drawTf(h, cdatamatrix{subj}, cxdata{subj}, cydata{subj}, cchannels{subj}, chanlocs);
else
    drawTf(h, datamatrix{subj}, xdata{subj}, ydata{subj}, channels{subj}, chanlocs);
end

function group_view_callback(hObject, ~, h, fnames, datamatrix, xdata, ydata, channels, chanlocs)

istoggled = get(hObject, 'value');

% TODO -> userdatan alustus, combined siirto userdataan jne.

if istoggled
    % group view
    combined = getappdata(gcf, 'combined');
    
    for i = 1:length(combined)
        sets{i} = combined(i).id;
        cdatamatrix{i} = combined(i).datamatrix;
        cxdata{i} = combined(i).xdata;
        cydata{i} = combined(i).ydata;
        cchannels{i} = combined(i).channels;
        cchanlocs = combined(i).chanlocs;
    end

    set(h.subjpopup, 'value', 1);
    set(h.subjpopup, 'string', sets);
    set(h.subjtext, 'string', 'Group');

    set(h.subjpopup, 'callback', {@edit_callback, h, cdatamatrix, cxdata, cydata, cchannels, cchanlocs});
    drawTf(h, cdatamatrix{1}, cxdata{1}, cydata{1}, cchannels{1}, chanlocs);
else
    % normal view
    set(h.subjpopup, 'value', 1);
    set(h.subjpopup, 'string', fnames);
    set(h.subjtext, 'string', 'Participant');
    
    set(h.subjpopup, 'callback', {@edit_callback, h, datamatrix, xdata, ydata, channels, chanlocs});
    drawTf(h, datamatrix{1}, xdata{1}, ydata{1}, channels{1}, chanlocs);
end


function group_condition_callback(~,~, h, condition, datamatrix, xdata, ydata, channels, chanlocs)

uniqcondition = unique(condition);

selected_conditions = listdlg('PromptString','Select a file:',...
                                'SelectionMode','multiple',...
                                'ListString', uniqcondition);

if isempty(selected_conditions)
    return;
end

% open group view button
set(h.group_view_button, 'Enable', 'off');

combined = getappdata(gcf, 'combined');
len = length(combined);
setname = inputdlg('Give name to a set', 'Prompt', 1, {['Set ' num2str(len+1)]});

% calculate ERP for this set of participants with these conditions
firsttime = 1;
filecount = 0;

for i = selected_conditions

    participants_with_this_condition = find(strcmp(condition, uniqcondition{i}));
    
    for k = participants_with_this_condition
        for j = channels{i}
            if firsttime
                catmatrix{j} = datamatrix{k}{j};
            else
                catmatrix{j} = cat(3, catmatrix{j}, datamatrix{k}{j});
            end
        end
        firsttime = 0;
        filecount = filecount+1;
    end
end

% 
% catmatrix = [];
% for i = selected_conditions
%   rows_with_this_condition = find(strcmp(condition, uniqcondition{i}));
%     catmatrix = cat(3, catmatrix, datamatrix{rows_with_this_condition});
% end

% calculate means
for j = channels{1}
    meanmatrix{j} = mean(catmatrix{j}, 3);
end

% store to appdata% store to appdata
combined(len+1).id = [setname{1} ' (' num2str(filecount) ')'];
combined(len+1).datamatrix = meanmatrix;
combined(len+1).xdata = xdata{1};
combined(len+1).ydata = ydata{1};
combined(len+1).channels = channels{1};
combined(len+1).chanlocs = chanlocs;
setappdata(gcf, 'combined', combined);

% open group view button
set(h.group_view_button, 'Enable', 'on');

if get(h.group_view_button, 'value')
    % if in group-view mode, add to the end of the popupmenu
    for i = 1:length(combined)
        sets{i} = combined(i).id;
        cdatamatrix{i} = combined(i).datamatrix;
        cxdata{i} = combined(i).xdata;
        cydata{i} = combined(i).ydata;
        cchannels{i} = combined(i).channels;
        cchanlocs = combined(i).chanlocs;
    end
    
    set(h.subjpopup, 'callback', {@edit_callback, h, cdatamatrix, cxdata, cydata, cchannels, cchanlocs});
    set(h.subjpopup, 'string', sets);
end


function group_fname_callback(~, ~, h, fnames, datamatrix, xdata, ydata, channels, chanlocs)

    
selected_participants = listdlg('PromptString','Select a file:',...
                                'SelectionMode','multiple',...
                                'ListString',fnames(1:end));

if isempty(selected_participants)
    return;
end

combined = getappdata(gcf, 'combined');
len = length(combined);
setname = inputdlg('Give name to a set', 'Prompt', 1, {['Set ' num2str(len+1)]});

% calculate ERP for this set of participants

firsttime = 1;

for i = selected_participants

    for j = channels{i}
        if firsttime 
            catmatrix{j} = datamatrix{i}{j};
        else
            catmatrix{j} = cat(3, catmatrix{j}, datamatrix{i}{j});
        end
    end
    
    firsttime = 0;
end

% calculate means
for j = channels{1}
    meanmatrix{j} = mean(catmatrix{j}, 3);
end

% store to appdata
combined(len+1).id = [setname{1} ' (' num2str(length(selected_participants)) ')'];
combined(len+1).datamatrix = meanmatrix;
combined(len+1).xdata = xdata{1};
combined(len+1).ydata = ydata{1};
combined(len+1).channels = channels{1};
combined(len+1).chanlocs = chanlocs;
setappdata(gcf, 'combined', combined);

% open group view button
set(h.group_view_button, 'Enable', 'on');

if get(h.group_view_button, 'value')
    % if in group-view mode, add to the end of the popupmenu
    for i = 1:length(combined)
        sets{i} = combined(i).id;
        cdatamatrix{i} = combined(i).datamatrix;
        cxdata{i} = combined(i).xdata;
        cydata{i} = combined(i).ydata;
        cchannels{i} = combined(i).channels;
        cchanlocs = combined(i).chanlocs;
    end

    set(h.subjpopup, 'string', sets);
    set(h.subjpopup, 'callback', {@edit_callback, h, cdatamatrix, cxdata, cydata, cchannels, cchanlocs});
end



function save_results_callback(~, ~, h, fnames, datamatrix, xdata, ydata, channels, eventcount, chanlocs)
% callback for the save results-button

save_results(h, fnames, datamatrix, xdata, ydata, channels, eventcount, chanlocs);

function save_results(h, fnames, datamatrix, xdata, ydata, channels, eventcount, chanlocs)
  
% find first indice after 'xmin' and last before 'xmax' edit
ind_xmin = find(xdata{1}>=str2num(get(h.xmine, 'String')), 1, 'first'); %#ok<*ST2NM>
ind_xmax = find(xdata{1}<=str2num(get(h.xmaxe, 'String')), 1, 'last');

% smoothen (add 0.1) a little bit to easen float number comparisons 
ind_ymin = find(ydata{1}>=str2num(get(h.ymine, 'String'))-0.1, 1, 'first');
ind_ymax = find(ydata{1}<=str2num(get(h.ymaxe, 'String'))+0.1, 1, 'last');

% define sample range
range_x = xdata{1}(ind_xmin:ind_xmax);
range_y = ydata{1}(ind_ymin:ind_ymax);

xmin = range_x(1);
xmax = range_x(end);

ymin = range_y(1);
ymax = range_y(end);

%%%%%%%%%%%%%%%%%%%%%%%%%% filecontrol-code %%%%%%%%%%%%%%%%%%%%%%%%%%%
[filename, path, ~] = uiputfile('*.csv');

% filename was gotten
if (filename == 0)
    return;
end

%open the file for writing
fid = fopen(strcat(path, filename), 'a+');

if fid == -1
    errordlg('Could not open the file for writing.');
    return;
end
%%%%%%%%%%%%%%%%%%%%%%%%%% /filecontrol-code %%%%%%%%%%%%%%%%%%%%%%%%%%

% save header row to the file
saveHeaderRow(fid, chanlocs, 'xmin', 'xmax', 'ymin', 'ymax');

% get sample type
contents = cellstr(get(h.samplepopup,'String'));
stype = contents{get(h.samplepopup, 'Value')};

% all subjects
subjvector = 1:length(fnames);

% take sample from 2-dimensional matrix
% loop through all subjects and their stimuluses and write to ->file
for k = subjvector

    for l = channels{k}
        data = datamatrix{k}{l}(ind_ymin:ind_ymax, ind_xmin:ind_xmax);
        SAMPLE{l} = num2str(calcSample(stype, data, range_x)); 
        clearvars data;
    end
    
    writeSampleRow(fid, SAMPLE, fnames{k}, stype, 'T-F', num2str(eventcount{k}), ...
                   num2str(xmin), num2str(xmax), num2str(ymin), num2str(ymax));
end


% close the file
fclose(fid);

    
 function drawTf(h, data, xdata, ydata, channels, chanlocs)
% fills all the axes objects in the head 
% parameters are: 
% h         = handle structure
% chanlocs  = channel location data (to plot channel labels)

colormap(jet(256));

for i = channels
    
    set(gcf, 'currentaxes', h.haxes(i));
    cla;
    hold all;
    imagesc(xdata, ydata, data{i});
    axis tight;
    chanlabels = chanlocs(i).labels;

    % put channel name text to the upper right corner
    yscale = get(gca, 'Ylim');
    xscale = get(gca, 'Xlim');

    text(xscale(2), yscale(2)-0.1*(yscale(2)-yscale(1)), 30, chanlabels, ...
                 'fontunits', 'normalized', 'fontsize', 0.25, 'horizontalalignment', 'right', 'color', 'black');

    line( [0 0], get(gca, 'ylim'), 'color', 'black', 'linestyle', ':');

    % set labels to axis
    labels.xid = 'Time (ms)';
    labels.yid = 'Frequency (Hz)';
    set(h.haxes(i), 'userdata', labels);
    set(h.haxes(i), 'clim', [str2num(get(h.cmine, 'string')) str2num(get(h.cmaxe, 'string'))]);

    % set axes and it's childrens buttondownfcn to axesclick
    set(gca, 'ButtonDownFcn', {@axesClick, h});
    set(get(h.haxes(i), 'children'), 'ButtonDownFcn', {@axesClick, h});
    hold off;
end


function SAMPLE = calcSample(stype, data, range)
% function calculates the sample of the data depending on the
% stype-selection.

switch stype
    case 'mean'
        SAMPLE = mean(mean(data, 2));
    case 'min'
        SAMPLE = min(min(data, [], 2));
    case 'max'
        SAMPLE = max(max(data, [], 2));
    case 'min_lat'
        SAMPLE1 = min(min(data, [], 2));

        % minimun of each column
        x_data = min(data, [], 1);
        
        % find value FIRST time
        index = find(x_data == SAMPLE1, 1,'first');
        SAMPLE = range(index);
        
    case 'max_lat'
        SAMPLE1 = max(max(data, [], 2));

        % minimun of each column
        x_data = max(data, [], 1);

        % find value FIRST time
        index = find(x_data == SAMPLE1, 1,'first');
        SAMPLE = range(index);
end


function axesClick(~, ~, h)
% catch mouseclick from an axis and -> zoom

% what kind of click was performed?
clicktype = get(gcf, 'SelectionType');

if strcmp(clicktype, 'normal')
    
    %get subject    
    subjstr = get(h.subjpopup, 'string');
    subj = get(h.subjpopup, 'Value');

    identifier_text = ['PARTICIPANT: ', subjstr{subj}];
    
    hfig = zoomAxes(gca, identifier_text);

end
