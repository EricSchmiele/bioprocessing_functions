%============================================================================
% Function name.: source_psd
% Date..........: December 18, 2018
% Author........: Eric F Schmiele
%                 (eric.robotic@gmail.com)
% Description...:
%                 Calculates the power spectral density of the current
%                 sources in the brain and returns the power from a frequency
%                 interval, if the limits are not specified then it returns
%                 the total power.
%                   
% Parameters....:
%                 input_source.-> source type struct in the fieldtrip format.
%                 sampFreq.....-> sampling frequency of the input
%                                 signal [Hz]
%                 lowFreq......-> frequency of the begining of the frequency
%                                 interval from which the power will be
%                                 calculated [Hz].
%                 highFreq.....-> frequency of the ending of the frequency
%                                 interval from which the power will be
%                                 calculated [Hz].
%                 window_size..-> optional input: size of the window [in
%                                 samples] from which the psd will be
%                                 calculated.
%                                 Default: whole length.
%                 window_step..-> optional input: step [in samples] between
%                                 each signal window.
%                                 Default: 1.
%
% Return........:
%                 output_psd.-> power calculated from the frequency interval
%                               for each source point.
%============================================================================

function output_psd = source_psd(input_source, sampFreq, lowFreq, highFreq, window_size, window_step)

%============================================================================
%% Manage inputs
if nargin < 6
    window_step = 1;
end
if nargin < 5
    window_size = length(input_source.avg.mom{1});
end
%============================================================================
%% Initialize other variables
aux = window_size;
ends = 1;
while aux <= length(input_source.avg.mom{1})
	ends = [ends aux];
	aux = aux + window_step;
end
total_windows = length(ends) - 1;
%============================================================================
%% Calculate PSD
for i = 1:length(input_source.avg.mom)
	p = [];
	for j = 1:3
		for k = 1:total_windows
			p = [p; power_freq_range(input_source.avg.mom{i}(j,ends(k):ends(k-1))), sampFreq, lowFreq, highFreq)];
		end
	end
	output_psd(i,:) = sum(p, 1);
end
%============================================================================

end