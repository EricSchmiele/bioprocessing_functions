%============================================================================
% Function name.: get_index_from_peaks
% Date..........: December 15, 2017
% Author........: Eric F Schmiele
%                 (eric.robotic@gmail.com)
% Description...:
%                 Finds the points of peaks from a given signal.
%                    
% Parameters....: 
%                 raw_input.-> pure input signal.
%                 min_diff..-> optional input: minimum distance between two
%                              peaks [sample points].
%                              Default: 1500.
%                 max_diff..-> optional input: maximum distance between two
%                              peaks [sample points].
%                              Default: 8500.
%
% Return........:
%                 index.-> index from peaks begining positions.
%============================================================================

function index = get_index_from_peaks(raw_input, min_diff, max_diff)

%============================================================================
%% Manage inputs
if nargin < 3
    if nargin < 2
        min_diff = 1500;
    end
    max_diff = 8500;
end
%============================================================================
%% Make valleys turn into peaks
%aux = raw_input;
%m = mean(raw_input);
%lesser = raw_input < m;
%aux(lesser) = m + (m - aux(lesser));
%============================================================================
%% Make valleys disapppear
aux = raw_input;
m = mean(raw_input);
lesser = raw_input < m;
aux(lesser) = m;
%============================================================================
%% Find peaks indexes
[~, ind] = findpeaks(aux);
%============================================================================
%% Filter repetitive occurences inside the minimum and maximum distance window
ind_line = zeros(1, length(raw_input));
ind_line(ind) = 1;
index = get_index_from_trigger(ind_line, 1, min_diff, max_diff);
%============================================================================

end