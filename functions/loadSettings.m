function [ settings ] = loadSettings(dpath)
    % Get previously saved settings from a file or default settings.
    %
    % Parameters:
    %  dpath = string containing a directory where to save settings
    %
    % Returns:
    %  settings = cell-table [numsettings 1]

    fid=fopen([dpath filesep 'eegtool_config.txt']);

    if ~(fid==-1) % file found
        alldata = textscan(fid, '%s', 'Delimiter', '\n');
        settings = alldata{1};
        fclose(fid);

    else
        settings{1} = '-500';     %epoch winmin default value
        settings{2} = '2000';     %epoch winmax default value
        settings{3} = '-500';     %baseline winmin default value
        settings{4} = '0';        %baseline winmax default value
        settings{5} = 'RMS';      %default artefact detection type
        settings{6} = '40';       %def artefact detection treshold
        settings{7} = '0';        %def artefact detection visualization on
        settings{8} = '1';        %def artefact detection overwrite on
    end