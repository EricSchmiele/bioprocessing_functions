%============================================================================
% Function name.: eeg2tlck
% Date..........: May 8, 2019
% Author........: Eric F Schmiele
%                 (eric.robotic@gmail.com)
% Description...:
%                 Transforms eeg signal struct into a timelock analysis
%                 struct in order to be used in the calculation of the
%                 brain's current sources.
%
% Parameters....: 
%                 eeg.....-> eeg signal struct in the fieldtrip format.
%                 each....-> optional input: determines if each trial should
%                            be considered separately (1) or if they should
%                            be averaged alltogether (0).
%                            Default: 1.
%                 cov_int.-> optional input: time interval to be considered
%                            for the covariance calculation.
%                            Default: [-inf 0].
% Return........:
%                 tlck.-> timelock analysis in the fieldtrip format. If the
%                         separated option was chosen, then it will be a
%                         struct where each value in the trial field is the
%                         timelock analysis of that specific trial from the
%                         given eeg signal.
%============================================================================

function tlck = eeg2tlck(eeg, each, cov_int)

%============================================================================
%% Manage inputs
if nargin < 2
	each = 1;
end
if nargin < 3
	cov_int = [-inf 0];
	% it will calculate the covariance matrix on the timepoints that are
	% before the zero-time point in the trials
end
%============================================================================
%% Preprocessing (just for certainty)
cfg = [];
eeg_single_trial = ft_preprocessing(cfg, eeg);
%============================================================================
%% Configurations
cfg = [];
cfg.covariance = 'yes';
cfg.covariancewindow = cov_int;
%============================================================================
%% Timelocked analysis
if each
	for i = 1:length(eeg.trial)
		cfg.trials = i; % trial to keep
		aux = ft_timelockanalysis(cfg, eeg_single_trial);
		aux.fsample = eeg_single_trial.fsample;
		tlck.trial{i} = aux;
	end
else
	tlck = ft_timelockanalysis(cfg, eeg_single_trial);
	tlck.fsample = eeg_single_trial.fsample;
end
%============================================================================

end