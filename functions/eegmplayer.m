classdef eegmplayer < handle
% Movie player class which initializes a movie player and offers the 
% user the possibility to control the player from the movie player
% window or with object methods. The object control methods are jump to
% next epoch, jump to previous epoch and play. The epoched methods
% require epoched array of frames in each epoch to be presented.
% 
% The real-time playing property of this class might be problematic on
% some systems or codecs(?). If so, pausing the video between
% transitions (not letting it loop continuously) might help.

properties (GetAccess = public, SetAccess = private)
	figHandle;
end
   
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
properties (GetAccess = private, SetAccess = private)
	video_obj; % handle for video-object
	ispaused = 1;
	epoching; % epoching information in a cell array
	current_epoch; % limits in the moveVideo-method (for whole video: [1 end])
	first_stim_frame = NaN;
	videofilename;
end
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
methods (Access = public)

%constructor
function obj = eegmplayer(dpath, filename)

	if nargin ~= 2
		% get filename and path, load the file
		filter = {'*.mov;*.avi;*.mp4'};
		[filename, dpath] = uigetfile(filter);

	if filename == 0
		delete(obj);
		return;
		end
	end

	if ~exist([dpath filename], 'file')
		errordlg('The video file specified in the file could not be found. Video is disabled.');
		delete(obj);
		return;
	end

	% load video object
	obj.videofilename = filename;
	obj.video_obj = VideoReader([dpath filename]);

	vidHeight = obj.video_obj.Height;
	vidWidth = obj.video_obj.Width;

	% Size a figure based on the video's width and height.
	obj.figHandle = figure;
	set(obj.figHandle, 'position', [150 150 vidWidth vidHeight], 'menubar', 'none', ...
	 'numbertitle', 'off', 'name', ['Video file: ' filename], 'closerequestfcn', @obj.player_closereqf);

	% create axes
	axes('units', 'normalized', 'position', [0 0 1 1]);

	obj.current_epoch=[1 obj.video_obj.NumberOfFrames];
	obj.moveVideo(1);

	% Create the toolbar
	th = uitoolbar(obj.figHandle);

	% Add a push tool to the toolbar
	uipushtool(th,'CData', imread('graphics/player_start.png'),...
	           'TooltipString','Move one frame backward',...
	           'HandleVisibility','off', 'clickedcallback', @obj.back_callb);

	uipushtool(th,'CData',imread('graphics/player_end.png'),...
	           'TooltipString','Move one frame forward',...
	           'HandleVisibility','off', 'clickedcallback', @obj.forw_callb);

	uipushtool(th,'CData',imread('graphics/kdevelop_down.png'),...
	           'TooltipString','Jump to frame',...
	           'HandleVisibility','off', 'clickedcallback', @obj.jumpto_callb);

	uipushtool(th,'CData',imread('graphics/player_play.png'),...
	           'TooltipString','Plays',...
	           'HandleVisibility','off', 'clickedcallback', @obj.play_callb);

	uipushtool(th,'CData',imread('graphics/player_pause.png'),...
	           'TooltipString','Pause',...
	           'HandleVisibility','off', 'clickedcallback', @obj.pause_callb);

	uipushtool(th,'CData',imread('graphics/text_italic.png'),...
	           'TooltipString','Mark the first stimulus',...
	           'HandleVisibility','off', 'clickedcallback', @obj.mark_first_callb);     

	% set keypressfcn for the figure
	set(gcf,'KeyPressFcn', @obj.keypress_callb);

end

