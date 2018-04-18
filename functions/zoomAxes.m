function hfig = zoomAxes(objhandle, identifier)
% Zooms the objhandle ocject (axes) on a new figure.
% 
% Parameters:
%  objhandle  = handle of the object to zoom
%  identifier = title of the new figure (string)
%
% Returns:
%  hfig       = generated figure's handle

% get the colormap that the invoking figure used
clrmap = get(gcf, 'colormap');

% make new figure
hfig = figure;

set(hfig, 'name', identifier, 'numbertitle','off');


% move gui to the center
movegui(gcf, 'center');

set(hfig, 'colormap', clrmap);

% copy the object properties to fig and change it's position
C = copyobj(objhandle, hfig);

% position originally was: [0.05 0.05 0.90 0.90]

set(C, 'position', [0.08 0.08 0.88 0.88], 'xcolor', 'black', ...
    'ycolor', 'black', 'xticklabelmode', 'auto', 'yticklabelmode', 'auto');
graphicobjs = get(C, 'children');

% get the axis identifiers from userdata of the axes and set them to
% axis labels
labels = get(C, 'userdata');
if ~isempty(labels)
    xlabel(labels.xid);
    ylabel(labels.yid);
end

% set buttondownfunctions empty
set(C, 'buttondownfcn', '');
set(graphicobjs, 'buttondownfcn', '');