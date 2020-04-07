%============================================================================
% Function name.: filter_no_dist
% Date..........: December 10, 2018
% Author........: Eric F Schmiele
%                 (eric.robotic@gmail.com)
% Description...:
%                 Applies a butterworth filter of any type (low-pass,
%                 high-pass, band-pass or notch) without phase distortion.
%                    
% Parameters....: 
%                 signal...-> input signal (channels x samples).
%                 order....-> filter order.
%                 cutFreq..-> cutoff frequency [Hz], must be a vector with
%                             two values in the case of bandpass or notch.
%                 sampFreq.-> sampling frequency from the input signal [Hz].
%                 filtType.-> optional input: type of the filter:
%                             'low': low pass filter;
%                             'high': high pass filter;
%                             'band'/'bandpass': band pass filter;
%                             'notch'/'stop': notch filter.
%                             Default: 'low' (if cutFreq has only one value),
%                             'bandpass' (otherwise).
%
% Return........:
%                 filtered.-> resulting filtered signal.
%============================================================================

function filtered = filter_no_dist(signal, order, cutFreq, sampFreq, filtType)

%============================================================================
%% Manage inputs
if length(cutFreq) == 2
    if nargin < 5
        filtType = 'bandpass';
    end
    %determine correct frequency order
    if cutFreq(1) > cutFreq(2)
        aux = cutFreq(1);
        cutFreq(1) = cutFreq(2);
        cutFreq(2) = aux;
    end
else
    if nargin < 5
        filtType = 'low';
    end
    %in case there are more than 2 frequency values
    aux = cutFreq(1);
    cutFreq = [];
    cutFreq = aux;
end

%determine correct filter type name
if strcmp(filtType, 'band')
    filtType = 'bandpass';
elseif strcmp(filtType, 'notch')
    filtType = 'stop';
end
%============================================================================
%% Filter
baseFreq = sampFreq / 2;
wc = cutFreq / baseFreq;
[b, a] = butter(order, wc, filtType);
filtered = zeros(size(signal));
for i = 1:size(signal, 1)
    filtered(i,:) = filtfilt(b, a, signal(i,:));
end
%============================================================================

end