function [EEG, ev_val] = removeEpoch(EEG, ev_val, rejected_epochs)
% Takes parameter ALLEEG and event_validity matrices and returns them
% without epochs specified in rejected_epochs
%
% Parameters:
%  EEG               =  eeglab EEG-dataset (epoched)
%  ev_val            =  array of event-validity data [channel epoch]
%  rejected_epochs   =  array of epochs to reject e.g. [1 2 5 78] or [3]
%
% Returns:
%  EEG               =  eeglab EEG-dataset (epoched) if all removed->
%                       return empty matrix []
%  ev_val            =  updated array of event-validity data [channel epoch]


% check if the rejected_epochs array is smaller than the epoch count for
% the event ( otherwise this would mess listboxes etc. in the gui )

if isempty(rejected_epochs)
    return;
end

if length(rejected_epochs) >= EEG.trials
   % error('All the epochs of this event type are choosed to be removed. Please re-epoch the data instead. ');
   EEG = [];
   ev_val = [];
   return;
end

%%%%%%%%%%%%%%FIX FOR THE EEGLAB BUG OF REMOVING TIME
times = EEG.times;

% if epoch count goes down to one -> eeglab removes the (needed)
% epoch-struct. We preserve it.
epochindices = 1:length(EEG.epoch);

% collect all the epochs
for i = epochindices
    epoch(i) = EEG.epoch(i);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% remove the selected epoch
[EEG, ~] = pop_selectevent(EEG, 'omitepoch', rejected_epochs);

%%%%%%%%%%%%%%%%%%%%%% fix continues %%%%
if(length(rejected_epochs) - EEG.trials == 0)
    EEG.times = times;
end

% insert the removed epoch-thing back
if isempty(EEG.epoch)
    % find the one epoch that was not in the list of rejected_epochs...
    notrej = setdiff(epochindices, rejected_epochs);
    EEG.epoch = epoch(notrej);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% update the ev_val-table to correspond to the new epoch-count
ev_val(:,rejected_epochs) = [];