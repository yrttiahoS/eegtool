function [events, winopts] = inputEventsGui(EEG, settings)
% GUI that collects the parameters to perform epoching. Blocks execution.
%
% Parameters:
%  EEG = Eeglab continuous EEG-struct
%  settings = two-component vector with values [winstart winend] from
%            previous tasks
% Returns:
%  events = cell-table of event identifiers chosen by user
%  winopts = 2-element cell-table of {winstart winend} strings

if nargin < 1 
    disp('Need at least 1  parameter: the EEG-signal structure.');
    return;
end

%EEG.nbchan
% retrieve events in a cell-list
 for i=1:length(EEG.event(:))
    stringtypes{i} = num2str(EEG.event(i).type);
 end
 
type = unique(stringtypes);
%type = unique({EEG.event.type});

% generate figure and switch off unneeded figure controls
h.fig = figure('position', [400 400 150 300], 'menubar', 'none', ...
               'numbertitle', 'off', 'color', 'white');	

% move gui to the center of the screen
movegui(gcf, 'center');

% define ui elements
h.descl = uicontrol('Style', 'listbox', 'string', type, 'Max', length(type), 'Min', 0, ...
                     'position', [10 130 130 160], 'horizontalalignment', ...
                     'center');

h.geneb = uicontrol('Style', 'pushbutton', 'string', 'Generate epochs', ...
                   'horizontalalignment', 'center', 'position', [10 10 130 30]);

h.emine = uicontrol('Style', 'edit', 'string', settings{1}, 'position', [90 90 50 30]);
                   
h.emaxe = uicontrol('Style', 'edit', 'string', settings{2}, 'position', [90 50 50 30]);

h.emint = uicontrol('Style', 'text', 'string', 'Epoch start', 'position', [10 90 70 30]);

h.emaxt = uicontrol('Style', 'text', 'string', 'Epoch end', 'position', [10 50 70 30]);

% set some objects backgrounds to white
hChildren = get(gcf, 'Children');
set(hChildren(strcmp(get(hChildren, 'style'), 'text')), 'backgroundcolor', [1 1 1]);
set(hChildren(strcmp(get(hChildren, 'style'), 'radiobutton')), 'backgroundcolor', [1 1 1]);

set(h.geneb, 'callback', {@geneb_callback, h});
set(h.fig, 'closerequestfcn', {@close_fig});
uiwait;

events = getappdata(gcf, 'events');

winopts{1} = get(h.emine, 'string'); %#ok<*ST2NM>
winopts{2} = get(h.emaxe, 'string');

close;

function geneb_callback(~ , ~, h)

selected = get(h.descl, 'Value');
desc = get(h.descl, 'string');

events = desc(selected);

setappdata(gcf, 'events', events);

uiresume;

function close_fig(hObject, ~)
%setappdata(gcf, 'events', {});

if isequal(get(hObject, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(hObject);
else
    % The GUI is no longer waiting, just close it
    delete(hObject);
end
