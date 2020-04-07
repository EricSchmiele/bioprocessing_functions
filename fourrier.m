%============================================================================
% Function name.: fourrier
% Date..........: May 8, 2019
% Author........: Eric F Schmiele
%                 (eric.robotic@gmail.com)
% Description...:
%                 Returns the fft from a given signal and its frequency
%                 range.
%                    
% Parameters....: 
%                 signal...-> input signal.
%                 sampFreq.-> sampling frequency of the input signal.
%                 opt_plot.-> optional input: plots the result (logical).
%                             Default: 0.
%
% Return........:
%                 fourrier........-> resulting fft values.
%                 frequency_range.-> frequency range of the fft values for
%                                    plotting.
%============================================================================

function [fourrier, frequency_range] = fourrier(signal, sampFreq, opt_plot)        

%============================================================================
%% Manage inputs
if nargin < 3
    opt_plot = 0;
end
%============================================================================
%% Prepare variables
len = length(signal);
nfft = 2 ^ nextpow2(len);
%============================================================================
%% Calculate fft and generate frequency vector
y = fft(signal, nfft) / len;
fourrier = 2 * abs(y(1:nfft / 2 + 1));

frequency_range = sampFreq / 2 * linspace(0, 1, nfft / 2 + 1);
%============================================================================
%% Plot result
if opt_plot
    plot(frequency_range, fourrier);
end
%============================================================================

end