%============================================================================
% Function name.: getSSC
% Date..........: July 13, 2017
% Author........: Eric F Schmiele
%                 (eric.robotic@gmail.com)
% Description...:
%                 Returns the number of times that the slope sign of the
%                 signal changed from positive to negative and vice-versa.
%                    
% Parameters....: 
%                 signal.-> input signal.
%
% Return........:
%                 ssc.-> resulting number of times that the slope sign
%                        changed.
%============================================================================

function ssc = getSSC(signal)

%============================================================================
%% Calculate
ssc = 0;% slope sign change
for i = 1:(length(signal) - 1)
    if (i~=1) && (((signal(i) < signal(i + 1)) && (signal(i) < signal(i - 1))) || ((signal(i) > signal(i + 1)) && (signal(i) > signal(i - 1))))
        ssc = ssc + 1;
    end
end
%============================================================================

end