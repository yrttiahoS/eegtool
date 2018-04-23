function writeSampleRow(fid, SAMPLE, setid, stype, stimid, eventcount, opt1, opt2, opt3, opt4)
    % Writes a sample row for one file to a result-file with given parameters.
    %
    % Parameters:
    %  fid        = file identifier (handle) 
    %  SAMPLE     = vector of samples (numeric)
    %  setid      = setidentifier (string)
    %  stype      = sample type
    %  stimid     = stimulus identifier (string)
    %  eventcount = numeric
    %  opt1       = optional string 1
    %  opt2       = optional string 2
    %  opt3       = optional string 3
    %  opt4       = optional string 4


    if ~iscell(SAMPLE)
        % convert to cell-array for printing to file
        for i=1:length(SAMPLE)
            SAMPLECELL{i} = num2str(SAMPLE(i));
        end
    else
        SAMPLECELL = SAMPLE;
    end

    % line change
    fprintf(fid, '\n');

    % process desc row
    desc = sprintf( '%s,%s,%s,%s,%s,%s,%s,%s,%s,', setid, datestr(now), stimid, eventcount, stype, opt1, opt2, opt3, opt4);
    disp(['Saving sample-data for ' setid '..']);
    writeRow(fid, desc, SAMPLECELL);