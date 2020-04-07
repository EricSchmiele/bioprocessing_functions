%============================================================================
% Function name.: find_thresh
% Date..........: February 5, 2019
% Author........: Eric F Schmiele
%                 (eric.robotic@gmail.com)
% Description...:
%                 Looks for values above a certain threshold in an EEG input
%                 matrix. It then separates the epochs where these values
%                 were found and returns them and the rest in separate
%                 matrices.
%
% Parameters....: 
%                 input..-> EEG matrix (samples x channels x epochs).
%                 thresh.-> threshold value for comparison.
% Return........:
%                 output...-> remaining epochs that didn't have any values
%                             above the threshold.
%                 excluded.-> epochs that had values above the threshold.
%                 found....-> indexes of the excluded epochs acording to
%                             their order in the input matrix.
%============================================================================

function [output, excluded, found] = find_thresh(input, thresh)

%============================================================================
%% Find epochs with threshold
found = [];
for i=1:size(input, 3)
	exists = sum(sum(input(:,:,i) >= thresh));
	if exists
		found = [found; i];
	end
end
%============================================================================
%% Separate epochs
excluded = input(:,:,found);
output = input;
output(:,:,found) = [];
%============================================================================

end