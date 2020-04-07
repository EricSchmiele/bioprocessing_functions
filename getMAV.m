%============================================================================
% Function name.: getMAV
% Date..........: July 13, 2017
% Author........: Eric F Schmiele
%                 (eric.robotic@gmail.com)
% Description...:
%                 Returns the mean absolute value from a signal.
%                    
% Parameters....: 
%                 signal.-> input signal.
%
% Return........:
%                 mav.-> resulting mean absolute value.
%============================================================================

function mav = getMAV(signal)

%============================================================================
%% Calculate
mav = mean(abs(signal));% mean absolute value
%============================================================================

end