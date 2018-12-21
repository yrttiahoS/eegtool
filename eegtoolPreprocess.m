function varargout = eegtoolPreprocess(d_path, d_out_path, filename, savemode, continuous_procedure, stim_ids, ...
                                        epoch_limits, bad_epochs, epoched_procedure)
% ------------------------------------------------------------------------------
% Help for eegtoolPreprocess.m
% ---------------------------------------------------------------------------
%   A matlab GUI/function for epoching and preprocessing EEG data using either
%   a GUI or automated scripting mode.  The preprocessing tools included are: 
%   filtering, detrending, interpolation, baseline correction, re-referencing, 
%   impedance thresholding, and automated artifact detection using amplitude- 
%   or RMS-based measures. The eegtoolPreprocess function requires EEGLAB 
%   to be installed and added to the MATLAB path or added to the program?s 
%   root-folder. Every preprocessing/analysis step is traceable from the 
%   functions provided along eegtoolPreprocess or from EEGLAB functions.
%   Some EEGLAB functions have been slightly modified for the purpose of 
%   parsing the input data.                     
%   Operation-modes:
%   1)	Interactive GUI mode: Call function without parameters. Most of the
%       functionality of the scripting mode is available here also and vice versa.
%   2)	Scripting mode: Call function with parameters. If called with a file input, 
%       Output files are generated to the directory specified in the parameters. 
%       If called with a workspace variable input, output-struct is
%       returned as a variable.
%  
%   Parameters for the eegtoolPreprocess function in the order of appearance:
%    
%     eegtoolPreprocess(d_path, d_out_path, filename, save_mode, continuous_procedure, 
%                        stim_ids, epoch_limits, bad_epochs, epoched_procedure)
%    
%      d_path           = Directory path of the folder containing the file(s)
%                         to be processed.
%                         Include the file separator (e.g., '/') to the end 
%                         of the path string.
%      d_out_path       = Directory path for the output file(s).
%                         Include the file separator to the end.
%      filename         = Filename: a string or a 1x2 cell-string or a 
%                         work-space variable. 
%                         If the cap file (for channel locations)
%                         is available in EEGLAB by default, a single
%                         string indicating the EEG data or EEGLAB .set file
%                         can be used. If the cap file is not in the EEGLAB 
%                         folder, please provide the filename of the cap 
%                         file as the second string in the cell.
%                         Example 1: 'subj1.raw'
%                         Example 2: {'subj1.raw', '66chnlsEKG.loc'}
%                         Example 3: EEGSTRUCT
%      savemode         = Savemode specifies the desired output files,
%                         1 for .set-files for each condition specified
%                         2 for .mat-file containing epoched and continous
%                         EEG (depends on procedures chosen)
%                         3 for both types
%                         4 for save nothing
%                         variable EEGDATA is returned by the function
%      continuous_procedure 
%                       = specifies the workflow of tasks for the CONTINUOS
%                         EEG such as filtering, epoch addition e.g. See
%                         later. Example: {'filter', [0 40], 'filter', [5 0]}
%                         Only basic FIR low- and highpass filters are available 
%                         at the moment.
%      stim_ids         = Stimulus identifiers (epoching will be based on 
%                         these identifiers).
%                         Example: {'fear', 'cont'}.
%      epoch_limits     = A 1x2 vector with fields [ epoch_start epoch_end]
%                         in milliseconds.
%                         Example: [-500 1000].
%      bad_epochs       = A cell-matrix identifying the epochs of each 
%                         stimulus type to be rejected (acquired using e.g.,
%                         GUI based video analysis). 
%                         Example: {[1 11], [], [1:5]}.
%                         This parameter is mandatory even if empty. 
%      epoched_procedure
%                       = Procedure which defines the order of processing 
%                         steps performed to each epoched EEG dataset. 
%                         Consists of pairs of (stepIdentifier, stepParameters).
%                         The steps are performed in the same order as 
%                         parameters are listed in the preProcedure variable.
%                         For example, in the following example, baseline 
%                         correction precedes RMS-based artefact detection 
%                         and epoch rejection. 
%                         Example: {'blc', [-500 0], 'ad', {'RMS', 35, 0}, ...
%                                   'rejepochs', 25}.
%   
%    Step identifiers and required parameters for continuous_procedure:
%      'filter'         = Filter mode: apply dsp filters to data. A few of
%                         the most common filters are applicable here.
%                         Parameters: filter-vectors as filterings needed.
%                         parameter: 1x2 vector with [f_low f_max].
%                         example: [0 40] for a 40-Hz FIR low-pass filter.
%      'addevent'       = Add additional event data to the EEG data.
%                         Parameters: Filename with new events in a
%                         two-columns file 'type', 'latency' and with
%                         comma as a separator.
%
%    Step identifiers and required parameters for epoched_procedure:
%      'blc'            = Baseline correction. 
%                         Parameters: [blineStart blineEnd] values must be in
%                         milliseconds and within the epoch time-window.
%      'ad'             = Artefact Detection.
%                         Parameters: {adType, adTresh, overwrite}.
%                         adType = Artefact detection type. Options: 'RMS',
%                         'Max difference', or 'Treshold'.
%                         adTresh = Treshold for the artefact detection, 
%                         value depends on the type of detection used. 
%                         overwrite = 1/0, overwrites the previous event 
%                         validity markings. Use overwrite=0 if you want to 
%                         keep the rejections listed in the (previous)
%                         badEpochs parameter.
%                         Example: {'RMS', 35, 0}.
%   
%      'rejepochs'        = Epoch rejection according to a threshold number of
%                           bad channels/epoch.
%                           Parameters: Threshold (number). Please, provide 
%                           a number corresponding e.g., to 10 % of channels.
%      'detrend'          = Detrend each ERP.
%                           Parameters: nothing, just type 'nullprm' 
%      'interpolate'      = Interpolate bad ERPs detected by artefact detection.
%                           Parameters: 'nullprm'.
%      'rereference'      = Re-reference data. Parameters = {ref, excludechan}.
%                           ref = reference channels (leave [] if average).
%                           excludechan = channels to be excluded from the
%                           reference. Example: {[], [126 127 128]}.
%      'markchannelbad'   = Marks selected channels bad throughout all epochs.
%                           Parameters: channels in vector, Example: [1:4 113]
%                           (marks bad channels: 1,2,3,4, and 113).
%      'impedancetresh'   = Loads the impedance file (same filename with 
%                           appendix: ".IMP", so for ex. "testfile1.raw.IMP")
%                           and marks bad those channels whose impedance 
%                           exceeds the threshold provided. Impedance files 
%                           need to be present in the same folder as the EEG 
%                           files or an error occurs. 
%                           Parameters: Threshold (number), e.g., 50.
%      'savetrends'       = Calculates the trend-averages for each erp by
%                           condition over all epochs and saves them to a csvf.
%                           Parameters: Filename to which save the file,
%                           example: 'trends.csv'.
%      'rect'             = Takes absolute value of each signal.
%                           Parameters: 'nullprm'.
%      'process_with_fcn' = Advanced feature, where each signal for each
%                           channel and epoch is processed with the
%                           function described in parameter. Function needs
%                           to be know to matlab (internal or in path).
%                           Parameters: function name
%                           example: 'abs'
%
%    
%     Recommended environment: Tested mostly with Matlab R2011b, Windows 7
%                              Enterprise (Sp1) 32-bit, Intel Core2 6300-CPU
%                              for larger files, use 64-bit and more RAM.
%
%   ATTENTION: Exceptions might be thrown by the script (and underlying functions),
%   so it may be a good idea to put a try-catch block in the script-file...
%    
%   WARNING! This software has been tested, but there could still be 
%   some bugs left. Use it at your own risk! The authors hold no 
%   responsibility for any damages caused by using the software nor promise 
%   any guarantee of suitability of the software for any particular purpose.
%
%   Software licence is found under the licence/ folder included in the
%   distribution.

% For deeper understanding of the GUI/script:
%
% Important folders:
%  functions/       =   container for all additional functions used by the
%                       program(s)
%  graphics/        =   container for all the graphics for the program(s)
%  locs/            =   container for additional location files (optional)
%  licence/         =   contains the licence for this software
%                       
%
% Central variables of this GUI (stored in appdata, inside gcf):
%  setid            =   set identifier, this program uses the filename of the
%                       loaded file as an identifier
%  EEG              =   Appdata-type global variable which stores the original
%                       continuous EEG-dataset
%  ALLEEG           =   Appdata-type global variable array of epoched EEG-datasets 
%                       whose setname describes the event-type for the dataset
%                       THE PRESENCE OF ALLEEG-VARIABLE INFORMS THE PROGRAM THAT
%                       THE USER IS EDITING EPOCHED DATASET
%                       otherwise -> continuous
%  event_validity   =   Appdata-type global variable which holds the structure
%                       of good, detected or marked bad or interpolated epoch.
%                       The format for this is a containers.Map-struct containing
%                       event id's as keys. Values are arrays [channel nepoch].
%                       The arrays store integers, 0=good event, 2=detected
%                       bad event, 9=interpolated.
%  urevent_validity =   Original event_validity (full of 0's, just for the
%                       size comparisons in statistical output)
%  haxes            =   stores the handles of the electrode-drawing axes
%  eegvideo         =   stores the handle for the loaded video-object
%  removed_epochs   =   containers.Map containing information (vector) about removed
%                       epochs by each event id (keys)
%  settings         =   contains settings from settings file or defaulted
%                       (cell array)
%  currentpath      =   string containing the path where the user last time
%                       loaded something
%  rootdir          =   directory of the eegtoolPreprocess function
%  iscontrolpressed =   whether control is beign pressed at the moment
%                       (channel to be marked bad by click?)
%  
%
%
% It should be relatively easy to add new functionality to the script e.g.
% calls to e.g. other Eeglab-functions. Our aim was to use good programming 
% practices throught the program. Also we paid attention to documentation 
% and testing phases.

% register the rootdirectory where the eegtoolPreprocess script is located
rootdir = fileparts(mfilename('fullpath'));

% Construct pathing for the program
constructEegtoolPaths(rootdir);

