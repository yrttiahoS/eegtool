function constructEegtoolPaths(rootdir)
    % Function that constructs the Matlab-pathing required to run Eegtool-programs.
    % If errors occur in your system due to not finding certain files, edit this file!
    % Needed folders are:
    %  functions
    %  graphics
    % Additional folders are:
    %  locs (containing additional cap-files)
    %
    % Also EEGLAB-toolbox should be included in the Matlab path
    %
    % Parameters:
    %  rootdir = directory path for the main folder of eegtool (string)

    % if not deployed (might mess things up)
    if ~isdeployed

        % construct essential pathing
        addpath(rootdir);
        rootpath = rootdir;
        funpath = [rootdir filesep 'functions' filesep];
        analysepath = [rootdir filesep 'functions' filesep 'analyses' filesep];
        graphpath = [rootdir filesep 'graphics' filesep];

        if (isdir(funpath) && isdir(graphpath))
            addpath(rootpath);
            addpath(funpath);
            addpath(analysepath);
            addpath(graphpath);
        end

        % construct additional paths
        locpath = [rootdir filesep 'locs' filesep];

        if isdir(locpath)
            addpath(locpath);
        end
    end