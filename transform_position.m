%============================================================================ 
% Function name.: transform_position
% Date..........: July 6, 2017
% Author........: Eric F Schmiele
%                 (eric.robotic@gmail.com)
% Description...:
%                 Converts a position from a sample interval to a new one
%                 considering the respective sample frequencies.
%                    
% Parameters....:
%                 previous_position.-> input position/s.
%                 previous_freq.....-> frequency from original sample
%                                      interval [Hz].
%                 new_freq..........-> frequency of the desired new sample
%                                      interval [Hz].
% Return........:
%                 new_position......-> converted position/s.
%============================================================================ 

function new_position = transform_position(previous_position, previous_freq, new_freq)

%============================================================================ 
%% Calcualte
ratio = new_freq / previous_freq;
new_position = round(previous_position * ratio);
%============================================================================ 

end