% version number
h.version = '1.034';

varargout = {};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% scripting mode
if ~(nargin==0)
    
    % perform some error-detection tasks
    % even number of steps (each step has also parameters)
    len_epoch_pros = length(epoched_procedure);
    len_cont_pros = length(continuous_procedure)
    continuous_procedure
    if (mod(len_epoch_pros, 2) ~= 0) || mod(len_cont_pros, 2) ~= 0
        error('preProcedure or initprocedure parameters contains odd number of fields so something is missing.');
    end
    continuous_steps = 1:2:len_cont_pros;
    epoching_steps = 1:2:len_epoch_pros;
    
    % check if chanlocs should be loaded
    load_chanlocs_separately = 0;
    if iscell(filename)
        fname = filename{1};
        chanfname = filename{2};
        load_chanlocs_separately = 1;
    else
        fname = filename;
    end
    
    variable_or_filename_input = ischar(fname);
    
    % check if filename argument was a string or variable in the workspace
    if variable_or_filename_input
        [~, fname_no_extension, extension] = fileparts(fname);
        
        if strcmp(extension, '.raw')
            %read eeg-data to EEG-datastructure with eeglab-functions
            EEG = pop_readegi([d_path filesep fname]);

        elseif strcmp(extension, '.cnt')
            % read the cnt-data with EEGLAB-funtions
            EEG = pop_loadcnt([d_path filesep fname]);

        elseif strcmp(extension, '.set')
            % read the cnt-data with EEGLAB-funtions
            EEG = pop_loadset([d_path filesep fname]);
            
        elseif strcmp(extension, '.mat')
            % read the .mat-data (take CONTINUOUS data out)
            [~, EEG, ~, ~, ~, ~, ~] = loadMatFile([d_path filesep fname]);

        elseif strcmp(extension, '.eeg')
            load([d_path filesep fname], '-mat');
        end
    else
        % read the file as an input variable
        EEG = fname;
        fname_no_extension = inputname(3);
        EEGS = [];
        fname = inputname(3); % this is probably not very good programming...
    end
    
    % check if result folder exists and if not, make it
    if ~isdir(d_out_path)
        mkdir(d_out_path);
    end
    
    % load chanlocs if input was cell
    if load_chanlocs_separately
       EEG.chanlocs = readlocs(chanfname);
    end
    
    % continuous part, all the phases done to each stim-type epoch
    for i = continuous_steps
    
        identifier = continuous_procedure{i};
        parameter = continuous_procedure{i+1};
        
        switch(identifier)
            case 'filter'
                EEG = pop_eegfilt(EEG, parameter(1), parameter(2));
            case 'addevents'
                EEG = pop_importevent(EEG, 'event', parameter, 'fields', { 'type', 'latency' }, 'delim', ',');
            otherwise
                error('epoched_procedure-parameter contains unidentified parameter.');
        end
    end
    
    % initialize epoched-mode variables
	event_validity = containers.Map;
	urevent_validity = containers.Map;
	removed_epochs = containers.Map;
	
	nonemptyeegcounter = 1;
	
    % epoching part, all the phases done to each stim-type epoch
    for i=1:length(stim_ids)
		disp(['Processing stimulus ' stim_ids{i} '...']);
		
        % epoch data
        EEG2 = pop_epoch(EEG, stim_ids(i), [epoch_limits(1)/1000 epoch_limits(2)/1000], 'newname', stim_ids{i}, 'epochinfo', 'yes');
		setname = EEG2.setname;
        
        % generate matrix of good events and bad events (rows are channels,
        % columns are events)
        epochs = length(EEG2.epoch);
        
        % eeglab bug or "feature" of not putting epochs to 1 at all
        if epochs == 0
           epochs = 1; 
        end
        
        
        
        % Add urepoch-field to epoch-substruct (reason: to preserve
        % original epoch numbering
        for k=1:epochs%length(EEG2.epoch)
            EEG2.epoch(k).urepoch = k;
        end
        
        
        urev_val = zeros([EEG2.nbchan epochs]);
		
		% save info of pre-rejected epochs 
		saveRejectionInfo(d_out_path, fname, stim_ids{i}, bad_epochs{i}, urev_val);

        % truncate list of bad epochs if it's too long for epoched EEG2
        if max(bad_epochs{i}) > EEG2.trials
            bad_epochs{i} = bad_epochs{i}(bad_epochs{i} <= EEG2.trials);
            disp([char(10) 'List of bad epochs exceeds EEG2.trials, list truncated!' char(10)] );
        end
        
        % remove the marked epochs
		[EEG2, ev_val] = removeEpoch(EEG2, urev_val, bad_epochs{i});
        removed_epochs(setname) = bad_epochs{i};
        
        % loop throught the procedure
        for j = epoching_steps
			
            if ~isempty(EEG2) % if the EEG2 becomes empty at some step
				
				identifier = epoched_procedure{j};
				parameter = epoched_procedure{j+1};

				% what to do on this step? Calculation and parameter meaning
				% (if any) specified by the identifier
				switch identifier
					case 'blc'
						[EEG2, ~] = pop_rmbase(EEG2, parameter);
					case 'ad'
						% detect artefacts and gather event_validity matrix
						[ev_val_new, ~] = artefactDetection(EEG2, parameter{1}, parameter{2});
						% not checking already interpolated because assumed to be first interpolation

                        % check that the new event_validity matrix does not overwrite the old 
						ev_val = combine_ev(ev_val_new, ev_val, parameter{3});

					case 'rejepochs'
						[EEG2, ev_val, new_removed] = rejectEpochsByTreshold(EEG2, ev_val, parameter);
						removed_epochs(setname) = [removed_epochs(setname) new_removed ];
					   %change 3rd parameter to be -> removed epochs!!
					
                    case 'detrend'
						EEG2 = detrendEEG(EEG2);

					case 'interpolate'
						[EEG2, ev_val] = interpolateBadChan(EEG2, ev_val);

					case 'rereference'
						EEG2 = reReference(EEG2, parameter{1}, parameter{2});
						disp(['Excluding channels: ' num2str(parameter{2}) ' from the rereference.']);

					case 'markchannelbad'
						% for each stimulus type, mark the channel bad
						ev_val_new = zeros(size(ev_val));
                        ev_val_new(parameter, :) = 2;

                        % check that the new ev_val matrix does not overwrite the old 
						ev_val = combine_ev(ev_val_new, ev_val, 0);

					case 'impedancetresh'
						impedancevector = loadImpedanceFile([d_path filesep fname '.IMP']);
						disp(['Tresholding impedance with limit: ' num2str(parameter)]);
                            
                        ev_val_new = ev_val;
						removethesechan = find(impedancevector > parameter);
						%ev_val(removethesechan, ev_val(removethesechan, :)~=9) = 2;
                        ev_val_new(removethesechan, :) = 2;
                        ev_val = combine_ev(ev_val_new, ev_val, 1);
                        
                    case 'savetrends'
                        saveTrends(EEG2, fname, parameter);

                    case 'rect'
                        EEG2 = rectifyEEG(EEG2);

                    case 'process_with_fcn'
                        EEG2 = processWithFunction(parameter, EEG2);
                        
					otherwise
						error('epoched_procedure-parameter contains unidentified parameter.');

					% here additional processing steps would go
                end
            else
                disp('EEG-datastruct became empty. Moving to next dataset.');
            end
        end

		
		if ~isempty(EEG2) % if EEG2 was not empty -> save
			urevent_validity(EEG2.setname) = urev_val;
			event_validity(EEG2.setname) = ev_val;
			ALLEEG(nonemptyeegcounter) = EEG2;
			nonemptyeegcounter = nonemptyeegcounter+1;
                
            varargout{1} = ['EEG2.trials: ' num2str(EEG2.trials)];
            
			% save this set file
            if variable_or_filename_input
                if (savemode == 1 || savemode == 3)
                    saveSet(d_out_path, fname, EEG2, ev_val, urev_val);
                end
            else 
                EEGS = [EEGS EEG2];
            end
        else
			disp('All the epochs of this dataset were-removed. Set data not saved for this condition.');
            varargout{1} = 'All the epochs of this dataset were-removed. Set data not saved for this condition.';
		end

        clearvars ev_val urev_val EEG2;
    end
    
    
    % saving the dataset in .mat-form
    if variable_or_filename_input
        if (savemode == 2 || savemode == 3)
            if nonemptyeegcounter > 1
                % epoched data around -> fille epoch specific variables
                % accordingly
                saveMatFile([d_out_path filesep fname_no_extension '.mat'], fname, EEG, ALLEEG, event_validity, urevent_validity, removed_epochs);
            else
                % no epoched data around -> epoch-specific variables to
                % empty
                saveMatFile([d_out_path filesep fname_no_extension '.mat'], fname, EEG, [], [], [], []);
            end
         end
    else
        varargout{1} = ['EEGS.trials: ' EEGS.trials];
    end
    
    return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Non scripting-mode

% draw the head-background gui
h.eegtool = headGui(['eegtoolPreprocess ' h.version ' - no dataset']);

% define ui elements
h.winlentext = uicontrol('Style', 'text', 'string', 'winlen (ms)', ...
                    'units', 'normalized', 'position', [0.01 0.01 0.08 0.03], ...
                    'horizontalalignment', 'left');
                
h.ymintext = uicontrol('Style', 'text', 'string', 'ymin (uV)', ...
                    'units', 'normalized', 'position', [0.01 0.05 0.08 0.03], ...
                    'horizontalalignment', 'left');

h.ymaxtext = uicontrol('Style', 'text', 'string', 'ymax (uV)', ...
                    'units', 'normalized', 'position', [0.01 0.09 0.08 0.03], ...
                    'horizontalalignment', 'left');

h.yminedit = uicontrol('Style', 'edit', 'string', '-', ...
                    'units', 'normalized', 'position', [0.11 0.05 0.04 0.03], ...
                    'horizontalalignment', 'center');
               
h.ymaxedit = uicontrol('Style', 'edit', 'string', '-', ...
                    'units', 'normalized', 'position', [0.11 0.09 0.04 0.03], ...
                    'horizontalalignment', 'center');
                
h.winlenedit = uicontrol('Style', 'edit', 'string', '5000', ...
                    'units', 'normalized', 'position', [0.11 0.01 0.04 0.03], ...
                    'horizontalalignment', 'center');

h.timeslider = uicontrol('Style', 'slider', 'units', 'normalized', 'position', [0.333 0.08 0.333 0.04]);

h.eventlistbox = uicontrol('Style', 'listbox', 'units', 'normalized', 'position', [0.89 0.88 0.105 0.11]);

h.epochlimtext = uicontrol('Style', 'text', 'string', '', 'units', 'normalized', ...
                           'position', [0.01 0.96 0.15 0.03], 'horizontalalignment', 'left');%[0.88 0.85 0.1 0.02]);

