function erp = ERPbootsrap(grandEEG, samples, epochsSample, channel, times, color)
% synopsis function eeg = ERPbootsrap(grandEEG, samples, epochsSample, channel, times, color)
% Calulates an average bootsrapped epoch from all epochs included in
% grandEEG
%
% Parameters:
%  grandEEG    = 3D eegdata matrix dims 1,2, and 3 refer to channels, 
%                time %(samples), and epochs
%  samples     = number of bootstrap samples used in calculation
%  epochSample = number of epochs used for calculation of one sampled ERP
%  channel     = the electrode channel to be analyzed
%  times       = time axis
%  color       = plotting color
%
% Returns:
%  erp        = 3D erp-wave (ERPs by channels by time)
%

%alpha for confidence level e.g., use alpha=0.05 for 95 % confidence
%itervals
alpha = 0.05;

%number of channels in input eeg
channels = size(grandEEG,1);
%number of samples or time frames in input eeg
timeSamples = size(grandEEG,2);
%number of epochs in input eeg
epochs = size(grandEEG,3);

%initialize matrix for bootstrapped ERPs
erp = zeros(samples, channels, timeSamples);

%calculate many ERPs by resampling (bootsrapping)
for i=1:samples

    %2D matrix for storing summarized epoch (for calulating an ERP)
    sampleEEG = zeros(channels,timeSamples);

    %summarize n epochs to one evoked resonpnse (cf. ERP)
    for j=1:epochsSample
        sampleRow = round((rand * (epochs-1)) + 1 );
        sampleEEG = sampleEEG + grandEEG(:, :, sampleRow);
    end;
    %divide by number of epochs to get the average ERP    
    sampleEEG = sampleEEG ./ epochsSample;
    erp(i,:, : ) = sampleEEG;
    
end

%sort bootsamples
s_eeg = sort(erp,1);

%select the bootsampled data from one channel only
erps = reshape(s_eeg(:,channel,:),samples,timeSamples);

%calculate mean from bootstrapped ERPs.
bootERP = mean(erps,1);

%and standard deviation from bootstrapped ERPs. NOT USED FOR
%ANYTHING AT THE MOMENT...
%bootError = std(erps,1);

%regular sample ERP from all epochs calculated without resampling
ERP_mean = mean(grandEEG,3);
ERP_mean = reshape(ERP_mean(channel,:), 1, timeSamples);

%upper CI border
%percentile bootstrap. NOT IN USE!
%bootERPup = erps(fix(0.975 * samples),:); 

%Basic Bootstrap
bootERPup = 2 .* ERP_mean - erps(fix( (alpha / 2)  * samples),:);

%lower CI border
%percentile bootstrap. NOT IN USE!
%bootERPlow = erps(fix(0.025 * samples),:);

%Basic Bootstrap
bootERPlow = 2 .* ERP_mean - erps(fix( (1 - alpha / 2) * samples),:);
%plot and example ERP from example channel

p = plot(times, 2.*ERP_mean - bootERP);
set(p,'Color', color, 'LineWidth', 2);

%plot confidence intervals with plus&minus standard deviation
hold all
%plot(times, reshape(bootERP(1,channel,:),1,timeSamples) + reshape(bootError(1,channel,:),1,timeSamples) );
p = plot(times, bootERPup);
set(p,'Color', color, 'LineWidth',1)
hold all
%plot(times, reshape(bootERP(1,channel,:),1,timeSamples) - reshape(bootError(1,channel,:),1,timeSamples) );
p = plot(times, bootERPlow);
set(p,'Color', color,'LineWidth',1)

%erp = 2.*ERP_mean - bootERP;

erp = zeros(4, length(times));

erp(1,:) = times;
erp(2,:) = 2.*ERP_mean - bootERP;
erp(3,:) = bootERPup;
erp(4,:) = bootERPlow;