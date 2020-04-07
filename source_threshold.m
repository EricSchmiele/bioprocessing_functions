%============================================================================
% Function name.: source_threshold
% Date..........: August 19, 2019
% Author........: Eric F Schmiele
%                 (eric.robotic@gmail.com)
% Description...:
%                 Changes the information from the inside structure to
%                 contain only the sources which have the highest variance
%                 given a certain rate threshold:
%                 average_variance + rate * std_variance.
%
% Parameters....: 
%                 input_source.-> source type struct in the fieldtrip format.
%                 rate.........-> standard deviation rate to be considered
%                                 above the average to calculate the
%                                 threshold.
%                 number.......-> optional input: determines a fixed number
%                                 of sources to be considered (the most
%                                 influential among the ones found with the
%                                 rate calculation).
% Return........:
%                 output_source.-> source type struct in the fieldtrip
%                                  format.
%============================================================================

function output_source = source_threshold(input_source, rate, number)

%============================================================================
%% Manage inputs
if nargin > 2
    use_number = 1;
else
    use_number = 0;
    number = Inf;
end
%============================================================================
%% Calculate variance from power
inicial_inside_index = find(input_source.inside);
pow_all_inside = input_source.avg.pow(inicial_inside_index,:);
source_variance = var(pow_all_inside');
%============================================================================
%% Calculate threshold
mean_s = mean(source_variance);
std_s = std(source_variance);
threshold = mean_s + rate*std_s;
%============================================================================
%% Find sources of interest
index_kept = find(source_variance > threshold);
%============================================================================
%% Limit size of sources of interest
if use_number && length(index_kept) > number
    source_variance_kept = source_variance(index_kept);
    [~, index_order] = sort(source_variance_kept, 2, 'descend');
    index_kept = index_kept(index_order);
    index_kept = index_kept(1:number);
end
%============================================================================
%% Remanage according to the original number of sources
index_kept = inicial_inside_index(index_kept);
%============================================================================
%% Manage outputs
% The other information is not taken out, only the information of which
% sources are inside the brain. Therefore, any use of all sources of interest
% should be done in the form:
%                    x = output_source.avg.pow(find(output_source.inside),:);
output_source = input_source;
output_source.inside = zeros(size(input_source.inside));
output_source.inside(index_kept) = 1;
%============================================================================

end