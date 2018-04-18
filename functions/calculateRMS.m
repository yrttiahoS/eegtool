function rms1 = calculateRMS(datavector)
% Function calculates root mean square for a 1-D datavector.
%
% Parameters:
%  datavector =  vector of numerical values
%
% Returns:
%  rms1       =  root mean square value.

datavector = datavector.^2;
rms1 = sqrt(sum(datavector)/length(datavector));