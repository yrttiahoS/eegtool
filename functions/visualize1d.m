function  visualize1d(fnames, condition, datamatrix, xdata, eventcount, ...
                      chanlocs, atype, limits, axisid)
    % This function displays 1-d ERP-type data on a head GUI. Various outputs
    % can be taken out of the function such as mean, max or min. 
    %
    % Parameters:
    %  fnames     = cell table with i cells. i:th cell identifiers of i:th row
    %               in datamatrix and xdata
    %  condition  = cell table with i cells. i:th cell is the condition for
    %               i:th file. This allows grouping by condition. 
    %  datamatrix = cell table with i cells. Cell i is the datamatrix [nbchan,
    %               nbpoints] for fnames{i}
    %  xdata      = x-axis pointvector for the i:th datamatrix
    %  eventcount = vector of event counts for each file
    %  chanlocs   = channel locations struct (eeglab-format)
    %  atype      = string to mark the type of the analysis (only to be
    %               displayed on the GUI)
    %  limits     = [ymin ymax] default limits to the GUI's ymin, ymax values
    %  axisid     = {xid, yid} cell table with 2 strings. Xid labels x-axis and
    %               Yid labels y-axis.

    % almost no error checking made in this GUI, so prepare your input well!

    % draw the head-background gui and store figure handle
    h.visualize1d = headGui(['Eegtool - ' atype ' visualization']);

    % define gui elements

    %%%%%%%%%%%%%%%%%%%%% upper area %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    h.subjtext = uicontrol('Style', 'text', 'string', 'File', ...
                           'units', 'normalized', 'position', ...
                           [0.01 0.955 0.03 0.03], 'horizontalalignment', ...
                           'left');

    h.subjpopup = uicontrol('Style', 'popupmenu', 'string', 'All', ...
                            'horizontalalignment', 'center', 'units', ...
                            'normalized', 'position', [0.05 0.96 0.15 0.03]);

    h.group_fname_button = uicontrol('Style', 'pushbutton', 'string', ...
                                     'Group by filename', 'units', ...
                                     'normalized', 'position', ...
                                     [0.01 0.91 0.15 0.03], 'tooltipstring', ...
                                     'Form subject group-averages for visualization (not saved).');

    h.group_condition_button = uicontrol('Style', 'pushbutton', 'string', ...
                                         'Group by condition', 'units', ...
                                         'normalized', 'position', ...
                                         [0.01 0.87 0.15 0.03], 'tooltipstring',
                                         'Form subject group-averages for visualization (not saved).');

    h.difference_button = uicontrol('Style', 'pushbutton', 'string', ...
                                    'Difference', 'units', 'normalized', ...
                                    'position', [0.01 0.83 0.15 0.03], ...
                                    'tooltipstring', ...
                                    'Form subject group-averages for visualization (not saved).');


    %%%%%%%%%%%%%%%%%%%%% lower area %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    h.ymaxtext = uicontrol('Style', 'text', 'string', 'Ymax', ...
                           'horizontalalignment', 'left', 'units', ...
                           'normalized', 'position', [0.01 0.09 0.04 0.03]);

    h.ymaxedit = uicontrol('Style', 'edit', 'string', limits(2), ...
                       'horizontalalignment', 'center', 'units', ...
                       'normalized', 'position', [0.06 0.09 0.04 0.03]);

    h.ymintext = uicontrol('Style', 'text', 'string', 'Ymin', ...
                       'horizontalalignment', 'left', 'units', ...
                       'normalized', 'position', [0.01 0.05 0.04 0.03]);
                   
    h.yminedit = uicontrol('Style', 'edit', 'string', limits(1), ...
                       'horizontalalignment', 'center', 'units', ...
                       'normalized', 'position', [0.06 0.05 0.04 0.03]);

    h.samplet = uicontrol('Style', 'text', 'string', 'Sample type', ...
                          'HorizontalAlignment', 'left', 'units', ...
                          'normalized', 'position', [0.01 0.01 0.08 0.03]);

    sampletypes = {'mean', 'max', 'min', 'max_lat', 'min_lat'};

    h.samplep = uicontrol('Style', 'popupmenu', 'string', sampletypes, ...
                         'units', 'normalized', 'position', ...
                         [0.09 0.01 0.09 0.03]);

    h.ranget = uicontrol('Style', 'text', 'string', 'Range(x-axis)', ...
                         'HorizontalAlignment', 'left', 'units', ...
                         'normalized', 'position', [0.19 0.01 0.08 0.03]);
                     
    h.xmine = uicontrol('Style', 'edit', 'string', 'min', 'units', ...
                        'normalized', 'position', [0.28 0.01 0.05 0.03]);

    h.xmaxe = uicontrol('Style', 'edit', 'string', 'max', 'units', ...
                        'normalized', 'position', [0.34 0.01 0.05 0.03]);

    h.ranget2 = uicontrol('Style', 'text', 'string', 'Range2(x-axis)', ...
                          'visible', 'off', 'HorizontalAlignment', 'left', ...
                          'units', 'normalized', 'position', ...
                          [0.19 0.05 0.08 0.03]);
                   
    h.xmine2 = uicontrol('Style', 'edit', 'string', 'min', 'visible', 'off', ...
                         'units', 'normalized', 'position', ...
                         [0.28 0.05 0.05 0.03]);

    h.xmaxe2 = uicontrol('Style', 'edit', 'string', 'max', 'visible', 'off',...
                         'units', 'normalized', 'position', ...
                         [0.34 0.05 0.05 0.03]);
                   
    h.range2_helpt = uicontrol('Style', 'text', 'string', ...
                               'SAMPLE = SAMPLE(range)-SAMPLE(range2)', ...
                               'visible', 'off', 'HorizontalAlignment', ...
                               'left', 'units', 'normalized', 'position', ...
                               [0.40 0.05 0.25 0.03]);

    h.topoplot_button = uicontrol('Style', 'pushbutton', 'string', ...
                                  'Topoplot', 'units', 'normalized', ...
                                  'position', [0.70 0.01 0.13 0.03]);

    h.extract_raw_button = uicontrol('Style', 'pushbutton', 'string', ...
                                     'Extract raw', 'units', 'normalized', ...
                                     'position', [0.85 0.05 0.13 0.03]);

    h.extract_button = uicontrol('Style', 'pushbutton', 'string', 'Extract', ...
                                 'units', 'normalized', 'position', ...
                                 [0.85 0.01 0.13 0.03]);

    h.doublearea_tag = uicontrol('Style', 'radiobutton', 'string', ...
                                 'Difference between ranges', 'units', ...
                                 'normalized', 'position', ...
                                 [0.40 0.01 0.17 0.03]);

    % set some background elements white
    hChildren = get(gcf, 'Children');
    set(hChildren(strcmp(get(hChildren, 'style'), 'text')), ...
        'backgroundcolor', [1 1 1]);
    set(hChildren(strcmp(get(hChildren, 'style'), 'checkbox')),
        'backgroundcolor', [1 1 1]);
    set(hChildren(strcmp(get(hChildren, 'style'), 'radiobutton')),
        'backgroundcolor', [1 1 1]);


    % add combined-string to the end of the list
    fnames{end+1} = 'Combined view';

    % generate the list of subjects for the event box
    set(h.subjpopup, 'String', fnames);

    axdim = [0.05 0.04];

    % draw axes to their righteous places
    %%%%%%%%%%%wrong parameters -> known
    h.haxes = drawTopoAxis(h.visualize1d, chanlocs, axdim, axisid{1}, axisid{2});

    set(h.group_fname_button, 'callback', {@group_fnameCallback, h, fnames, ...
                                           datamatrix, xdata, chanlocs});
    set(h.group_condition_button, 'callback', {@group_conditionCallback, h, ...
                                               condition, datamatrix, ...
                                               xdata, chanlocs});
    set(h.difference_button, 'callback', {@differenceCallback, h, ...
                                          datamatrix, xdata, chanlocs});
    set(h.subjpopup, 'callback', {@editCallback, h, datamatrix, xdata, ...
                                  chanlocs});
    set(h.ymaxedit, 'callback', {@editCallback, h, datamatrix, xdata, ...
                                 chanlocs});
    set(h.yminedit, 'callback', {@editCallback, h, datamatrix, xdata, ...
                                 chanlocs});
    set(h.extract_button, 'callback', {@extractCallback, h, datamatrix, ...
                                       xdata, fnames, eventcount, chanlocs, ...
                                       atype});
    set(h.extract_raw_button, 'callback', {@extract_rawCallback, h, ...
                                           datamatrix, xdata, fnames, ...
                                           eventcount, chanlocs, atype});
    set(h.topoplot_button, 'callback', {@topoplotCallback, h, datamatrix, ...
                                        xdata, fnames, eventcount, chanlocs});
    set(h.doublearea_tag, 'callback', {@doubleareaCallback, h});

    % plot the initial state of the gui
    % clear axes and put them on hold for the multiple plots
    for i=1:length(h.haxes)
        set(gcf, 'currentaxes', h.haxes(i));
        hold all;
    end

    ymax = str2num(get(h.ymaxedit, 'string')); %#ok<*ST2NM>
    ymin = str2num(get(h.yminedit, 'string'));

    %PLOT
    drawData(h, datamatrix{1}, xdata{1}, ymin, ymax, chanlocs, 8);

    % return all the axes to non-hold state   
     for i=1:length(h.haxes)
         set(gcf, 'currentaxes', h.haxes(i));
         hold off;
     end

    % process xmin and xmax values
    e.xmin = min(xdata{1});
    e.xmax = max(xdata{1});

    set([h.xmine h.xmine2], 'string', num2str(e.xmin));
    set([h.xmaxe h.xmaxe2], 'string', num2str(e.xmax));

    h.mine.UserData = e;
    h.maxe.UserData = e;

    % format combined appdata-struct
    setappdata(gcf, 'combined', []);

