function [meanFFT, freq, eventcount] = calculateFFT(data, srate, wind)
    % Calculates FFT for all the events (average TFRs across the 3rd
    % dimension of the EEG matrix)
    %
    % Parameters:
    %  data       = matrix [channels datapoints events] (EEGLAB epoched 
    %               EEG-struct .data)
    %  srate      = sampling rate
    %  wind       = number, 0 = no windowing, 1 = Hann windowing
    %
    % Returns:
    %  meanFFT    = matrix [channels FFT-datapoints]
    %  eventcount = number of the events, from which the ERP was counted

    eventcount = size(data, 3);

    % EDIT: fft-calculation performed according to this matlab-tutorial 
    % http://www.mathworks.se/help/matlab/ref/fft.html

    Fs = srate;                         % Sampling frequency
    L = length(data(1,:,1));            % Length of signal
    NFFT = 2^nextpow2(L);               % Next power of 2 from length of y
    freq = Fs/2*linspace(0,1,NFFT/2+1);

    % form windowing-matrix for the multiplication (window length is the
    % amount of datapoints before zero)
    if wind == 0
        w = window(@rectwin, size(data,2));
    else if wind == 1
        w = window(@hann, size(data,2));
        end
    end

    %calc fft's
    for i=1:size(data,1)
       for j=1:size(data,3)
            y = data(i,:,j).*w';
            Y = fft(y,NFFT)/L;
            fftsignal(i,:,j) = 2*abs(Y(1:NFFT/2+1));
       end
    end

    meanFFT = mean(fftsignal, 3);