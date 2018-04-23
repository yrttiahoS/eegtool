function [vector, option, ismarked, ismarked2] = ...
         inputAdValueGui(advicestring1, advicestring2, advicestring3, ...
                         advicestring4, options, defaultchoise, ...
                         defaultstring, ismarked, ismarked2)
    % a GUI for typing the artefact detection parameters as a vector
    %
    % Parameters: 
    %  advice_string = string to give user hint what to input
    %  defaultstring = default string in the edit field
    %  options       = cell with strings inside to provide options for gui
    %  defaultchoise = which option to default to
    %  ismarked      = 0/1 should the checkbox 1 be checked by default
    %  ismarked      = 0/1 should the checkbox 2 be checked by default
    %
    % Returns:
    %  vector        = vector from the gui edit-field
    %  option        = selected option from the list ([] means user did not
    %                  quit by pressing 'Ok'.)
    %  ismarked      = 0/1 whether the user checked the box 1
    %  ismarked2     = 0/1 whether the user checked the box 2

    % generate figure and switch off unneeded figure controls
    h.fig = figure('position', [400 400 200 200], 'menubar', 'none', ...
                   'numbertitle', 'off', 'color', 'white'); 

    % move gui to the center of the screen
    movegui(gcf, 'center');

    % define ui elements

    h.vectortext1 = uicontrol('Style', 'text', 'string', advicestring1, ...
                              'position', [5 160 90 30], ...
                              'backgroundcolor', [1 1 1]);
    h.vectortext2 = uicontrol('Style', 'text', 'string', advicestring2, ...
                              'position', [105 160 90 30], ...
                              'backgroundcolor', [1 1 1]);

    h.optionpopup = uicontrol('Style', 'popupmenu', 'string', options, ...
                              'position', [10 120 110 30]);
    h.vectoredit = uicontrol('Style', 'edit', 'string', defaultstring, ...
                             'position', [130 128 60 20]);

    h.vectortext3 = uicontrol('Style', 'text', 'string', advicestring3, ...
                              'position', ...
                              [10 80 150 30], 'backgroundcolor', ...
                              [1 1 1], 'horizontalalignment', 'left');
    h.markerbox = uicontrol('Style', 'checkbox', 'value', ...
                            str2num(ismarked), 'position', ...
                            [165 85 15 30], 'backgroundcolor', [1 1 1]);

    h.vectortext4 = uicontrol('Style', 'text', 'string', advicestring4, ...
                              'position', [10 40 150 30], ...
                              'backgroundcolor', [1 1 1], ...
                              'horizontalalignment', 'left');
    h.markerbox2 = uicontrol('Style', 'checkbox', 'value', ...
                             str2num(ismarked2), 'position', ...
                             [165 45 15 30], 'backgroundcolor', [1 1 1]);


    h.readyb = uicontrol('Style', 'pushbutton', 'string', 'Ok', ...
                       'horizontalalignment', 'center', ...
                       'position', [5 5 190 30]);

    set(h.readyb, 'callback', {@readyb_callback});
    set(h.fig, 'closerequestfcn', {@close_fig});
    setappdata(gcf, 'ispressed', 0);

    % set default artefact detection type from the parameter
    set(h.optionpopup, 'value', find(strcmp(options, defaultchoise)));

    uiwait;

    vector = str2num(get(h.vectoredit, 'string'));
    optval = get(h.optionpopup, 'value');
    option = options{optval};
    ismarked = get(h.markerbox, 'Value');
    ismarked2 = get(h.markerbox2, 'Value');

    if ~getappdata(gcf, 'ispressed')
        erroridentifier = -1;
        option = erroridentifier;
        ismarked = erroridentifier;
        vector = erroridentifier;
    end

    close;

function close_fig(hObject, ~)

    if isequal(get(hObject, 'waitstatus'), 'waiting')
        % The GUI is still in UIWAIT, us UIRESUME
        uiresume(hObject);
    else
        % The GUI is no longer waiting, just close it
        delete(hObject);
    end

function readyb_callback(~, ~)

    setappdata(gcf, 'ispressed', 1);
    uiresume;