function doubleareaCallback(hObject,~, h)

    if get(hObject, 'value')
       % button was toggled on
       set(h.xmaxe2, 'visible', 'on');
       set(h.xmine2, 'visible', 'on');
       set(h.ranget2, 'visible', 'on');
       set(h.range2_helpt, 'visible', 'on');

    else
       set(h.ranget2, 'visible', 'off');
       set(h.xmaxe2, 'visible', 'off');
       set(h.xmine2, 'visible', 'off');
       set(h.range2_helpt, 'visible', 'off');
    end


function group_conditionCallback(~,~, h, condition, datamatrix, xdata, chanlocs)

    uniqcondition = unique(condition);

    selected_conditions = listdlg('PromptString','Select a file:',...
                                    'SelectionMode','multiple',...
                                    'ListString', uniqcondition);

    combined = getappdata(gcf, 'combined');
    len = length(combined);
    setname = inputdlg('Give name to a set', 'Prompt', 1, {['Set ' num2str(len+1)]});

    if isempty(selected_conditions) || isempty(setname{1})
        return;
    end

    % find all the files or participants having this condition
    catmatrix=[];
    for i=selected_conditions
        rows_with_this_condition = find(strcmp(condition, uniqcondition{i}));
        catmatrix = cat(3, catmatrix, datamatrix{rows_with_this_condition});
    end

    % calculate mean
    meanmatrix = mean(catmatrix, 3);

    % store to appdata
    combined(len+1).id = setname{1};
    combined(len+1).data = meanmatrix;
    setappdata(gcf, 'combined', combined);

    updateView(h, datamatrix, xdata, chanlocs);


