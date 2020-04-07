%============================================================================
% Function name.: getZC
% Date..........: July 13, 2017
% Author........: Eric F Schmiele
%                 (eric.robotic@gmail.com)
% Description...:
%                 Returns the number of times that the signal crossed the
%                 horizontal line of 0 or other indicated value.
%                    
% Parameters....: 
%                 signal.....-> input signal.
%                 base_value.-> optional input: base value for the line that 
%                               will be used for the counting of crossings.
%                               Default: 0.
%
% Return........:
%                 zc.-> number of times the signal crossed the horizontal
%                       line in 0 or in the base value indicated.
%============================================================================

function zc = getZC(signal, base_value)

%============================================================================
%% Manage inputs
if nargin ~= 2
    base_value = 0;
end
%============================================================================
%% Calculate horizontal crossings
zc = 0;% zero crossing
for i = 1:(length(signal) - 1)
    if ((signal(i) > base_value) && (signal(i + 1) < base_value)) || ((signal(i) < base_value) && (signal(i + 1) > base_value))
        zc = zc + 1;
    end
end
%============================================================================

end