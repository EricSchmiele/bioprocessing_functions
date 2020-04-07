%============================================================================
% Function name.: source_calculation
% Date..........: August 07, 2019
% Author........: Eric F Schmiele
%                 (eric.robotic@gmail.com)
% Description...:
%                 Calculates the brain's current sources of a given eeg
%                 signal in timelock analysis (ft_timelockanalysis or
%                 eeg2tlck) using the chosen technique.
%
% Parameters....:
%                 tlck......-> eeg signal in timelock analysis in the 
%                              fieldtrip format.
%                 leadfield.-> leadfield matrix that determines how each
%                              source influences each eeg channel.
%                 vol.......-> head volume used.
%                 tech_name.-> optinal input: name of the technique desired
%                              to calculate the brain current sources:
%                              'sloreta' standardized low-resolution
%                                        electromagnetic tomography;
%                              'eloreta' exact low-resolution electromagnetic
%                                        tomography;
%                              'lcmv'    linear constrained minimum variance
%                                        beamformer;
%                              'pcc'     partial cannonical correlation/
%                                        coherence;
%                              'mne'     minimum norm estimation;
%                              'rv'      scan residual variance with single
%                                        dipole;
%                              Default: 'sloreta'.
%                 lambda....-> optional input: value for the regularization
%                              parameter, if not given, the value is
%                              calculated considering the snr value if
%                              present in the tlck signal, or accoarding to
%                              the technique used in ft_sourceanalysis (check
%                              each technique: some use a fixed value and
%                              others estimate it through different methods).
%                 trial.....-> optinal input: indicates which trial should b
%                              be used in the calculation, because if the
%                              signal was generated using the eeg2tlck
%                              function it may have more than one trial; it
%                              is ignored for the case of data generated
%                              from ft_timelockanalysis.
%                              Default: 1.
% Return........:
%                 source.-> source struct with the power values and vector
%                           values from all the sources (determined by the
%                           leadfield matrix) for the time duration of the
%                           eeg signal.
%============================================================================

function source = source_calculation(tlck, leadfield, vol, tech_name, lambda, trial)

%============================================================================
% 'sloreta' lambda (default: 0 or trace)
% 'eloreta' lambda (default: 0.05)
% 'lcmv'    lambda (default: 0 or trace)
% 'pcc'     lambda (default: 0)
% 'mne'     lambda (default: estimated from snr)
% 'rv'      no lambda
%============================================================================
%% Manage inputs
if nargin < 4
	tech_name = 'sloreta';
else
	if ~sum(strcmp(tech_name,{'sloreta', 'eloreta', 'lcmv', 'pcc', 'mne', 'rv'}))
		ME = MException('MyComponent:incorrectTechniqueName', 'The chosen technique name is not supported.\nThe supported ones are:\nsloreta;\neloreta;\nlcmv;\npcc;\nmne;\nrv.');
		throw(ME);
	end
end
if nargin < 5 || isempty(lambda)
	if isfield(tlck, 'snr')
		lambda = 1/tlck.snr;
		tlck = rmfield(tlck, 'snr');
	elseif strcmp(tech_name, 'mne')
		lambda = 5;
	else
		lambda = [];
	end
end
if nargin < 6;
	trial = 1;
end
%========================================================================
%% Prepare technique parameters
technique.keepmom = 'yes';
technique.keepfilter = 'yes';
if isempty(lambda)
	technique.powmethod = 'trace';
else
	technique.powmethod = 'lambda1';
	technique.lambda = lambda;
end

cfg = [];
cfg.method = tech_name;
cfg.sourcemodel = leadfield;
cfg.headmodel = vol;
cfg.(tech_name) = technique;
%========================================================================
%% Inverse Solution and add sampling frequency
if isfield(tlck, 'trial')
	source = ft_sourceanalysis(cfg, tlck.trial{trial});
	source.fsample = tlck.trial{trial}.fsample;
else
	source = ft_sourceanalysis(cfg, tlck);
	source.fsample = tlck.fsample;
end
%========================================================================
%% Calculate pow
if strcmp(tech_name, 'eloreta') || strcmp(tech_name, 'sloreta')
	source = source_power(source, 1);
else
	source = source_power(source);
end
%============================================================================

end