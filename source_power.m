%============================================================================
% Function name.: source_power
% Date..........: September 4, 2019
% Author........: Eric F Schmiele
%                 (eric.robotic@gmail.com)
% Description...:
%                 Calculates the power of the current sources in the brain
%                 (use in case it is a simulated source).
%
% Parameters....: 
%                 input_source.-> source type struct in the fieldtrip format.
%                 force........-> optional input: forces the calculation even
%                                 if the input source already have the power
%                                 values calculated.
%                                 Default: 0.
% Return........:
%                 output_source.-> source type struct in the fieldtrip
%                                  format.
%============================================================================

function output_source = source_power(input_source, force)

%============================================================================
%% Manage inputs
if nargin < 2
    force = 0;
end
%============================================================================
%% Initialize other variables
output_source = input_source;
%============================================================================
%% Calculate power
if ~isfield(input_source.avg, 'pow') || force
	output_source.avg.pow = nan(size(input_source.pos, 1), size(input_source.time, 2));
	for i=1:size(input_source.pos, 1)
        if output_source.inside(i)
            output_source.avg.pow(i,:) = (sum(abs(input_source.avg.mom{i}).^2, 1)).^(0.5);
        end
	end
end
%============================================================================

end