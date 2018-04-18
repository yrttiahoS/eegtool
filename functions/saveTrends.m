function saveTrends(EEG, identificator, output_filename)

disp(['Saving trendlines for ' identificator]);
file_existed = exist(output_filename, 'file');

% open file
fid = fopen(output_filename, 'a');

if fid == -1 
   return; 
end

% if first time, write header row
if file_existed == 0
    fprintf(fid, 'filename,condition,');

    for i = 1:length(EEG.chanlocs)
        fprintf(fid, '%s,', EEG.chanlocs(i).labels);
    end
    fprintf(fid, '\n');
end

fprintf(fid, '%s,%s,', identificator, EEG.setname);

% calculate trends for 
trends = calculateTrends(EEG);

for i = 1:length(trends)
    fprintf(fid, '%f,', trends(i));
end

fprintf(fid, '\n');
fclose(fid);



function trendvector = calculateTrends(EEG)
% Function calculates the mean of slopes of each channel throughout epochs.

val = zeros(size(EEG.data, 1), size(EEG.data, 3));

% calculate slope for each ERP 
for i = 1:size(EEG.data, 1)
    for j = 1:size(EEG.data, 3)
        a = polyfit(EEG.times, EEG.data(i, :, j), 1);
        val(i, j) = a(1);
    end
end

% calculate the mean of each channel of 
trendvector = mean(val, 2);