function group_fnameCallback(~,~, h, fnames, datamatrix, xdata, chanlocs)

    selected_participants = listdlg('PromptString','Select files:',...
                                    'SelectionMode','multiple',...
                                    'ListString', fnames(1:end-1));

    combined = getappdata(gcf, 'combined');
    len = length(combined);
    setname = inputdlg('Give name to a set', 'Prompt', 1, {['Set ' num2str(len+1)]});

    if isempty(selected_participants) || isempty(setname{1})
        return;
    end

    % calculate ERP for this set of participants
    catmatrix=[];
    for i=selected_participants
        catmatrix = cat(3, catmatrix, datamatrix{i});
    end

    % calculate mean
    meanmatrix = mean(catmatrix, 3);

    % store to appdata
    combined(len+1).id = setname{1};
    combined(len+1).data = meanmatrix;
    setappdata(gcf, 'combined', combined);

    updateView(h, datamatrix, xdata, chanlocs);


function differenceCallback(~,~, h, datamatrix, xdata, chanlocs)

    combined = getappdata(gcf, 'combined');
    len = length(combined);

    if isempty(combined)
       return; 
    end

    for i=1:len
        id_cell{i} = combined(i).id;
    end

    selected_conditions_1 = listdlg('PromptString','Select a minuend condition:',...
                                    'SelectionMode','single',...
                                    'ListString', id_cell);

    selected_conditions_2 = listdlg('PromptString','Select a subtrahend condition:',...
                                    'SelectionMode','single',...
                                    'ListString', id_cell);
                                
    setname = inputdlg('Give name to a set', 'Prompt', 1, {['Set ' num2str(len+1)]});

    if isempty(selected_conditions_1) || isempty(selected_conditions_2) || isempty(setname{1})
        return;
    end             


    difdata = combined(selected_conditions_1).data - combined(selected_conditions_2).data;

    combined(len+1).id = setname{1};
    combined(len+1).data = difdata;
    setappdata(gcf, 'combined', combined);

    updateView(h, datamatrix, xdata, chanlocs);


