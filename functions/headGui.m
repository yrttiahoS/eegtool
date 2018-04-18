function [ hfig ] = headGui(name)
% Deploys a gui that has a simple head-model in the background
%
% Parameters:
%  name = name of the GUI (string)
%
% Returns:
%  hfig = handle of the figure

% generate figure and switch off unneeded figure controls
%hfig = figure('units', 'normalized', 'position', [100 100 1000 700]);
hfig = figure('units', 'normalized', 'position', [0.1 0.1 0.8 0.8]);

set(hfig, 'menubar', 'none', 'numbertitle', 'off', 'name', name);

% set backgroung image
hBg =  axes('units','normalized', 'position',[0 0 1 1]);

% Move the background axes to the bottom
uistack(hBg,'bottom'); 
I = imread('head2.jpg');

imagesc(I);
colormap gray;

set(hBg,'handlevisibility','off', 'visible','off');

% set here figure common properties such as object default background color etc.
%set(hfig, 'defaultproperty', ...);

% set here common elements in the Gui's

%h.icltext = uicontrol('Style', 'text', 'fontsize', 7, 'string', ...
%                     {'Infant Cognition Lab','University Of Tampere'}, 'horizontalalignment', ...
%                     'center', 'units', 'normalized', 'horizontalalignment', 'right', 'position', [0.85 0.967 0.145 0.03]); %0.003