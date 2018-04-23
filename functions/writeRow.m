function writeRow(fid, desc, row)
    % Saves a new row of values to an existing opened file. File is not closed
    % after this operation
    % format is 
    % desc row(1) row(2) ....
    %
    % Parameters: 
    %  fid       =   file identifier of open file (handle)
    %  desc      =   description that goes to the first column (string)
    %  row       =   cellvector of strings

    delimiter = ',';

    fprintf(fid, ['%s' delimiter], desc);

    for i=1:length(row)
        % print to file

        fprintf(fid, ['%s' delimiter], row{i});
    end