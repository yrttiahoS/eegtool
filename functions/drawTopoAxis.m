function haxes = drawTopoAxis(fighandle, chanlocs , axdim, xid, yid)
% Draws the electrode axes to the corresponding places on current figure.
%
% Parameters: 
%  fighandle  =  handle of the figure where to plot
%  chanlocs   =  must contain channel location data such as variables r
%                and theta are to be found.
%  axdim      =  axis dimensions as [x y] ranging from 0-1 (1 the whole screen)
%  xid, yid   =  string how to label on x/y-axis
%
% Returns:
%  haxes      =  vector of axes handles

for i=1:length(chanlocs)
    % retrieve channel coordinates and do transform polar -> cartesian
    % (for location)
    r(i) = chanlocs(i).radius;

    theta(i) = (chanlocs(i).theta/360)*2*pi;

end

% normalize the r and make it to be a bit smaller than 0->1
r = r./(1.3*max(r));

% set fighandle figure to be current figure before generating axes
set(0, 'currentfigure', fighandle);

for i=1:length(r)

    %polar->cartesian transform
    x = r(i) * cos(theta(i));
    y = r(i) * sin(theta(i));
    %       0.55
    ydraw = 0.56-axdim(1)/2 + 0.56*x;%0.58*x;
    xdraw = 0.5-axdim(2)/2 + 0.58*y;
%0.6 was y
    haxes(i) = generate_axes([xdraw ydraw axdim(1) axdim(2)], xid, yid);
end
    
    
function haxes = generate_axes(position, xid, yid)
% generates axes and returns the handle to the function caller

%generate one axes object with handle haxes 
haxes = axes('units','normalized', 'position', position, 'FontSize', 7, 'GridLineStyle', 'none');


set(haxes, 'xticklabel', {}, 'yticklabel', {});
set(haxes, 'box', 'off', 'xcolor', 'white', 'ycolor', 'white');

% set labels to axis
labels.xid = xid;
labels.yid = yid;

set(haxes, 'userdata', labels);