function editCallback(~, ~, h, datamatrix, xdata, chanlocs)
    % function to update the view after changes


    updateView(h, datamatrix, xdata, chanlocs);


function updateView(h, datamatrix, xdata, chanlocs)

    % get subject
    subj = get(h.subjpopup, 'Value');

    % clear axes and put them on hold for the multiple plots

    % y-min and y-max parameters
    ymax = str2num(get(h.ymaxedit, 'string'));
    ymin = str2num(get(h.yminedit, 'string'));

    % delete the old legends
    if isappdata(gcf, 'hlegend')
        delete(getappdata(gcf, 'hlegend'));
        rmappdata(gcf, 'hlegend');
    end

    for i=1:length(h.haxes)
        set(gcf, 'currentaxes', h.haxes(i));
        cla;
        hold all;
    end

    % if combined-view chosen
    if subj > length(datamatrix)
        combined = getappdata(gcf, 'combined');
        
        for i=1:length(combined)
            hcurve = drawData(h, combined(i).data, xdata{1}, ymin, ymax, ...
                              chanlocs, i);
            
            % create 'legends' to specify the colors
            hlegend(i) = uicontrol('Style', 'text', 'string', ...
                                   combined(i).id, 'units', 'normalized', ...
                                   'position', ...
                                   [0.85 0.98-i*0.035 0.14 0.03], ...
                                   'ForegroundColor', get(hcurve, 'color'), ...
                                   'backgroundcolor', 'white', 'fontunits', ...
                                   'normalized', 'fontsize', 0.8, ...
                                   'horizontalalignment', 'right', ...
                                   'ButtonDownFcn', {@legendCallback, ...
                                                     i, h, datamatrix, ...
                                                     xdata, chanlocs}, ...
                                   'tooltipstring', ...
                                   'Right-click to remove grouping.');
        end
        
        if ~isempty(combined)
            % set legend handles to appdata
            setappdata(gcf, 'hlegend', hlegend);
        end
        
    else
        drawData(h, datamatrix{subj}, xdata{subj}, ymin, ymax, chanlocs, 8);
    end

    % return all the axes to non-hold state
    for i=1:length(h.haxes)
        set(gcf, 'currentaxes', h.haxes(i));
        hold off;
    end

function extract_rawCallback(~, ~, h, datamatrix, xdata, fnames, eventcount, ...
                             chanlocs, atype)

    outputtype = questdlg('Use an xls-file or separate csv-files for output?', ...
                          'Output-file type', 'Xls', 'Csv', 'Xls');


    switch outputtype
        
        case 'Xls'

            %%%%%%%%%%%%%%%%%%%%%%%%%% filecontrol-code %%%%%%%%%%%%%%%%%%%%%%%%%%%
            [filename, dpath, ~] = uiputfile('*.xls');

            % filename was gotten
            if (filename == 0)
            return;
            end

            combined = getappdata(gcf, 'combined');

            hwait = waitbar(0, 'Writing xls-file...');
            for i=1:length(datamatrix)
                xlswrite([dpath filename],datamatrix{i}, fnames{i});
                waitbar(i/(length(datamatrix)+length(combined)), hwait);
            end

            for j=1:length(combined)
                xlswrite([dpath filename], combined(j).data, combined(j).id);
                waitbar(i+j/length(datamatrix), hwait);
            end

            close(hwait);

        case 'Csv'
            
            %%%%%%%%%%%%%%%%%%%%%%%%%% filecontrol-code %%%%%%%%%%%%%%%%%%%%%%%%%%%
            % get folder
            targetpath = uigetdir;

            
            % folder was gotten
            if (targetpath == 0)
                return;
            end

            combined = getappdata(gcf, 'combined');

            hwait = waitbar(0, 'Writing csv-files...');
            for i=1:length(datamatrix)
                [a b c] = fileparts(fnames{i});
                csvwrite([targetpath filesep b '.csv'], datamatrix{i});
                waitbar(i/(length(datamatrix)+length(combined)), hwait);
            end

            for j=1:length(combined)
                xlswrite([targetpath filesep combined(j).id '.csv'], ...
                         combined(j).data);
                waitbar(i+j/length(datamatrix), hwait);
            end

            close(hwait);
            
    end

