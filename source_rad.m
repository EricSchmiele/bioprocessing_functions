% Function name.: source_rad
% Date..........: November 1, 2019
% Author........: Eric F Schmiele
%                 (eric.robotic@gmail.com)
% Description...:
%                 Calculates the refined average direction of the current
%                 sources considered as inside the brain. It consists of
%                 making a scalar projection of all the instant vectors of a
%                 source onto the strongest source among them. The source
%                 input should be in accordance to the source structure from
%                 fieldtrip.
%
% Parameters....: 
%                 source.-> source structure with at least the fields:
%                           inside, avg.pow and avg.mom.
% Return........:
%                 output.-> a source structure with the added field: avg.rad.
%============================================================================

function output = source_rad(source, freq_low, freq_high)

%============================================================================
%% Manage inputs
use_filter = 1;
if nargin < 3 || nargin < 2 || isempty(freq_low) || isempty(freq_high)
	use_filter = 0;
end
%============================================================================
%% Calculate RAD for each source inside the brain
calc_rad = [];
for i = 1:length(source.inside)
	if source.inside(i)
		%====================================================================
		%% Filter
		if use_filter
			source.avg.mom{i} = filter_no_dist(source.avg.mom{i}, 4, freq_high, source.fsample, 'low');
			source.avg.mom{i} = filter_no_dist(source.avg.mom{i}, 4, freq_low, source.fsample, 'high');
			source = source_power(source, 1);
		end
		%====================================================================
		%% Calculate percentage of each vect point
		powers = source.avg.pow(i,:);
		powers = powers / sum(powers);
		%====================================================================
		%% Find the 10 % strongest ones and calculate their resultant
		[sorted_powers, index] = sort(powers, 2, 'descend');
		strongest_vect = source.avg.mom{i}(:,index(1));
		percentage = sorted_powers(1);
		current = 1;
		while percentage < 0.1
			current = current + 1;
			percentage = percentage + powers(current);
			strongest_vect = strongest_vect + source.avg.mom{i}(:,index(current));
		end
		str_vect{i} = strongest_vect;
		%====================================================================
		%% Calculate RAD given the resultant strongest direction
		for j = 1:length(source.time)
			calc_rad{i}(:,j) = vectorial_projection(source.avg.mom{i}(:,j), strongest_vect);
		end
	else
		calc_rad{i} = 0;
		str_vect{i} = 0;
	end
end
%============================================================================
%% Manage outputs
output = source;
output.avg.rad = calc_rad;
output.avg.str_vect = str_vect;
%============================================================================

end