function inputEpoching(obj, arg1, arg2, arg3, arg4)
	%(obj, video_vect, eeg_srate, offset, eventids)
	% calculate the video frames in each epoch

	if nargin==3
		% epoching and first stim frame provided 
		obj.first_stim_frame = arg1;
		obj.epoching = arg2;
	else 
		video_vect = arg1;
		eeg_srate = arg2;
		offset = arg3;
        eventids = arg4;

        if isnan(obj.first_stim_frame)
			prevFig = get(0, 'Currentfigure');
			warndlg(['First stimulus not marked. Video not epoched. ' ...
			         'Please mark first stimulus and re-epoch the EEG if you want video epoching.']);
			set(0,'Currentfigure', prevFig);
			return;
        end

        all_times = [];
        all_ids = {};
		% find the first appearing stimulus
		for i=1:length(video_vect)
			first_times(i) = video_vect{i}(1,1,1);
            all_times = [all_times reshape(video_vect{i}(1,1,:), 1, length(video_vect{i}(1,1,:)))];
            all_ids = [all_ids eventids{i}];
		end

		% do calculations for the offset with video
        [times_ascending, permutation] = sort(all_times);
        
        all_ids_ordered = all_ids(permutation);
        
        for i=1:length(times_ascending)
           ordering_nums{i} = [num2str(i) ' ' all_ids_ordered{i} ];
        end
        
        [s,v] = listdlg('PromptString','Select the "first" stimulus number that was marked on the video:',...
                'SelectionMode','single', 'ListString', ordering_nums);

        first_stim_time = times_ascending(s);
            
		%first_stim_time = min(first_times);
		first_stim_in_eeg = (first_stim_time - offset * eeg_srate);
		offset_eeg_and_video_fr = obj.first_stim_frame - first_stim_in_eeg * obj.video_obj.FrameRate / eeg_srate;

		for i=1:length(video_vect)
			% video vector from eeg-frames -> video vector in video-frames
			% (including offset-corrections)
			video_vector = video_vect{i}.*(obj.video_obj.FrameRate/eeg_srate) + offset_eeg_and_video_fr;
			for k = 1:size(video_vector, 3)
				epoch{i,k} = round(video_vector(1,1,k)):round(video_vector(1,end,k));
			end

			clearvars video_vector;
		end

		obj.epoching = epoch;
	end

	obj.current_epoch = [obj.epoching{1,1}(1) obj.epoching{1,1}(end)];
end


function moveToEpoch(obj, stimnum, epochnum)

    if (isempty(obj.epoching) || isnan(obj.first_stim_frame))
        % if no epochs 
		return; %and do nothing
	else
        % pause loop
        %             waspaused = obj.ispaused;
        %             obj.pauseMovie();

        % define new epoch limits and move to a frame
        obj.current_epoch = [obj.epoching{stimnum,epochnum}(1) obj.epoching{stimnum,epochnum}(end)];
        obj.moveVideo(obj.epoching{stimnum, epochnum}(1));
        
        % start playing loop again
        %             if ~waspaused
        %                 obj.playMovie();
        %             end
    end
end

function removeEpoching(obj)
	obj.epoching=[];
	obj.current_epoch=[1 obj.video_obj.NumberOfFrames];
	obj.moveVideo(1);
end

function info = giveInformation(obj)
	info.first_stim_frame = obj.first_stim_frame;
	info.filename = obj.videofilename;
	info.epoching = obj.epoching;
end

function removeStimulus(obj, stimnumber)
	obj.epoching(stimnumber, :) = [];
end

%destructor
function delete(obj)
	obj.ispaused = 1;
	delete(obj.figHandle);
end

end


methods (Access=private)
%%%%%%%%%% Callbacks %%%%%%%%%%

function back_callb(obj, ~, ~)
	obj.moveVideo('backward');
end

function forw_callb(obj, ~, ~)
	obj.moveVideo('forward');
end

function jumpto_callb(obj, ~, ~)
	% Gui to parse values
	frame = inputdlg('Frame number','Jump to a frame',1, {num2str(obj.video_obj.userdata.frame)});

    if isempty(frame)
       return;
    end
    
	obj.moveVideo(str2num(frame{1}));
end

function play_callb(obj, ~, ~)
	obj.playMovie;
end

function pause_callb(obj, ~, ~)
	obj.pauseMovie;
end

function mark_first_callb(obj, ~, ~)
	obj.markFirst;
end

function player_closereqf(obj, ~, ~)
	% pause the playing so that no other axis or instance starts playing
	delete(obj);
end
      