function extractCallback(~, ~, h, datamatrix, xdata, fnames, eventcount, ...
                         chanlocs, atype)
    % callback for the button save results

    % find first indice after 'xmin' and first before 'xmax' edit
    ind_xmin = find(xdata{1}>=str2num(get(h.xmine, 'String')), 1, 'first');
    ind_xmax = find(xdata{1}<=str2num(get(h.xmaxe, 'String')), 1, 'last');

    % define sample range 
    range = xdata{1}(ind_xmin:ind_xmax);

    xmin = range(1);
    xmax = range(end);

    %%%%%%%%%%%%%%%%%%%%%%%%%% filecontrol-code %%%%%%%%%%%%%%%%%%%%%%%%%%%
    [filename, dpath, ~] = uiputfile('*.csv');

    % filename was gotten
    if (filename == 0)
        return;
    end

    % open the file for writing
    fid = fopen(strcat(dpath, filename), 'a+');

    if fid == -1
        errordlg('Could not open the file for writing.');
        return;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%% /filecontrol-code %%%%%%%%%%%%%%%%%%%%%%%%%%

    % save header row to the file
    saveHeaderRow(fid, chanlocs, 'xmin', 'xmax', '', '');

    % get sample type
    contents = cellstr(get(h.samplep,'String'));
    stype = contents{get(h.samplep, 'Value')};

    % if all subjects selected (from now on only option)
    subjvector = 1:length(datamatrix);

    % loop through all subjects and their stimuluses and write to ->file
    for k = subjvector

        % take the desired sample out of the RES
       % SAMPLE = calcMetric(stype, datamatrix{k}(:, ind_xmin:ind_xmax), range); 
        SAMPLE = processMetricCalculation(h, xdata, datamatrix{k});

        writeSampleRow(fid, SAMPLE, fnames{k}, stype, atype, ...
                       num2str(eventcount{k}), num2str(xmin), num2str(xmax), ...
                       '', '');
    end
    fprintf(fid, '\n');

    % close the file
    fclose(fid);


function topoplotCallback(~, ~, h, datamatrix, xdata, fnames, eventcount, ...
                          chanlocs)
    % saves result for the selected subj/stim/sampletype-combination

    subj = get(h.subjpopup, 'Value');

    % if combined subjects selected
    if subj > length(datamatrix)
        combined = getappdata(gcf, 'combined');
        
        % loop through all the combined sets
        for k =1:length(combined)
            
            SAMPLE = processMetricCalculation(h, xdata, combined(k).data);
            
            % create plot figure
            hfig = figure;
            topoplot(SAMPLE, chanlocs, 'electrodes', 'labels'); % 'pts'

            % set figure name to
            set(hfig, 'name', ['Combined set: ' combined(k).id], 'numbertitle','off');
            
            % and colorlimits
            set(gca, 'Clim', [str2num(get(h.yminedit, 'string')) str2num(get(h.ymaxedit, 'string'))]);
        end
    else

        subjvector = subj;

        % loop through all subjects
        for k = subjvector

            % take the desired sample
            SAMPLE = processMetricCalculation(h, xdata, datamatrix{k});

            % create plot figure
            hfig = figure;
            topoplot(SAMPLE, chanlocs, 'electrodes', 'labels'); % 'pts'

            % set figure name to
            set(hfig, 'name', ['SUBJECT: ' fnames{k}], 'numbertitle','off');
            % and colorlimits
            set(gca, 'Clim', [str2num(get(h.yminedit, 'string')) str2num(get(h.ymaxedit, 'string'))]);
        end
    end


