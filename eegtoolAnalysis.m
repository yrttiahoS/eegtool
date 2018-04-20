function eegtoolAnalysis
    % ------------------------------------------------------------------------------
    % Help for eegtoolAnalysis.m 
    % ------------------------------------------------------------------------------
    % 
    %   A function that creates a GUI for the user to run various EEG analyses. 
    %   On the upper part of the GUI, a working directory path is shown. It must
    %   be selected with the button "Choose directory". The program displays the 
    %   .set files in the working directory. Files chosen for the analysis must 
    %   be highlighted by clicking. Analysis type can be selected from the 
    %   "Choose analysis"-menu (refer to help on each function for additional information).
    %   The ?Run analysis? button will perform and visualize the specified
    %   analysis for the selected datafiles.
    %   
    %   Extracting metrics: After computation, the visualization for the specified
    %   analysis is displayed. In the visualization, a button "Extract" is shown.
    %   By selecting the desired method and range for extraction, the ?Extract? 
    %   button makes an output file with the computations listed from each input 
    %   file.
    %    
    %   The input EEG files need to be of same form for the analysis to work. 
    %   Some analyses might impose additional requirements to files. For example,
    %   in some analyses the duration of pre- and post-stimulus time must match 
    %   in duration.
    %   
    %   eegtoolAnalysis implements some of the commonly used analyses for epoched 
    %   EEG files. New analysis functions can be added as user-made MATLAB
    %   functions. To do so, the functions must be located in the folder:
    %   '?/eegtool_root/functions/?.
    %   Analysis functions must also accept two
    %   parameters: dpath and filenames (cell vector). Analyses placed on the
    %   folder will automatically appear on the drop-down menu after restart of
    %   eegtoolAnalysis.
    %   
    %   WARNING! This software has been carefully tested, but there could still be 
    %   some bugs left. Use it at your own risk! The authors hold no 
    %   responsibility for any damages caused by using the software nor promise 
    %   any guarantee of suitability of the software for any particular purpose.

    rootdir = fileparts(mfilename('fullpath'));

    % construct the pathing required to run the program and find functions
    constructEegtoolPaths(rootdir);

    % generate figure and switch off unneeded figure controls
    h.fig = figure('units', 'normalized', 'position', [0.4 0.4 0.17 0.4], 'menubar', 'none', ...
                   'numbertitle', 'off', 'color', 'white');	

    set(h.fig, 'name', 'eegtoolAnalysis');

    % define ui controls

    h.dirbutton = uicontrol('Style', 'pushbutton', 'string', 'Choose directory', ...
                       'horizontalalignment', 'center', 'units', 'normalized', 'position', [0.05 0.91 0.9 0.07]);

    h.dirtext = uicontrol('Style', 'text', 'string', '-', 'units', 'normalized', ...
                       'horizontalalignment', 'center', 'position', [0.05 0.79 0.9 0.10]);

    h.filetext = uicontrol('Style', 'text', 'string', ...
                           'Choose files', ...
                           'units', 'normalized', 'horizontalalignment', 'center', 'position', [0.05 0.68 0.9 0.07]);

    h.filelistbox = uicontrol('Style', 'listbox', 'string', '', 'units', 'normalized', ...
                        'position', [0.05 0.2 0.9 0.46], 'horizontalalignment', ...
                        'center');

    h.chanalysispopup = uicontrol('Style', 'popupmenu', 'string', {''}, 'units', 'normalized', 'position', ...
                                  [0.05 0.13 0.9 0.05], 'horizontalalignment', 'center');

    h.analyzebutton = uicontrol('Style', 'pushbutton', 'string', 'Run analysis', 'units', 'normalized', ...
                       'horizontalalignment', 'center', 'position', [0.05 0.01 0.9 0.10]);

    % set some objects backgrounds to white
    hChildren = get(gcf, 'Children');
    set(hChildren(strcmp(get(hChildren, 'style'), 'text')), 'backgroundcolor', [1 1 1]);
    set(hChildren(strcmp(get(hChildren, 'style'), 'checkbox')), 'backgroundcolor', [1 1 1]);

    set(h.dirbutton, 'callback', {@dirbutton_callback, h});
    set(h.analyzebutton, 'callback', {@analyzebutton_callback,h});

    analyses = dir([rootdir filesep 'functions' filesep 'analyses' filesep '*.m']);

    % generate list of available analyses from the analyses-folder
    for i=1:length(analyses)
        [a b c] = fileparts(analyses(i).name);
        listanalyses{i} = b;
    end

    set(h.chanalysispopup, 'string', listanalyses);

function dirbutton_callback(~, ~, h)
    % Callback for dirbutton

    % get folder
    folder = uigetdir;

    % user picked no folder
    if folder == 0
       return;
    end

    set(h.dirtext, 'String', [folder filesep]);
    r = dir(folder);

    % filter proper files
    nfiles = length(r);
    filenames = cell(1);
    j=1;

    for i=1:nfiles
        if(r(i).isdir == 0)
            if strcmp(r(i).name(find(r(i).name=='.'):end), '.set')
                filenames{j} = r(i).name;
                j=j+1;
            end
        end
    end

    set(h.filelistbox, 'String', filenames);
    set(h.filelistbox, 'max', length(filenames), 'value', 1:length(filenames))

function analyzebutton_callback(~, ~, h)
    % Callback for analyzebutton

    % parse analyzable files
    filenames = get(h.filelistbox, 'string');
    chosen_filenames = get(h.filelistbox, 'value');
    dpath = get(h.dirtext, 'String');

    if isempty(filenames) || isempty(chosen_filenames)
        return;
    end

    chosen_files = filenames(chosen_filenames);

    % COMMON error detection here? 

    % analysis type
    analyses = get(h.chanalysispopup, 'string');
    analysis_num = get(h.chanalysispopup, 'Value');
    analysis_type = analyses{analysis_num};

    % if no files chosen -> return
    if strcmp(chosen_files{1}, '')
        return;
    end

    % construct the function call as a string
    runme = [analysis_type '(dpath,chosen_files);' ];

    % evaluate analysis function
    eval(runme);