function keypress_callb(obj, ~, evnt)
	
	k=evnt.Key;

	if isequal(k, 'leftarrow')
		obj.moveVideo('backward');
	elseif isequal(k, 'rightarrow')
		obj.moveVideo('forward');
	elseif isequal(k, 'uparrow')
		%selaaEventteja('eteen');
	elseif isequal(k, 'downarrow')
		%selaaEventteja('taakse');
	elseif isequal(k, 'space')
		if obj.ispaused
			obj.playMovie;
		else
			obj.pauseMovie;
		end
	elseif isequal(k, 'i')
		obj.markFirst;
	end
end
      
%%%%%%%%%% methods %%%%%%%%%%%%

function pauseMovie(obj)
	obj.ispaused = 1;
end

function playMovie(obj)
	time_between_frames = 0.07;
	
	% start playing
	obj.ispaused = 0;

	% read the property "ispaused" on every round and pause if value
	% changed to 1
	while (isvalid(obj) && ~obj.ispaused)
		a = tic;
        obj.moveVideo('forward');
		videoprocessingdelay = toc(a);
		
		% if at the last frame -> pause
		if(obj.video_obj.userdata.frame == obj.video_obj.NumberOfFrames)
			obj.ispaused = 1;
		end

		% make a slight pause to allow interruptions from other causes (think
		% it works like this)

		pausedur = time_between_frames - videoprocessingdelay;
		if pausedur > 0
			pause(pausedur);
		else
			pause(0.001);
		end
		
	end
end

function moveVideo(obj, action)
	% function to move video 
	% parameters:
	% action = number or command-string, such as 'backward' 'forward', e.g to
	% specify the action for the videoplayer. If number, jump to that frame.

	if size(action)~=1
		return;
	end

	if isnumeric(action)
		frame = action;
	else
		switch action
			case 'forward'
				frame = obj.video_obj.userdata.frame+1;
			case 'backward'
				frame = obj.video_obj.userdata.frame-1;
			otherwise
				frame = 1;
		end
	end

	% check that frame inside limits
	if frame < obj.current_epoch(1) 
		frame = obj.current_epoch(1);
	elseif frame > obj.current_epoch(2)
		frame = obj.current_epoch(2);
		if ~obj.ispaused
			frame = obj.current_epoch(1);
		end
	end

	% check that frame inside video file
	if frame < 1
		frame = 1;
	elseif frame > obj.video_obj.NumberOfFrames
%		frame = obj.video_obj.NumberOfFrames; % if this -> freeze
        frame = 1;
		if ~obj.ispaused
			frame = 1;
		end
	end

	% read the frame
	mov = read(obj.video_obj, frame);

	% jump temporarily to the videoplayer-figure
	prevFig = get(0,'Currentfigure');
	set(0,'Currentfigure', obj.figHandle);

	% draw frame
	image(mov);
	obj.video_obj.userdata.frame = frame;

	axis off;
	axis image;
	% '|Ap.Time:' num2str(frame*(1/obj.video_obj.FrameRate), 3) 

	text(obj.video_obj.Width, obj.video_obj.Height*0.98, 30, ...
	     ['Frame:' num2str(frame) '/' num2str(obj.video_obj.NumberOfFrames) ...
	     '  FPS:' num2str(obj.video_obj.FrameRate)], ...
	     'fontunits', 'normalized', 'fontsize', 0.03, 'horizontalalignment', ...
	     'right', 'color', 'white', 'BackgroundColor', 'black');

	if(frame == obj.first_stim_frame)
		text(obj.video_obj.Width, obj.video_obj.Height*0.02, 30, ... 
		     '1st stimulus marker', 'fontunits', 'normalized', 'fontsize', ...
		     0.03, 'horizontalalignment', 'right', 'color', 'white');
	end

	% return to previous figure
	set(0,'Currentfigure', prevFig);
end

function markFirst(obj)
	
	currentframe = obj.video_obj.userdata.frame;
	if (obj.first_stim_frame == currentframe)
		obj.first_stim_frame = NaN;
	else
		obj.first_stim_frame = currentframe;
	end

	obj.moveVideo(currentframe);
end


end

% classdef
end