function hcurve = drawData(h, data, xdata, ymin, ymax, chanlocs, colornum)
    % fills all the axes objects in the head 

    % parameters are: 
    % h     = handle structure
    % data  = epoched EEG
    % xdata = x-datavector (similar length than data assumed)
     
    % decide color of this curve (tried to make curvcolors better with this
    % function :)
    color1 = mod([0.85 0.3 0.27] + [3.57 6.145 1.72].^(colornum-1), 1);

    % form x axis
    x_axis = xdata;

    xmin = x_axis(1);
    xmax = x_axis(end);

    % set axis limits
    axlimits = [xmin xmax ymin ymax];

    row = size(h.haxes,2);

    % for all the haxes
    for i=1:row
        set(gcf, 'currentaxes', h.haxes(i));

        % curve to draw to this axes: one row(channel) from the EEG-matrix
        y_axis = data(i, :);

        hcurve = plot(h.haxes(i), x_axis, y_axis, 'color', color1);

        % draw line in the event-location and x-axis
        line( [0 0], [ymin ymax], 'color', 'black', 'linestyle', ':');
        line( [xmin xmax], [0 0], 'color', 'black');

        % put channel name text to the upper right corner
        text(xmax, ymax-0.1*(ymax-ymin), chanlocs(i).labels, ...
                     'fontunits', 'normalized', 'fontsize', 0.25, 'horizontalalignment', 'right');

        % set the limits
        axis(h.haxes(i), axlimits);
        
        % set axes and it's childrens buttondownfcn to axesclick
        set(h.haxes(i), 'ButtonDownFcn', {@axesClick, h});
        set(get(h.haxes(i), 'children'), 'ButtonDownFcn', {@axesClick, h});
    end


function SAMPLE = calcMetric(stype, data, range)
    % function calculates the sample of the data depending on the
    % stype-selection.

    switch stype
        case 'mean'
            SAMPLE = mean(data, 2);
        case 'min'
            SAMPLE = min(data, [], 2);
        case 'max'
            SAMPLE = max(data, [], 2);
        case 'min_lat'
            SAMPLE = zeros(size(data, 1),1);
            for i=1:length(SAMPLE)
                SAMPLE(i) = range(find(data(i,:) == min(data(i,:)), 1, 'first'));
                % TODO TARKASTA VIELÄ TÄMÄ!!!
            end
        case 'max_lat'
            SAMPLE = zeros(size(data, 1),1);
            for i=1:length(SAMPLE)
                SAMPLE(i) = range(find(data(i,:) == max(data(i,:)), 1, 'first'));
                % TODO TARKASTA VIELÄ TÄMÄ!!!
            end
    end


function legendCallback(~, ~, legendnum, h, datamatrix, xdata, chanlocs)
    % callback function for a legend identifier text

    % what kind of click was performed?
    clicktype = get(gcf, 'SelectionType');
    if ~strcmp(clicktype, 'alt')
       return;
    end

    % remove the legend from "combined"
    combined = getappdata(gcf, 'combined');
    combined(legendnum) = [];
    setappdata(gcf, 'combined', combined);

    % delete current legend (handle and from appdata)
    if isappdata(gcf, 'hlegend')
        hlegend = getappdata(gcf, 'hlegend');
        delete(hlegend(legendnum));
        hlegend(legendnum) = [];
        setappdata(gcf, 'hlegend', hlegend);
    end

    % update view
    updateView(h, datamatrix, xdata, chanlocs);

    function SAMPLE = processMetricCalculation(h, xdata, ydata)

    % get parameters from gui

    % find first indice after 'xmin' and first before 'xmax' edit -> sample range 
    ind_xmin = find(xdata{1}>=str2num(get(h.xmine, 'String')), 1, 'first');
    ind_xmax = find(xdata{1}<=str2num(get(h.xmaxe, 'String')), 1, 'last');
    range = xdata{1}(ind_xmin:ind_xmax);
        
    % second range
    % find first indice after 'xmin' and first before 'xmax' edit -> sample range
    ind_xmin2 = find(xdata{1}>=str2num(get(h.xmine2, 'String')), 1, 'first');
    ind_xmax2 = find(xdata{1}<=str2num(get(h.xmaxe2, 'String')), 1, 'last');
    range2 = xdata{1}(ind_xmin2:ind_xmax2);
        
    % get sample type
    contents = cellstr(get(h.samplep,'String'));
    mtype = contents{get(h.samplep, 'Value')};

    if get(h.doublearea_tag, 'value')
        % calculate the desired sample for one two ranges (default)
        SAMPLE1 = calcMetric(mtype, ydata(:, ind_xmin:ind_xmax), range); 
        SAMPLE2 = calcMetric(mtype, ydata(:, ind_xmin2:ind_xmax2), range2);
        SAMPLE = SAMPLE1 - SAMPLE2;
    else
        % calculate the desired sample for one range (default)
        SAMPLE = calcMetric(mtype, ydata(:, ind_xmin:ind_xmax), range); 
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