h.pointtext = uicontrol('Style', 'text', 'string', 'Time/event', ...
                        'units', 'normalized', 'position', [0.390 0.035 0.07 0.03], ...
                        'horizontalalignment', 'center');

h.pointedit = uicontrol('Style', 'edit', 'string', '-', 'units', 'normalized', 'position', [0.470 0.035 0.04 0.03], ...
                    'horizontalalignment', 'center', 'enable', 'off');

h.rmepochbutton = uicontrol('Style', 'pushbutton', 'string', 'Remove epoch', ...
                    'horizontalalignment', 'center', 'units', 'normalized', 'position', [0.520 0.035 0.1 0.03]);

h.dispchanedit = uicontrol('Style', 'checkbox', 'string', 'Display channel numbers', ...
                   'horizontalalignment', 'center', 'units', 'normalized', 'position', [0.37 0.005 0.16 0.03]);
			   
h.dispxaxis = uicontrol('Style', 'checkbox', 'string', 'Display x-axis', 'value', 1, ...
                        'horizontalalignment', 'center', 'units', 'normalized', 'position', [0.54 0.005 0.16 0.03]);

% set keypressfcn for the figure
set(h.eegtool,'KeyPressFcn', {@buttonPressControl});
set(h.eegtool,'KeyReleaseFcn', {@buttonReleaseControl});

% Set keypressfunction for the current children of the figure
hChildren = get(h.eegtool, 'Children');
set(hChildren, 'KeyPressFcn', {@buttonPressControl});

h.filemenu = uimenu('Label', 'File');
h.loaditem = uimenu(h.filemenu, 'Label', 'Open datafile');
h.saveitem = uimenu(h.filemenu, 'Label', 'Save dataset');
h.printitem = uimenu(h.filemenu, 'Label', 'Print view');
h.clearitem = uimenu(h.filemenu, 'Label', 'Clear view');
h.videoitem = uimenu(h.filemenu, 'Label', 'Load video');
h.chanitem = uimenu(h.filemenu, 'Label', 'Edit channel locations');
h.quititem = uimenu(h.filemenu, 'Label', 'Quit');

h.modemenu = uimenu('Label', 'Mode');
h.contitem  = uimenu(h.modemenu, 'Label', 'Continuous', 'checked', 'off');
h.epochitem = uimenu(h.modemenu, 'Label', 'Epoched', 'checked', 'off');

h.premenu = uimenu('Label', 'Preprocessing');
h.filtitem = uimenu(h.premenu, 'Label', 'Filter');
h.impedanceitem = uimenu(h.premenu, 'Label', 'Impedances');
h.baselinecitem = uimenu(h.premenu, 'Label', 'Baseline Correction');
h.rectitem = uimenu(h.premenu, 'Label', 'Rectify');
h.detrenditem = uimenu(h.premenu, 'Label', 'Detrend');
h.erroritem = uimenu(h.premenu, 'Label', 'Artefact detection');
h.rejectepochsitem = uimenu(h.premenu, 'Label', 'Reject epochs by treshold');
h.interpitem = uimenu(h.premenu, 'Label', 'Interpolate bad segments');
h.rerefitem = uimenu(h.premenu, 'Label', 'Re-reference');

h.statmenu = uimenu('Label', 'Statistics');
h.disprejecteditem = uimenu(h.statmenu, 'Label', 'Display removed epochs');
%h.disptrendsitem = uimenu(h.statmenu, 'Label', 'Display trends');

% define callbacks (after defining items, because item handles given as
% parameters)
set(h.yminedit, 'callback', {@edit_callback, h});
set(h.ymaxedit, 'callback', {@edit_callback, h});
set(h.timeslider, 'callback', {@timeslider_callback, h});
set(h.eventlistbox, 'callback', []);
set(h.loaditem, 'callback', {@loadbutton_callback, h});
set(h.chanitem, 'callback', {@chanbutton_callback, h});
set(h.clearitem, 'callback', {@clearbutton_callback, h});
set(h.quititem, 'callback', {@quitbutton_callback});
set(h.contitem, 'callback', {@contbutton_callback, h});
set(h.epochitem, 'callback', {@epochbutton_callback, h});
set(h.detrenditem, 'callback', {@detrend_callback, h});
set(h.erroritem, 'callback', {@errorbutton_callback, h});
set(h.rejectepochsitem, 'callback', {@rejepochs_callback, h});
set(h.interpitem, 'callback', {@interpbutton_callback, h});
set(h.rmepochbutton, 'callback', {@rmepochbutton_callback, h});
set(h.saveitem, 'callback', {@savebutton_callback, h});
set(h.filtitem, 'callback', {@filtbutton_callback, h});
set(h.impedanceitem, 'callback', {@impedancebutton_callback, h});
set(h.baselinecitem, 'callback', {@baselinec_callback, h});
set(h.rectitem, 'callback', {@rect_callback, h});
set(h.dispchanedit, 'callback', {@edit_callback, h});
set(h.dispxaxis, 'callback', {@edit_callback, h});
set(h.rerefitem, 'callback', {@rerefbutton_callback,h});
set(h.printitem, 'callback', {@print_callback, h});
set(h.videoitem, 'callback', {@loadvideo_callback, h});
set(h.disprejecteditem, 'callback', {@disprejected_callback});
%set(h.disptrendsitem, 'callback', {@disptrends_callback});

% set some objects backgrounds to white
set(hChildren(strcmp(get(hChildren, 'style'), 'text')), 'backgroundcolor', [1 1 1]);
set(hChildren(strcmp(get(hChildren, 'style'), 'checkbox')), 'backgroundcolor', [1 1 1]);

% set default keypressfcn for figure children (for example to the axes...)
set(h.eegtool,'DefaultUicontrolKeyPressFcn', {@buttonPressControl});
set(h.eegtool,'CloseRequestFcn', {@eeg_closerequestfcn, h});

% set initial values
settings = loadSettings(rootdir);
setappdata(h.eegtool, 'settings', settings);

% set default y-axis values 
set(h.yminedit, 'String', '-200');
set(h.ymaxedit, 'String', '200');

% switch buttonmode -> continuous
controlEpochButtons(h, 'Off');

setappdata(h.eegtool, 'currentpath', pwd);
setappdata(h.eegtool, 'rootdir', rootdir);
% let the gui wait for input


function buttonPressControl(~,evnt)
% Function handles the keypresses on the gui

% pressed key
k = evnt.Key;

if isequal(k, 'control')
    % change the pointer style
    set(gcf, 'Pointer', 'circle');
    setappdata(gcf, 'iscontrolpressed', 1);
end


function buttonReleaseControl(~,evnt)
% pressed key
k = evnt.Key;

% if control released, return the icon to norm and uncheck
% iscontrolpressed
if isequal(k, 'control')
    % change the axes clickfcn
    set(gcf, 'Pointer', 'arrow');
    setappdata(gcf, 'iscontrolpressed', 0);
end


function print_callback(~, ~, h)
% prints the input gui
% guihandle = handle of the gui desired to be printed

[filename, dpath] = uiputfile('*.png');

if filename == 0
    return;
end

print(h.ekgtool, '-dpng', strcat(dpath, filesep, filename));


function loadvideo_callback(~, ~, h)
% callback function for the load video button. Loads video and displays it
% in a different gui

% if checkVideo(h);
%     return;
% end

% get filename and path, load the file
currentpath = getappdata(h.eegtool, 'currentpath');
filter = {'*.mov;*.avi;*.mp4', 'Matlab supported video-files'};
[filename, dpath] = uigetfile(filter, 'Select video file', currentpath);

% filename was gotten
if (filename == 0)
    return;
end

switchContinuous(h);

setappdata(h.eegtool, 'currentpath', dpath);

% load videoObject
eegvideo = eegmplayer(dpath, filename);

% set the video to destroy it's handle from eegtool when the window is
% closed
set(eegvideo.figHandle, 'closerequestfcn', {@closereq_eegvideo, h.eegtool, eegvideo});
setappdata(h.eegtool, 'eegvideo', [getappdata(h.eegtool, 'eegvideo') eegvideo]);


function closereq_eegvideo(~, ~, heegtool, objh)
% close request function for the eegvideo figure
% figh = handle of the figure

eegvideo = getappdata(heegtool, 'eegvideo');

delete(objh);
eegvideo(~isvalid(eegvideo)) = [];

setappdata(heegtool, 'eegvideo', eegvideo);


%delete(objh);
%rmappdata(heegtool, 'eegvideo'); % remove this appdata all together of keep it empty?


function impedancebutton_callback(~, ~, h)

if ~isappdata(h.eegtool, 'EEG')
	return;
end

% load impedancefile with predefined name
dpath = getappdata(h.eegtool, 'currentpath');
setid = getappdata(h.eegtool, 'setid');
impedancefile = [dpath setid '.IMP'];

if exist(impedancefile, 'file') ~= 2
	errordlg(['Could not found impedance file: ' impedancefile '.']);
	return;
end

impedancevector = loadImpedanceFile(impedancefile);

EEG = getappdata(h.eegtool, 'EEG');
event_validity = getappdata(h.eegtool, 'event_validity');

hfig = figure;

set(hfig, 'menubar', 'none', 'numbertitle', 'off', 'name', ['Impedances: ' setid]);

