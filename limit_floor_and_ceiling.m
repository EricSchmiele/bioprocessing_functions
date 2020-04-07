% Function name.: limit_floor_and_ceiling
% Date..........: April 6, 2020
% Author........: Eric F Schmiele
%                 (eric.robotic@gmail.com)
% Description...:
%                 Limits the minimal and maximum limits for a given input
%                 array to be a rate of the original standard deviation.
%
% Parameters....: 
%                 input.-> Input signal;
%                 rate..-> Rate of the standard deviation to be considered
%                          for the limitations
%                          Default: 1;

function output = limit_floor_and_ceiling(input, rate)

%============================================================================
%% Manage inputs
if nargin < 2 || isempty(rate)
	rate = 1;
end
%============================================================================
%% Limit floor
floor_used = mean(input) + rate*std(input);
output = input;
output(input < floor_used) = floor_used;
%============================================================================
%% Limit ceiling
ceiling_used = max(input);
output(input > floor_used) = ceiling_used;
%============================================================================

end
