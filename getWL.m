%============================================================================
% Function name.: getWL
% Date..........: July 13, 2017
% Author........: Eric F Schmiele
%                 (eric.robotic@gmail.com)
% Description...:
%                 Returns the waveform length of the signal.
%                    
% Parameters....: 
%                 signal.-> input signal.
%
% Return........:
%                 wl.-> resulting waveform length.
%============================================================================

function wl = getWL(signal)

%============================================================================
%% Calculate
wl = 0;% waveform length
for i = 1:(length(signal) - 1)
    wl = wl + abs(signal(i + 1) - signal(i));
end
%============================================================================

end