% set backgroung image
hBg =  axes('units','normalized', 'position',[0 0 1 1]);

% Move the background axes to the bottom
uistack(hBg,'bottom');

if isappdata(h.eegtool, 'ALLEEG')
	% if in epoched mode -> make tresholding possible
	hi.impedancetreshtext = uicontrol('Style', 'text', 'string', 'Impedance treshold', ...
                                      'units', 'normalized', 'position', [0.32 0.03 0.15 0.04], ...
                                      'horizontalalignment', 'center', 'backgroundcolor', [1 1 1]);
	
	hi.impedancetreshedit = uicontrol('Style', 'edit', 'string', '50', ...
                                      'units', 'normalized', 'position', [0.48 0.03 0.04 0.04], ...
                                      'horizontalalignment', 'center');

	hi.impedancetreshbutton = uicontrol('Style', 'pushbutton', 'string', 'Reject channels', ...
                                        'units', 'normalized', 'position', [0.53 0.03 0.15 0.04], ...
                                        'horizontalalignment', 'center');

	set(hi.impedancetreshbutton, 'callback', {@imptresh_callback, h, hi, event_validity, impedancevector});
else 
	hi.impedancetreshtext = uicontrol('Style', 'text', 'string', 'Switch to epoched mode to treshold channels using impedances.', ...
	                                  'units', 'normalized', 'position', [0.10 0.03 0.8 0.04], ...
	                                  'horizontalalignment', 'center', 'backgroundcolor', [1 1 1]);
end

for i=1:length(EEG.chanlocs)
    % retrieve channel coordinates and do transform polar -> cartesian
    % (for location)
    r(i) = EEG.chanlocs(i).radius;

    theta(i) = (EEG.chanlocs(i).theta/360)*2*pi;

end

% normalize the r and make it to be a bit smaller than 0->1
r = r./(1.3*max(r));

for i=1:length(r)

    %polar->cartesian transform
    x = r(i) * cos(theta(i));
    y = r(i) * sin(theta(i));
	
	ydraw = 0.56 + 0.56*x;%0.58*x;
    xdraw = 0.5 + 0.58*y;
	
	value = round(impedancevector(i)/10)+5;
	
	text(xdraw, ydraw, [EEG.chanlocs(i).labels ':' num2str(round(impedancevector(i)))], ...
		 'fontsize', value, 'horizontalalignment', 'center');
end

set(gca, 'XTick',[], 'YTick', []);


function imptresh_callback(~,~, h, hi, event_validity, impedancevector)

tresh = str2num(get(hi.impedancetreshedit, 'string'));
removethesechan = find(impedancevector>tresh);

% for each stimulus type, mark the channel bad
evkeys = event_validity.keys;
for i=1:length(evkeys)
	ev_val = event_validity(evkeys{i});
	ev_val(removethesechan, ev_val(removethesechan, :)~=9) = 2;
	event_validity(evkeys{i}) = ev_val;
end

close gcf;

set(0, 'CurrentFigure', h.eegtool);

drawEpochData(get(h.eventlistbox, 'value'), round(get(h.timeslider, 'Value')), h);


function loadbutton_callback(~, ~, h)
% callback for the "load" button on buttonpress

% load EEG-file (as continuous dataset)

% retrieve filename & path
% filename filter
currentpath = getappdata(h.eegtool, 'currentpath');
filter = {'*.raw;*.cnt;*.set;*.mat; *.eeg', 'Continuous EEG-datafiles (.raw, .cnt, .set, .eeg) or EEGDATA-mat-files (.mat)'};
[filename, dpath]=uigetfile(filter, 'Select datafile to open', currentpath);

% filename was gotten
if (filename == 0)
    return;
end

setappdata(h.eegtool, 'currentpath', dpath);
set(h.eegtool, 'name', ['Eegtool-preprocess ' h.version ' - ' filename]);

% clear all data
removeAxes(h);
clearDatastructs(h);
clearFields(h);

extension = filename(end-3:end);

% draw channels to their corresponding locations
axdim = [0.05 0.04];
try
    if strcmp(extension, '.mat')
        % user loads pre-saved ask-dataset

        [~, EEG , ALLEEG, event_validity, urevent_validity, removed_epochs, vinfo] = loadMatFile([dpath filesep filename]);

        % check if mat file contains epoched EEG
        if isempty(ALLEEG)
            % only continuous data -> Do nothing, EEG is processed like
            % with other forms of files
        else
            % epoched data
            
            %set other variables
            setappdata(h.eegtool, 'setid', filename);
            setappdata(h.eegtool, 'EEG', EEG);
            setappdata(h.eegtool, 'ALLEEG', ALLEEG);
            setappdata(h.eegtool, 'event_validity', event_validity);
            setappdata(h.eegtool, 'urevent_validity', urevent_validity);
            setappdata(h.eegtool, 'removed_epochs', removed_epochs);

            controlSlider(ALLEEG(1), 1, h);

            % draw the axis corresponding to the electrode locations to the headgui
            haxes = drawTopoAxis(h.eegtool, EEG.chanlocs, axdim, 'Time (s)', 'Power (\muV)');

            % set the handles of the axes areas to global variables
            setappdata(h.eegtool, 'haxes', haxes);

            % get the stimulus/event descriptions to cell -> listbox
            event={};
            for i=1:length(ALLEEG)
                event{end+1} = ALLEEG(i).setname;
            end

            % set the stimulus types for the event type listbox and choose first one
            set(h.eventlistbox, 'value', 1);
            set(h.eventlistbox, 'string', event);
            set(h.epochlimtext, 'string', ['Epoch: ' num2str(ALLEEG(1).xmin*1000) ' ' num2str(ALLEEG(1).xmax*1000)]);

            drawEpochData(1, 1, h);

            % enable epoch-related function buttons        
            set(h.contitem, 'enable', 'On');
            controlEpochButtons(h, 'On');

            % enable video
            if ~isempty(vinfo)

                for i=1:length(vinfo)
                
                    % load videoObject
                    eegvideo = eegmplayer(dpath, vinfo(i).filename);
                    set(eegvideo.figHandle, 'closerequestfcn', {@closereq_eegvideo, h.eegtool, eegvideo});

                    set(0, 'CurrentFigure', h.eegtool);

                    setappdata(h.eegtool, 'eegvideo', [getappdata(h.eegtool, 'eegvideo') eegvideo]);
                    
                    % if loading video object succesful
                    if checkVideo(h)
                        eegvideo.inputEpoching(vinfo(i).first_stim_frame, vinfo(i).epoching);
                        eegvideo.moveToEpoch(1, ALLEEG(1).epoch(1).urepoch);
                    end
                end
            end

            return;
        end
    
	elseif strcmp(extension, '.raw')
        %read eeg-data to EEG-datastructure with eeglab-functions
        EEG = pop_readegi(strcat(dpath,filename));

	elseif strcmp(extension, '.cnt') %#ok<*ALIGN>
        % read the cnt-data with EEGLAB-funtions
        EEG = pop_loadcnt(strcat(dpath,filename));
    
	elseif strcmp(extension, '.set')
        % read the cnt-data with EEGLAB-funtions
        EEG = pop_loadset(strcat(dpath,filename));
                
    elseif strcmp(extension, '.eeg')
        load(strcat(dpath,filename), '-mat');
    else
        return;
    end
    
catch err
	errordlg(err.message);
	setFigNameDefault(h);
	return;
end

% if the channel locations are missing, give the user the opportunity
% to load them from an external file
if isempty(EEG.urchanlocs)
    [filename2, dpath2] = uigetfile('*.loc', ['Select map-file for ' num2str(EEG.nbchan) '-channel EEG file.']);
    if ~(filename2 == 0)
        try
            EEG.chanlocs = readlocs(strcat(dpath2, filename2));
        catch err
            errordlg(err.message);
            return;
        end

        nchanimported = length(EEG.chanlocs);
        nchanshouldbe = EEG.nbchan;
        if ~(nchanshouldbe == nchanimported)
            % check that channel-count corresponds to nbchan
            errordlg(['The channel-file channel-count(' num2str(nchanimported) ...
                ') does not correspond to the EEG-file(' num2str(nchanshouldbe) ').']);
            return;    
        end
    else
        errordlg('Could not find channel locations for this kind of file');
        return;
    end
end

% draw the axis corresponding to the electrode locations to the headgui
haxes = drawTopoAxis(h.eegtool, EEG.chanlocs, axdim, 'Time (ms)', 'Pover (\muV)');

% set the handles of the axes areas to global variables
setappdata(h.eegtool, 'haxes', haxes);

% set setid to global variable
setappdata(h.eegtool, 'setid', filename);

if isempty(EEG.epoch) % if not empty -> epoched data
    % set CONTINUOUS EEG-data to global variable
    setappdata(h.eegtool, 'EEG', EEG);
    
    % do operations like tuning sliders and drawing etc.
    set(h.contitem, 'enable', 'On');
    switchContinuous(h);
else
    switchEpochedOnly(h);
    
    event_validity = containers.Map;
    urevent_validity = containers.Map;
    removed_epochs = containers.Map;
    EEG = generateALLEEG(EEG, event_validity, urevent_validity, removed_epochs);
    
    setappdata(h.eegtool, 'event_validity', event_validity)
    setappdata(h.eegtool, 'urevent_validity', urevent_validity)
    setappdata(h.eegtool, 'removed_epochs', removed_epochs);

    set(h.eventlistbox, 'value', 1);
    set(h.eventlistbox, 'string', generateEventIds(EEG));

    set(h.epochlimtext, 'string', ['Epoch: ' num2str(EEG.xmin*1000) ' ' num2str(EEG.xmax*1000)]);
    
    setappdata(h.eegtool, 'ALLEEG', EEG);
    
    controlSlider(EEG, 1, h);
    
    drawEpochData(1, 1, h)
end

function setFigNameDefault(h)

set(h.eegtool, 'name', ['Eegtool-preprocess ' h.version ' - no dataset']);


function is_video_present = checkVideo(h)
% checks if video-object is present on the program

