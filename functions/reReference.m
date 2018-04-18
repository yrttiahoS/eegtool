function [ EEG2 ] = reReference(EEG, ref, excludechan)
% Passes the argument to the EEGLAB-function pop_reref
%
% Parameters :
%  EEG          = Eeglab EEG-datastruct
%  ref          = vector to pass as argument 'ref'
%  excludechan  = vector of channels to exclude from the rereference
%
% Returns :
%  EEG          =  look up

% eeglab will remove the epoch from the struct if only one :(
if length(EEG.epoch) == 1
	preserved = 1;
	epoch = EEG.epoch;
else 
	preserved = 0;
end

EEG2 = pop_reref(EEG, ref, 'exclude', excludechan);

if preserved
	EEG2.epoch = epoch;
end