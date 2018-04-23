function saveSettings( dpath, settings )
    % Saves eegtool settings to a file
    %
    % Parameters:
    %  dpath = string containing a directory where to save settings
    %  settings = cell-table [numsettings 1]

    fid = fopen([dpath filesep 'eegtool_config.txt'], 'wt');

    if ~(fid==-1)
        for i=1:length(settings)
            fprintf(fid,'%s\n', settings{i});
        end
        fclose(fid);
    end