%is_video_present = isappdata(h.eegtool, 'eegvideo') && isvalid(getappdata(h.eegtool, 'eegvideo'));
is_video_present = ~isempty(getappdata(h.eegtool, 'eegvideo'));

function chanbutton_callback(~, ~ ,h)

% if there is no data
if ~isappdata(h.eegtool, 'EEG')
    return;
end

EEG = getappdata(h.eegtool, 'EEG');

newchansEEG = pop_chanedit(EEG);

setappdata(h.eegtool, 'EEG', newchansEEG);
removeAxes(h);

% draw channels to their corresponding locations
axdim = [0.05 0.04];

% draw the axis corresponding to the electrode locations to the headgui
haxes = drawTopoAxis(newchansEEG.chanlocs, axdim, 'Time (ms)', 'Pover (\muV)');

% set the handles of the axes areas to global variables
setappdata(h.eegtool, 'haxes', haxes);

switchContinuous(h);

function rect_callback(~, ~ ,h)

ALLEEG = getappdata(h.eegtool, 'ALLEEG');

for i=1:length(ALLEEG)
    [ALLEEG(i)] = rectifyEEG(ALLEEG(i));
end

setappdata(h.eegtool, 'ALLEEG', ALLEEG);

drawEpochData(get(h.eventlistbox, 'value'), round(get(h.timeslider, 'Value')), h);


function baselinec_callback(~, ~ ,h)

settings = getappdata(h.eegtool, 'settings');

% Gui to parse baseline values
prompt = {'Baseline start point (ms)','Baseline end point (ms)'};
dlg_title = 'Baseline correction';
num_lines = 1;
def = {settings{3}, settings{4}};
answer = inputdlg(prompt,dlg_title,num_lines,def);

% if answer was empty
if (isempty(answer) || isempty(answer{1}) || isempty(answer(2)))
   return;
end

settings{3} = answer{1};
settings{4} = answer{2};

ALLEEG = getappdata(h.eegtool, 'ALLEEG');

for i=1:length(ALLEEG)
    timerange = [str2num(answer{1}) str2num(answer{2})];
    [ALLEEG(i), ~] = pop_rmbase( ALLEEG(i), timerange);
end

setappdata(h.eegtool, 'ALLEEG', ALLEEG);
setappdata(h.eegtool, 'settings', settings);

drawEpochData(get(h.eventlistbox, 'value'), round(get(h.timeslider, 'Value')), h);


function epochbutton_callback(~, ~, h)
% a callback-function which runs when the epoched-button is pressed
% no extra parameters

if ~(isappdata(h.eegtool, 'EEG') || isappdata(h.eegtool, 'ALLEEG'))
    % dont turn on button
    set(h.epochitem, 'checked', 'off');
    set(h.contitem, 'checked', 'on');
    return;
elseif isappdata(h.eegtool, 'EEG')
    % continuous data available
    EEG = getappdata(h.eegtool, 'EEG');
else
    % only epoched data available
    EEG = getappdata(h.eegtool, 'ALLEEG');
end


% initialize channel & parameter selector
settings = getappdata(h.eegtool, 'settings');
[event, winopts]  = inputEventsGui(EEG, settings);

settings{1} = winopts{1};
settings{2} = winopts{2};

% the data is epoched such as: one stimulus type -> one epoched dataset
% how many epochs do we need
n_included_events = length(event);

% if events were selected -> form epoched EEG
if (n_included_events == 0) 
   return; 
end

% truth value to validate if video-object is available
is_video_present = checkVideo(h);

EDITED_EEG = EEG;

if (is_video_present)
    % form vector for epoching the VIDEO
    samplingVector = 1:length(EEG.data(1,:));

    % add sampling vector to the end of data-matrix
    EDITED_EEG.data = [EEG.data; samplingVector];
    EDITED_EEG.nbchan = EEG.nbchan+1;
    EDITED_EEG.chanlocs(end+1) = EEG.chanlocs(1); 
end

% destroy old ALLEEG data
if isappdata(h.eegtool, 'ALLEEG')
    rmappdata(h.eegtool, 'ALLEEG');
end

event_validity = containers.Map;
urevent_validity = containers.Map;
removed_epochs = containers.Map;
for i=1:n_included_events
    offset = str2num(settings{1})/1000;

    % generate epoched dataset
    nALLEEG = pop_epoch(EDITED_EEG, event(i), [offset str2num(settings{2})/1000], 'newname', event{i}, 'epochinfo', 'yes');

    % no epochs could be formed for some reason (=> only one epoch, crude hax for EEG-datastruct...)
    %if isempty(ALLEEG(i).epoch)
    if nALLEEG.trials == 1
        % do an artificial epoch to the struct
        arepoch.urepoch = 1;
        
        times1 = nALLEEG.xmin:1/nALLEEG.srate:nALLEEG.xmax;
        
        nALLEEG.epoch = arepoch;
        nALLEEG.times = times1*1000;

    elseif nALLEEG.trials == 0
        % no epochs at all
        errordlg(['One of the selected event-types cannot be epoched. Please re-epoch data without the event. Problematic stimulus type: ' nALLEEG.setname '.']);
        controlEpochButtons(h, 'Off');        
        switchContinuous(h);
        return;
    end

    if (is_video_present)
        % reset the changes made to EEG->ALLEEG struct
        video_vect{i} = nALLEEG.data(end, :, :);
        evid(1:nALLEEG.trials) = {nALLEEG.setname};
        eventids{i} = evid;
        nALLEEG.data(end, :, :) = [];
        nALLEEG.nbchan = nALLEEG.nbchan - 1;
        % chanlocs are lost in the process (EEGLAB self check etc....)
        nALLEEG.chanlocs = EEG.chanlocs;
        clearvars evid;
    end

    % perform operations on/with epoched EEG struct to be compatible 
    ALLEEG(i) = generateALLEEG(nALLEEG, event_validity, urevent_validity, removed_epochs);    
end

% set the stimulus types for the event type listbox and choose first one
set(h.eventlistbox, 'value', 1);
set(h.eventlistbox, 'string', generateEventIds(ALLEEG));

if(is_video_present)
    EEG.nbchan = EEG.nbchan-1;
    eegvideo = getappdata(h.eegtool, 'eegvideo');
    for i=1:length(eegvideo)
        eegvideo(i).inputEpoching(video_vect, EEG.srate, offset, eventids);
        eegvideo(i).moveToEpoch(1,1);
    end
end

setappdata(h.eegtool, 'event_validity', event_validity);
setappdata(h.eegtool, 'urevent_validity', urevent_validity);
setappdata(h.eegtool, 'removed_epochs', removed_epochs);
setappdata(h.eegtool, 'ALLEEG', ALLEEG);
setappdata(h.eegtool, 'settings', settings);

set(h.epochlimtext, 'string', ['Epoch: ' num2str(ALLEEG(1).xmin*1000) ' ' num2str(ALLEEG(1).xmax*1000)]);
controlSlider(ALLEEG(1), 1, h);

drawEpochData(1, 1, h);

% enable epoch-related function buttons
controlEpochButtons(h, 'On');

function EEG = generateALLEEG(EEG, event_validity, urevent_validity, removed_epochs)

% these are pointers so no need to return values
event_validity(EEG.setname) = zeros([EEG.nbchan length(EEG.epoch)]);
urevent_validity(EEG.setname) = zeros([EEG.nbchan length(EEG.epoch)]);
removed_epochs(EEG.setname) = [];

