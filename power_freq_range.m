%============================================================================
% Function name.: power_freq_range
% Date..........: April 3, 2018
% Author........: Eric F Schmiele
%                 (eric.robotic@gmail.com)
% Description...:
%                 Calculates the power spectral density from a signal and
%                 returns the power from a frequency interval, if the limits
%                 are not specified then it returns the total power.
%                    
% Parameters....: 
%                 signal...-> input signal.
%                 sampFreq.-> sampling frequency of the input signal [Hz].
%                 lowFreq..-> optional input: frequencies of the begining of
%                             the frequency interval from which the power
%                             will be calculated [Hz] (optional input).
%                             Default: 0.
%                 highFreq.-> optional input: frequencies of the ending of
%                             the frequency interval from which the power
%                             will be calculated [Hz] (must have the same
%                             length as lowFreq) (optional input).
%                             Default: sampFreq/2.
%
% Return........:
%                 power.......-> power calculated from the frequency
%                                interval.
%                 total_power.-> total power spectral density.
%                 f...........-> frequency vector relative to each point in
%                                total_power.
%============================================================================

function [power, total_power, f] = power_freq_range(signal, sampFreq, lowFreq, highFreq)

%============================================================================
%% Manage inputs
if nargin ~= 4
    lowFreq = 0;
    highFreq = sampFreq / 2;
end
%============================================================================
%% Calculate power spectral density
f = 0:1:sampFreq / 2;
[total_power, f] = pwelch(signal, [], [], f, sampFreq);
%============================================================================
% %% Normilize power spectral density
% total_power_norm = total_power / max(total_power);
% total_power = total_power';
%============================================================================
%% Calculate power from each frequency interval
power = [];
for i = 1:length(lowFreq)
    lowInd = f >= lowFreq(i);
    lowInd = find(lowInd, 1, 'first');
    highInd = f <= highFreq(i);
    highInd = find(highInd, 1, 'last');

    power(i) = trapz(total_power(lowInd:highInd));%trapz(total_power_norm(lowInd:highInd));
end
%============================================================================

end