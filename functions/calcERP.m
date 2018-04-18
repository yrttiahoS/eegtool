function [ERP eventcount] = calcERP(data)
% Calculates ERPs for all the events (i.e., averages across the 3rd 
% dimension of the EEG matrix).
%
% Parameters:
%  data       = matrix [channels datapoints events]
%
% Returns:
%  ERP        = matrix [channels ERP-datapoints]
%  eventcount = number of the events, from which the ERP was counted

eventcount = size(data, 3);
ERP = mean(data, 3);