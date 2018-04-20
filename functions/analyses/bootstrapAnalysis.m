function bootstrapAnalysis(dpath, filenames_to_analyze)
% Perform bootstrap-analysis on a dialog based approach.
% Extracting samples can be done during the dialog.
%
% Bootstrapping analyses are described in Yrttiaho, Forssman, Kaatiala, and
% Leppänen (2014)

% Parameters:
%  dpath                = path to folder where files are (string)
%  filenames_to_analyze = cell-table of filenames as strings

hwait = waitbar(0, 'Loading datafiles...');
disp('Loading datafiles...');

events = {};
grandwave = {};

for i=1:length(filenames_to_analyze)
	% avg will be i=1, so start from 2

	filename = filenames_to_analyze{i};

	% load one file
	EEG = pop_loadset(strcat(dpath, filename));

	fnames{i} = filename;
	condition{i} = EEG.setname;

	disp(['Loading file ' filename '...']);

	% find which number event is
	found = 0;
	eventnr = 0;
	for j=1:length(events)
		if strcmp(events{j}, EEG.setname)
			found = 1;
			eventnr = j;
		end
	end
	
	if ~found
		events{end+1} = condition{i};
		eventnr = length(events);
		grandwave{end+1} = [];
	end
	
	grandwave{eventnr} = cat(3, grandwave{eventnr}, EEG.data);
	
	waitbar((i)/(length(filenames_to_analyze)+1), hwait);
end

disp('Loading complete.');
waitbar((i) / (length(filenames_to_analyze)+1), hwait);
close(hwait);

% collect parameters

repeat_questions = 1;
while repeat_questions
    % choose which event types to use or if many -> combine
    [selection, ok] = listdlg('ListString', events, 'SelectionMode', 'multi', 'promptstring', ...
                              'Select the event(s) to use in the analysis:');

    if ~ok
        return;
    end

    % combine the grandwave matrix 
    cGrandwave = [];
    for i=1:length(selection)
        % combine all the grandwaves of the selected to cGrandwave
        cGrandwave = cat(3, cGrandwave, grandwave{selection(i)});
    end

    % prompt the user for parameters to the analysis
    prompt = {'Number of bootstrap samples:', 'Number of epochs', 'EEG-Channel or Channel-group'};
    def = {'1000', num2str(size(cGrandwave, 3)), '1'};
    answer = inputdlg(prompt, 'Bootstrap analysis', 1, def);

    % if answer was empty first condition to be evaluated: did user press
    % quit? second condition to be evaluated: did user press okay with empty?
    if isempty(answer)
        % repeat
    else
        repeat_questions = 0;
        if isempty(answer{1}) || isempty(answer{2}) || isempty(answer{3})
            % if boot samples was empty -> quit
            errordlg('There was an empty field -> quitting');
            return;
        end
    end
end

bootsamples = str2num(answer{1});
numerps = str2num(answer{2});
channel = str2num(answer{3});

hwait = waitbar(0, 'Calculating bootstrap...');
disp('Calculating bootstrap...');

%cGrandwave = cGrandwave(:,:, 1:epochLast);

figure;
color = 'black';
% calculate and plot bootstraps
cGrandwave = reshape(mean(cGrandwave(channel,:,:),1), 1, size(cGrandwave,2) , size(cGrandwave,3));
ERP = ERPbootsrap(cGrandwave, bootsamples, numerps, 1, EEG.times, color);
xlabel 'time(ms)';
ylabel 'U(uV)';
waitbar(1, hwait);
close(hwait);
disp('Done.');

% prompt the user for saving the bootstrap?
button = questdlg('Would you like to save bootstrap-analysis information as an csv-table?', 'Save data', 'Yes', 'No', 'Yes');

% save to csv
if strcmp(button, 'No')
	return;
end

[filename, dpath] = uiputfile('.csv');

if filename == 0
	return;
end

disp('Saving bootstrap information...');
%csvwrite([dpath filename], ERP);
fid = fopen([dpath filename], 'w');

fprintf(fid, 'sep=,\n');
for i=1:size(ERP, 1)

	for j = 1:size(ERP, 2)-1
		fprintf(fid, [num2str(ERP(i,j)) ',']);
	end
	fprintf(fid, [num2str(ERP(i,j)) '\n']);
end
fclose(fid);

disp('Done.');
