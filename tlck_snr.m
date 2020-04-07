%============================================================================
% Function name.: tlck_snr
% Date..........: July 15, 2019
% Author........: Eric F Schmiele
%                 (eric.robotic@gmail.com)
% Description...:
%                 Calculates the Signal to Noise Ration from an EEG signal
%                 inside a timelocked analysis struct (fieldtrip format)
%                 considering the variance ratio between the signal before
%                 (noise) and after (signal of interest) the cue signal
%                 considered to be present in the 0 s time sample.
%
% Parameters....: 
%                 tlck_input.-> timelock analysis type struct in the
%                               fieldtrip format.
%                 opt_2......-> use the second option for SNR calculation:
%                               consider only a frequency interval as the 
%                               signal of interest.
%                 low_freq...-> lower bound of the frequency range of
%                               interest.
%                 high_freq..-> higher bound of the frequency range of
%                               interest.
% Return........:
%                 tlck_output.-> timelock analysis type struct in the
%                                fieldtrip format with an added field named
%                                snr with the calculated SNR given the input
%                                signal and the interval before the cue.
%============================================================================

function tlck_output = tlck_snr(tlck_input, opt_2, low_freq, high_freq)

%============================================================================
%% Manage inputs
if nargin < 2 || opt_2 ~= 1 || isempty(opt_2)
	%========================================================================
	%% Separate intervals
	zero_point = find(tlck_input.time>=0, 1);
	signal_before = tlck_input.avg(:,1:zero_point-1);
	signal_after = tlck_input.avg(:,zero_point:end);
	%========================================================================
	%% Calculate the variance of each signal interval
	var_before = var(signal_before(:));
	var_after = var(signal_after(:));
	%========================================================================
	%% Calculate the SNR
	snr = var_after / var_before;
else
	%========================================================================
	%% Calculate power densities
	for i = 1:size(tlck_input.avg, 1)
		psd_calc(i,:) = power_freq_range(tlck_input.avg, tlck_input.fsample, [0 low_freq], [tlck_input.fsample/2 high_freq]);
	end
	psd_total = sum(psd_calc(:,1));
	psd_range = sum(psd_calc(:,2));
	psd_noise = psd_total - psd_range;
	%========================================================================
	%% Calculate the SNR
	snr = psd_range / psd_noise;
end
%============================================================================
%% Manage outputs
tlck_output = tlck_input;
tlck_output.snr = snr;

end