% Add urepoch-field to epoch-substruct (reason: to preserve
% original epoch numbering
for k=1:length(EEG.epoch)
    EEG.epoch(k).urepoch = k;
end


function eeg_closerequestfcn(hObject,~, h)
% get settings
saveSettings(getappdata(h.eegtool, 'rootdir'), getappdata(h.eegtool, 'settings'));

% close the video window (and also delete axes)
removeAxes(h);

% call the object destructor
delete(hObject);

function quitbutton_callback(~, ~)
close gcf;


function timeslider_callback(hObject, ~, h)

position = get(hObject,'Value');
   
moveSelection(position, h);


function contbutton_callback(~, ~, h)

if ~isappdata(h.eegtool, 'EEG')
    % dont turn on button
    set(h.epochitem, 'checked', 'off');
    set(h.contitem, 'checked', 'on');
    return;
end

switchContinuous(h);


function clearbutton_callback(~, ~, h)
removeAxes(h);
clearDatastructs(h);
clearFields(h);
set(h.timeslider, 'min', 0, 'max', 1, 'Value', 0);
setFigNameDefault(h);

% set buttons to correct state
controlEpochButtons(h, 'Off');


function edit_callback(~, ~, h)
% a callback-function which runs when interacting with the ymax-field

if (~isappdata(h.eegtool, 'EEG'))
	return;
end

time = round(get(h.timeslider, 'Value'));
winlen = str2num(get(h.winlenedit, 'String'))/1000; %#ok<*ST2NM>

if(~isappdata(h.eegtool, 'ALLEEG'))
    % the continuous mode
    drawContData(time, winlen, h);
else       
    % epoched mode
    drawEpochData(get(h.eventlistbox, 'value'), time, h);
end


function detrend_callback(~,~, h)

ALLEEG = getappdata(h.eegtool, 'ALLEEG');

for k=1:length(ALLEEG)
    ALLEEG(k) = detrendEEG(ALLEEG(k));
end

setappdata(h.eegtool, 'ALLEEG', ALLEEG);

drawEpochData(get(h.eventlistbox, 'value'), round(get(h.timeslider, 'Value')), h);


function errorbutton_callback(~, ~, h)
% a callback-function which runs when the Artefact detection-button is pressed

if ~isappdata(h.eegtool, 'event_validity')
    return;
end

settings = getappdata(h.eegtool, 'settings');

% spawn gui to input parameters for error detection
% treshold = inputVectorGui('Please type error treshold. (uV) Leave empty if you want to remove current error detection.', '200');
[treshold, type, ismarked, overwrite] = inputAdValueGui('Artefact detection method:', 'Treshold:', 'Visualize', 'Overwrite current a-d',...
                                           {'RMS';'Treshold';'Max difference'}, settings{5}, settings{6}, settings{7}, settings{8});

if type == -1
    % user did press quit-button
    return;
end

event_validity = getappdata(h.eegtool, 'event_validity');

ALLEEG = getappdata(h.eegtool, 'ALLEEG');

disp_val=[];
for k=1:length(ALLEEG)
    % form new event_validity-matrix by artefact detection
    [ev_val_new, disp_val1] = artefactDetection(ALLEEG(k), type, treshold);
    
    % check that the new event_validity matrix does not overwrite the old 
    event_validity(ALLEEG(k).setname) = combine_ev(ev_val_new, event_validity(ALLEEG(k).setname), overwrite);
    
    disp_val = [disp_val disp_val1];
end

%%% DISPLAY ARTEFACT DISTRIBUTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ismarked
    x=1:length(disp_val);
    g=figure;
    set(g, 'numbertitle', 'off', 'name', ['Artefact detection: ' type ' subj: ' getappdata(h.eegtool, 'setid')]);
    %plot(x, disp_val, 'linestyle', 'none', 'marker', '.', 'markersize', 4, 'markeredgecolor', 'k');
    plot(x, disp_val, 'color', 'black');
    h1 = line([1 length(x)], [treshold treshold]);
    bad = length(find(disp_val>treshold));
    good = length(disp_val);
    title(['Artefact detection: marked ' num2str(bad) ' erps bad out of ' num2str(good) '. Percentage: ' num2str(100*bad/good) '%.']);
    xlabel('Samples(each point represents single signals value)');
    ylabel(type);

    axis tight;
    set(h1, 'color', 'red');

    set(0, 'CurrentFigure', h.eegtool);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

settings{5} = type;
settings{6} = num2str(treshold);
settings{7} = num2str(ismarked);
settings{8} = num2str(overwrite);
setappdata(h.eegtool, 'settings', settings);

drawEpochData(get(h.eventlistbox, 'value'), round(get(h.timeslider, 'Value')), h);


function ev_val_new = combine_ev(ev_val_new, ev_val, overwrite_old_ad)
% Check that ev_val_new does not display already interpolated epochs as
% "good" -> mark previously (information in event_validity) 
% interpolated as interpolated in ev_val_new.
% same dimension assumed

% parameters:
% ev_val_new        = new event_validity matrix 
% ev_val            = matrix containing values for each chan/epoch whether 
%					  epoch was valid, "bad" or already interpolated 
% overwrite_old_ad  = 1/0, if yes, old artefact detection overwritten(but
%                     not interpolated)

% (not the most beautiful indexing, but does the job)
for i=1:size(ev_val, 1)
    for j=1:size(ev_val, 2)
        % if the event validity contained interpolated values
        % before in this member
        if ev_val(i,j) == 9 
            ev_val_new(i, j) = 9;
		end

		if ~overwrite_old_ad && ~(ev_val(i,j)==0)
			% if old_ev_val had error
			ev_val_new(i, j) = ev_val(i,j);
		end
    end
end

function rejepochs_callback(~,~, h)
% a callback-function which runs when the Reject epochs-button is pressed

ALLEEG = getappdata(h.eegtool, 'ALLEEG');
event_validity = getappdata(h.eegtool, 'event_validity');
removed_epochs = getappdata(h.eegtool, 'removed_epochs');

% Gui to parse baseline values
prompt = {'Please type max treshold (#chan) to be accepted. If one epoch contains more than treshold bad channels the epoch is rejected.'};
dlg_title = 'Reject epochs by treshold';
num_lines = 1;
def = {'10'};
answer = inputdlg(prompt,dlg_title,num_lines,def);

% if answer was empty first condition to be evaluated: did user press
% quit? second condition to be evaluated: did user press okay with empty?
if (isempty(answer) || isempty(answer{1}))
   return; 
end

treshold = str2num(answer{1});

hwait = waitbar(0, 'Rejecting epochs...');

removeindices = [];

for j=1:length(ALLEEG)
	% go through the different ALLEEG-datasets related to different events
	setname = ALLEEG(j).setname;

	[EEG2, ev_val, new_removed] = rejectEpochsByTreshold(ALLEEG(j), event_validity(setname), treshold);

	if isempty(ev_val)
		event_validity.remove(setname);
		removeindices = [removeindices j];
	else
		event_validity(setname) = ev_val;
		ALLEEG(j) = EEG2;
	end

	removed_epochs(setname) = [removed_epochs(setname) new_removed];

	waitbar((j)/(length(ALLEEG)));
end

% remove the "to-be-removed" structs from ALLEEG
ALLEEG(removeindices) = [];

% update the event listbox to the new situation
set(h.eventlistbox, 'string', generateEventIds(ALLEEG));

% close waitbar
close(hwait);

if isempty(ALLEEG)
	switchContinuous(h);
	helpdlg('All epochs removed -> switching back to continuous mode.');
	return;
end

% overwrite the epoched eeg-dataset with purified dataset
setappdata(h.eegtool, 'ALLEEG', ALLEEG);
%setappdata(h.eegtool, 'event_validity', event_validity);
setappdata(h.eegtool, 'removed_epochs', removed_epochs);

% update slider values (event that was chosen in the listbox)
controlSlider(ALLEEG(1), 1, h); %ALLEEG(get(h.eventlistbox, 'value'))

% draw the data (event that was chosen in the listbox)
drawEpochData(1, 1, h); %get(h.eventlistbox, 'value')


function disprejected_callback(~,~)
% a callback-function which runs

if ~isappdata(gcf, 'removed_epochs')
    return;
end

setname = getappdata(gcf, 'setid');
removed_epochs = getappdata(gcf, 'removed_epochs');

eventids = removed_epochs.keys;
for i=1:length(eventids)
	removed_cell{i} = sort(removed_epochs(eventids{i}));
end

displayStatsGui('Epochs removed by hand', setname, eventids, removed_cell);


function interpbutton_callback(~, ~, h)
% a callback-function which runs when the interpolate-button is pressed

ALLEEG = getappdata(h.eegtool, 'ALLEEG');
event_validity = getappdata(h.eegtool, 'event_validity');

hwait = waitbar(0,'Interpolating...');

for j=1:length(ALLEEG)
    % go through the different ALLEEG-datasets related to different events
    [ALLEEG(j), event_validity(ALLEEG(j).setname)] = interpolateBadChan(ALLEEG(j), event_validity(ALLEEG(j).setname));
    
    waitbar((j)/(length(ALLEEG)));
end

close(hwait);

% overwrite the epoched eeg-dataset with epoch-spesifically interpolated
% dataset
setappdata(h.eegtool, 'ALLEEG', ALLEEG);
%setappdata(h.eegtool, 'event_validity', event_validity);

% update slider values (event that was chosen in the listbox)
controlSlider(ALLEEG(get(h.eventlistbox, 'value')), 1, h);

% draw the data (event that was chosen in the listbox)
drawEpochData(get(h.eventlistbox, 'value'), 1, h);

function savebutton_callback(~, ~, h)
% callback-function for the save-button
% saves desired variables to a file the user specifies

currentpath = getappdata(h.eegtool, 'currentpath');
setid = getappdata(h.eegtool, 'setid');

if isempty(getappdata(h.eegtool, 'EEG'))
    % if only epoched data, remove the mat-option
    types = {'*.set', 'EEGLAB set-files (.set)'};
else
    types = {'*.mat','MAT-files with EEGDATA struct (.mat)';'*.set', 'EEGLAB set-files (.set)'};
end


[filename, dpath] = uiputfile(types, 'Select filename', [currentpath setid(1:end-4)]);

% if no file selected
if filename == 0
    return;
end

setappdata(h.eegtool, 'currentpath', dpath);

switch filename(end-2:end)

    case 'mat'
        % matlab file -> save EEGDATA
        setid = getappdata(h.eegtool, 'setid');
        EEG = getappdata(h.eegtool, 'EEG');
        event_validity = getappdata(h.eegtool, 'event_validity');
        urevent_validity = getappdata(h.eegtool, 'urevent_validity');
        ALLEEG = getappdata(h.eegtool, 'ALLEEG');
        removed_epochs = getappdata(h.eegtool, 'removed_epochs');

        % if video-object is available-> save video
        if checkVideo(h)
           eegvideo = getappdata(h.eegtool, 'eegvideo');
            for i=1:length(eegvideo)
                vinfo(i) = eegvideo(i).giveInformation();
            end
            saveMatFile([dpath filesep filename], setid, EEG, ALLEEG, event_validity, urevent_validity, removed_epochs, vinfo);
        else
            saveMatFile([dpath filesep filename], setid, EEG, ALLEEG, event_validity, urevent_validity, removed_epochs);
        end
        
    case 'set'
        %eeglab-file -> form and save eeglab file
        ALLEEG = getappdata(h.eegtool, 'ALLEEG');
        event_validity = getappdata(h.eegtool, 'event_validity');
        urevent_validity = getappdata(h.eegtool, 'urevent_validity');

        % for each stimulus-type
        for i=1:length(ALLEEG)
            saveSet(dpath, filename, ALLEEG(i), event_validity(ALLEEG(i).setname), urevent_validity(ALLEEG(i).setname));
		end
end


function eventlistbox_callback(hObject, ~, h)
% callback-function for the event-listbox

ALLEEG = getappdata(h.eegtool, 'ALLEEG');

nevent = get(hObject, 'value');
drawEpochData(nevent, 1, h);
controlSlider(ALLEEG(nevent), 1, h);


function rmepochbutton_callback(~, ~, h)

nevent = get(h.eventlistbox, 'value');
nepoch = round(get(h.timeslider,'Value'));

ALLEEG = getappdata(h.eegtool, 'ALLEEG');
event_validity = getappdata(h.eegtool, 'event_validity');
removed_epochs = getappdata(h.eegtool, 'removed_epochs');

% how many epochs left?
if length(ALLEEG(nevent).epoch) == 1
	% if only one epoch (EEG-struct different) left
	% -> remove the whole epoch
	
	% video operation
	if checkVideo(h)
		eegvideo = getappdata(h.eegtool, 'eegvideo');
		eegvideo.removeStimulus(nevent);
	end
	
	% event_validity operation 
	event_validity.remove(ALLEEG(nevent).setname);
	%setappdata(h.eegtool, 'event_validity', event_validity);
	
	removed_epoch = ALLEEG(nevent).epoch(nepoch).urepoch;
	removed_epochs(ALLEEG(nevent).setname) = [removed_epochs(ALLEEG(nevent).setname) removed_epoch];
	ALLEEG(nevent) = [];
	setappdata(h.eegtool, 'ALLEEG', ALLEEG);
	
	% if this was the last epoch -> continuous mode
	if isempty(ALLEEG)
		switchContinuous(h);
		helpdlg('All epochs removed -> switching back to continuous mode.');
		return;
	end
	
	drawEpochData(1, 1, h);
	controlSlider(ALLEEG(1), 1, h);
	set(h.eventlistbox, 'String', generateEventIds(ALLEEG));
	set(h.eventlistbox, 'Value', 1);
	
else 
	% more than 1 epochs left
	% remove the selected epoch
	removed_epoch = ALLEEG(nevent).epoch(nepoch).urepoch;

	setname = ALLEEG(nevent).setname;
	[ALLEEG(nevent), ev_val] = removeEpoch(ALLEEG(nevent), event_validity(setname), nepoch);

	if isempty(ev_val)
		event_validity.remove(setname);
	else
		event_validity(setname) = ev_val;
	end

	% add mark for the epochs removed by hand for informational (further
	% scripting) or statistics reasons
	removed_epochs(ALLEEG(nevent).setname) = [removed_epochs(ALLEEG(nevent).setname) removed_epoch];
	% setappdata(h.eegtool, 'removed_epochs', removed_epochs); <- not needed
	% because only a handle

	setappdata(h.eegtool, 'ALLEEG', ALLEEG);
	% setappdata(h.eegtool, 'event_validity', event_validity); <- not needed
	% because only a handle

	% if the user removes epoch number one, still number one epoch drawn,
	% otherwise next epoch:
	
	if nepoch == 1
		% epoch number one removed
		drawEpochData(nevent, 1, h);
		controlSlider(ALLEEG(nevent), 1, h);
	elseif nepoch == length(ALLEEG(nevent).epoch)+1
		% last epoch removed
		drawEpochData(nevent, nepoch-1, h);
		controlSlider(ALLEEG(nevent), nepoch-1, h);
	else		
		% some other epoch removed
		drawEpochData(nevent, nepoch, h);
		controlSlider(ALLEEG(nevent), nepoch, h);
	end
end


function filtbutton_callback(~, ~, h)
% perform the filtering for continuous data and replace the continuos data
% in the memory with filtered data

hEegtool = h.eegtool;

time = round(get(h.timeslider, 'Value'));
nevent = get(h.eventlistbox, 'value');
winlen = str2num(get(h.winlenedit, 'String'))/1000;

if isappdata(h.eegtool, 'ALLEEG')
    % if epoched EEG is present -> filter that byt no continuous
    ALLEEG = getappdata(h.eegtool, 'ALLEEG');
    for j=1:length(ALLEEG)
        EEG = ALLEEG(j);
        filtered_EEG(j) = pop_eegfilt(EEG);
    end
    setappdata(hEegtool, 'ALLEEG', filtered_EEG);
    
    drawEpochData(nevent, time, h);
    
elseif isappdata(h.eegtool, 'EEG')
    % only continuous EEG [RECOMMENDED]
    EEG = getappdata(h.eegtool, 'EEG');
    filtered_EEG = pop_eegfilt(EEG);
    setappdata(hEegtool, 'EEG', filtered_EEG);

    drawContData(time, winlen, h);
end


function rerefbutton_callback(~, ~, h)
% perform rereferencing and show results

nevent = get(h.eventlistbox, 'value');
nepoch = round(get(h.timeslider,'Value'));


% Gui to parse baseline values
prompt = {'Re-reference data to channels (empty for average-reference)','Channels to exclude from re-reference.'};
dlg_title = 'Re-reference';
num_lines = 1;
def = {'', ''};
answer = inputdlg(prompt,dlg_title,num_lines,def);

% if answer was empty first condition to be evaluated: did user press
% quit?
if (isempty(answer))
   return; 
end

ref = str2num(answer{1});
excludechan = str2num(answer{2});

ALLEEG = getappdata(h.eegtool, 'ALLEEG');

% rereference all epoched datasets

for i=1:length(ALLEEG)
    ALLEEG1(i) = reReference(ALLEEG(i), ref, excludechan); % v1.21 -> can now handle events with one epoch only
%    ALLEEG1(i) = pop_reref(ALLEEG(i), ref, 'exclude', excludechan);
    disp(['Excluding channels: ' num2str(excludechan) '.']);
end

% save rereferenced on top of old dataset ALLEEG
setappdata(h.eegtool, 'ALLEEG', ALLEEG1);

% Draw
drawEpochData(nevent, nepoch, h);


function clearDatastructs(h)
% clears the necessary datastructs

if isappdata(h.eegtool, 'setid')
    rmappdata(h.eegtool, 'setid');
end 

if isappdata(h.eegtool, 'EEG')
    rmappdata(h.eegtool, 'EEG');
end 

if isappdata(h.eegtool, 'ALLEEG')
    rmappdata(h.eegtool, 'ALLEEG');
end
    
clear;
    

function clearFields(h)
% clears the informative fields to zero-state

% set informative fields
set(h.pointedit, 'String', '-');
set(h.epochlimtext, 'string', '');


function removeAxes(h)
% deletes the handles of the axes components of the electrodes 

haxes = getappdata(h.eegtool, 'haxes');

% if there exists no handles for the electrode axes, return
if (isempty(haxes))
   return; 
end

row = size(haxes,2);

for i=1:row
    delete(haxes(i));
end

rmappdata(h.eegtool, 'haxes');
 
% remove the video
if checkVideo(h)   
    eegvideo = getappdata(h.eegtool, 'eegvideo');
    delete(eegvideo);
    rmappdata(h.eegtool, 'eegvideo');
end


function drawContData(starttime, winlen, h)
% fills all the axes objects in the head (continuous)
% parameters: 
% starttime    = time to start the plot in seconds  
% winlen       = length of the window in seconds 
% h            = handles data-struct 

EEG = getappdata(h.eegtool, 'EEG');
haxes = getappdata(h.eegtool, 'haxes');

ymin = str2num(get(h.yminedit, 'String'));
ymax = str2num(get(h.ymaxedit, 'String'));

xmin = round(starttime * EEG.srate) +1; %somehow comes non-integer, added round
xmax = xmin + winlen*EEG.srate;

x_axis = (xmin:xmax)./EEG.srate;

axlimits = [xmin/EEG.srate xmax/EEG.srate ymin ymax];

row = size(haxes, 2);

for i=1:row
    y_axis = EEG.data(i, xmin:xmax);

    % normalize y-axis
    y_axis = y_axis-y_axis(1);
    set(haxes(i), 'Color', 'white', 'xcolor', 'white', 'ycolor', 'white');
    set(h.eegtool, 'currentaxes', haxes(i));
    set(0, 'currentfigure', h.eegtool);
    hold on;
    cla;

    % plot continuous EEG for this channel
    plot(haxes(i), x_axis, y_axis, 'color', [0.1725 0.4980 0.7216]);

    % line corresponding the x-axis
    if get(h.dispxaxis, 'Value')
		line( [xmin/EEG.srate xmax/EEG.srate], [0 0], 'color', 'black');
	end
	
    % form the channel identifiers (if the user wants numbering of
    % channel of not)
    if get(h.dispchanedit, 'value')
        chanlabels = [num2str(i) '/' EEG.chanlocs(i).labels];
    else
        chanlabels = EEG.chanlocs(i).labels;
    end

    % put channel name text to the upper right corner
    text((xmax)/EEG.srate, ymax-0.1*(ymax-ymin), chanlabels, ...
                 'fontunits', 'normalized', 'fontsize', 0.25, 'horizontalalignment', 'right');

    %set scale
    axis(haxes(i), axlimits);
    %set(haxes(i), 'ButtonDownFcn', {});

    % set buttondownfcn's
    set(haxes(i), 'ButtonDownFcn', {@contClick});
    set(get(haxes(i), 'children'), 'ButtonDownFcn', {@contClick});

    hold off;
end


function contClick(~,~)
%catch mouseclick from continuous data and if normal -> zoom

% what kind of click was performed?
clicktype = get(gcf, 'SelectionType');
    
if strcmp(clicktype, 'normal')
    setid = getappdata(gcf, 'setid');

    identifier_text = ['File: ' setid ' continuous EEG'];
    zoomAxes(gca, identifier_text);
end


function drawEpochData(nstim, nepoch, h)
% fills all the axes objects in the head 
% parameters are: 
% nstim = number of stimulus 
% nepoch = number of epoch inside stimulus
% h = handle structure of the gui

ALLEEG = getappdata(h.eegtool, 'ALLEEG');
event_validity = getappdata(h.eegtool, 'event_validity');
haxes = getappdata(h.eegtool, 'haxes');

xmin = ALLEEG(nstim).xmin;
xmax = ALLEEG(nstim).xmax;

ymin = str2num(get(h.yminedit, 'String'));
ymax = str2num(get(h.ymaxedit, 'String'));

% generate axis limits
axlimits = [xmin xmax ymin ymax];

% form x axis
x_axis = ALLEEG(nstim).times/1000;

for i=1:ALLEEG(nstim).nbchan
    
    y_axis = ALLEEG(nstim).data(i, :, nepoch);

    set(h.eegtool, 'currentaxes', haxes(i));
    hold on;
    cla;
    
    plot(haxes(i), x_axis, y_axis, 'color', [0.1725 0.4980 0.7216]);

	ev_val = event_validity(ALLEEG(nstim).setname);
    if (ev_val(i, nepoch) == 0)
        %set white bg
        set(haxes(i), 'Color', 'white', 'xcolor', 'white', 'ycolor', 'white');
	elseif (ev_val(i, nepoch) == 9)
        %events have been interpolated, make background yellow
        set(haxes(i), 'Color', [0.9294 0.9725 0.6941], 'xcolor', ...
            [0.9294 0.9725 0.6941], 'ycolor', [0.9294 0.9725 0.6941]);
    else
        % alter background color
        set(haxes(i), 'Color', [0.9922 0.8000 0.7608], 'xcolor', ... 
            [0.9922 0.8000 0.7608], 'ycolor', [0.9922 0.8000 0.7608]);
    end

    % draw line in the event-location and x-axis
    line( [0 0], [ymin ymax], 'color', 'black', 'linestyle', ':');
	
	if get(h.dispxaxis, 'Value')
		line([xmin xmax], [0 0], 'color', 'black');
	end
	
    % form the channel identifiers (if the user wants numbering of
    % channel of not)
    if get(h.dispchanedit, 'value')
        chanlabels = [num2str(i) '/' ALLEEG(nstim).chanlocs(i).labels];
    else
        chanlabels = ALLEEG(nstim).chanlocs(i).labels;
        %chanlabels = ALLEEG(nstim).urchanlocs(i).labels;
    end

    % put channel name text to the upper right corner
    text(xmax, ymax-0.1*(ymax-ymin), chanlabels, ...
        'fontunits', 'normalized', 'fontsize', 0.20, 'horizontalalignment', 'right');

    % set buttondownfcn's
    set(haxes(i), 'ButtonDownFcn', {@axesclick, i, nepoch, nstim});
    set(get(haxes(i), 'children'), 'ButtonDownFcn', {@axesclick, i, nepoch, nstim});

    axis(haxes(i), axlimits);
    hold off;
end

% truth value to validate if video-object is available

if checkVideo(h)
    eegvideo = getappdata(h.eegtool, 'eegvideo');
    % Jump to UREPOCH (original epoch number) in the video
    for i=1:length(eegvideo)
        eegvideo(i).moveToEpoch(nstim, ALLEEG(nstim).epoch(nepoch).urepoch);
    end
end
    
     
function axesclick(~,~, channel, nepoch, nevent)
% cathces the mouse click and performs different actions for different type
% of clicks (normal, open, alt, extended)

% what kind of click was performed?
clicktype = get(gcf, 'SelectionType');


% was control pressed?

if strcmp(clicktype, 'normal')
    %plots the clicked plot on bigger screen
    setid = getappdata(gcf, 'setid');
    ALLEEG = getappdata(gcf, 'ALLEEG');
    
    identifier_text = ['File: ' setid ' event: ' ALLEEG(nevent).setname ' epoch: ' num2str(ALLEEG(nevent).epoch(nepoch).urepoch)];
    zoomAxes(gca, identifier_text);

elseif strcmp(clicktype, 'alt')
    %alternates between error and non-error

	ALLEEG = getappdata(gcf, 'ALLEEG');
	event_validity = getappdata(gcf, 'event_validity');
	
	ev_val = event_validity(ALLEEG(nevent).setname);
	

    if (ev_val(channel, nepoch) == 9)
        % event has been interpolated => it cannot be changed to good
        % anymore *DO NOTHING*

	elseif (~ev_val(channel, nepoch))
        % mark the epoch as bad

        set(gca, 'Color', [0.9922 0.8000 0.7608], 'xcolor', ...
            [0.9922 0.8000 0.7608], 'ycolor', [0.9922 0.8000 0.7608]);

        % if control pressed, do the same to all events this channel
        if getappdata(gcf, 'iscontrolpressed')
            %event_validity{nevent}(channel, :) = 2;
            
            % for each stimulus type, mark the channel bad
			evkeys = event_validity.keys;
            for i=1:length(evkeys)
				ev_val = event_validity(evkeys{i});
                ev_val(channel, ev_val(channel, :)~=9) = 2;
				event_validity(evkeys{i}) = ev_val;
            end
        else
            ev_val(channel, nepoch) = 2;
			event_validity(ALLEEG(nevent).setname) = ev_val;
        end

    else
        % uncheck error-marked epoch
        set(gca, 'Color', 'white', 'xcolor', 'white', 'ycolor', 'white');

        % if control pressed, do the same to all events this channel
        if getappdata(gcf, 'iscontrolpressed')
			
			evkeys = event_validity.keys;
            for i=1:length(evkeys)
				ev_val = event_validity(evkeys{i});
                ev_val(channel, ev_val(channel, :)~=9) = 0;
				event_validity(evkeys{i}) = ev_val;
            end
			
        else
            ev_val(channel, nepoch) = 0;
			event_validity(ALLEEG(nevent).setname) = ev_val;
		end
    end
    %setappdata(gcf, 'event_validity', event_validity);
end


function moveSelection(position, h)
% this function is beign called when the user wants to move to a certain point in the data. 

nevent = get(h.eventlistbox, 'value');

%return if no EEG loaded (EEG is always available when there is data, ALLEEG
%only when epochs are extracted)
if ~(isappdata(h.eegtool, 'EEG') || isappdata(h.eegtool, 'ALLEEG'))
    return;
end

winlen = str2num(get(h.winlenedit, 'String'))/1000;

if (~isappdata(h.eegtool, 'ALLEEG'))
    % the continuous mode

    % round position to some datapoint
    time = position;

    % draw the EEG from time sliderpoint -> winlen
    drawContData(time, winlen, h);

    %set informative field
    set(h.pointedit, 'String', num2str(time));
else
    % epoched mode

    ALLEEG = getappdata(h.eegtool, 'ALLEEG');

    nepoch = round(position);

    % draw epoched data ( get the evet which user has selected from the
    % listbox)
    drawEpochData(nevent, nepoch, h);

    %set informative fields
    set(h.pointedit, 'String', num2str(ALLEEG(nevent).epoch(nepoch).urepoch));
end

function switchEpochedOnly(h)

controlEpochButtons(h, 'On');

set(h.contitem, 'checked', 'Off');
set(h.contitem, 'enable', 'Off');



function switchContinuous(h)
% Function to call when the program wants to switch to continuous mode.
% Performs actions to start continuous data mode and draws the data in cont
% mode starting at time 0.

%set buttons to correct state
controlEpochButtons(h, 'Off');

% get window length of the continuous data drawing
winlen = str2num(get(h.winlenedit, 'String'))/1000;

% clear the epoched dataset out of memory

if isappdata(h.eegtool, 'ALLEEG')
    rmappdata(h.eegtool, 'ALLEEG');
end
if isappdata(h.eegtool, 'event_validity')
    rmappdata(h.eegtool, 'event_validity');
end
if isappdata(h.eegtool, 'urevent_validity')
    rmappdata(h.eegtool, 'urevent_validity');
end 
if isappdata(h.eegtool, 'removed_epochs')
    rmappdata(h.eegtool, 'removed_epochs');
end

EEG = getappdata(h.eegtool, 'EEG');

% set slider xmin->xmax
set(h.timeslider, 'Visible', 'On');
set(h.timeslider, 'Value', EEG.xmin);
set(h.timeslider, 'Max', EEG.xmax-winlen);
set(h.timeslider, 'Min', EEG.xmin);
set(h.epochlimtext, 'string', 'Continuous');

% make slider steps winlen and 5*winlen
set(h.timeslider, 'SliderStep', [winlen/(EEG.xmax-winlen-EEG.xmin) 5*winlen/(EEG.xmax-winlen-EEG.xmin)]);

% draw data from point 0
drawContData(0, winlen, h);

set(h.pointedit, 'String', '0');

% if video loaded
if checkVideo(h)
    eegvideo = getappdata(h.eegtool, 'eegvideo');
    % Jump to UREPOCH (original epoch number) in the video
    for i=1:length(eegvideo)
        eegvideo(i).removeEpoching();
    end
end


function controlSlider(EEG, sliderlocation, h)
% set slider first_event_number->last_event_number

% check if there are more epochs than one
if EEG.trials == 0
	errordlg('There is 0 epochs');
	return;
elseif EEG.trials == 1
	% if only one epoch, slider -> off and return
	set(h.timeslider, 'Value', 1, 'Visible', 'Off');
	set(h.pointedit, 'String', num2str(EEG.epoch(1).urepoch));
	return;
else
	% if more than one epoch, slider -> on
	set(h.timeslider, 'Visible', 'On');
end

set(h.timeslider, 'Value', sliderlocation);
set(h.pointedit, 'String', num2str(EEG.epoch(sliderlocation).urepoch));

set(h.timeslider, 'Max', EEG.trials);
set(h.timeslider, 'Min', 1);

% make slider steps 1 and 10
set(h.timeslider, 'SliderStep', [1/(length(EEG.epoch)-1) 1/(length(EEG.epoch)-1)*2]);
    
    
function controlEpochButtons(h, state)
% changes the state of the epoch-related buttons 
% h = handles struct
% state = 'On' / 'Off'

set(h.detrenditem, 'Enable', state);
set(h.erroritem, 'Enable', state);
set(h.rejectepochsitem, 'Enable', state);
set(h.interpitem, 'Enable', state);
set(h.saveitem, 'Enable', state);
set(h.rmepochbutton, 'Enable', state);
set(h.rerefitem, 'Enable', state);
set(h.rectitem, 'Enable', state);
set(h.baselinecitem, 'Enable', state);

if strcmp(state, 'Off')
    % empty the listbox for events
    set(h.eventlistbox, 'value', 1);
    set(h.eventlistbox, 'string', {});
    
    state_negation = 'On';
    set(h.eventlistbox, 'callback', []);
else
    state_negation = 'Off';
    set(h.eventlistbox, 'callback', {@eventlistbox_callback, h});
end

% turn on epoched-button, turn off continuous-button
set(h.filtitem, 'Enable', state_negation);
set(h.epochitem, 'checked', state);
set(h.contitem, 'checked', state_negation);


function eventids = generateEventIds(ALLEEG)
% generates event id's according to the setnames on the ALLEEG-struct EEG's

if isempty(ALLEEG)
	eventids = {''};
end

for j=1:length(ALLEEG)
	eventids{j} = ALLEEG(j).setname;
end
