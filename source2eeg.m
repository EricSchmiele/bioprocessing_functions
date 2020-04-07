%============================================================================
% Function name.: source2eeg
% Date..........: August 8, 2019
% Author........: Eric F Schmiele
%                 (eric.robotic@gmail.com)
% Description...:
%                 Generates the signals of the EEG channels considering the
%                 given leadfield matrix and the source currents.
%
% Parameters....: 
%                 eeg_input.....-> eeg type struct in the fieldtrip format.
%                 source........-> source type struct in the fieldtrip
%                                  format.
%                 leadfield.....-> leadfield type struct in the fieldtrip
%                                  format.
%                 trial_n.......-> number of the trial that is being
%                                  considered.
%                                  Default: 1.
%                 wanted_labels.-> cell with names of the wanted labels.
%
% Return........:
%                 eeg_output.-> resulting signals for each EEG channel in the
%                               same time duration of the sources.
%============================================================================

function eeg_output = source2eeg(eeg_input, source, leadfield, trial_n, wanted_labels)

%============================================================================
%% Manage inputs
if nargin < 4 || isempty(trial_n)
    trial_n = 1;
end
if nargin < 5
    wanted_labels = [];
end
%============================================================================
%% Initialize other variables
n_electrodes = length(leadfield.label);
n_sources = length(source.pos);
n_time = length(source.time);

eeg_output = eeg_input;
%============================================================================
%% Organize wanted labels
eeg_output.label = leadfield.label;
ordem = 1:length(leadfield.label);

if ~isempty(wanted_labels)
	if ~strcmp(wanted_labels, 'all')
		n_wanted = length(wanted_labels);
		ordem = zeros(n_wanted, 1);

		for i = 1:n_wanted
			for j = 1:n_electrodes
				if strcmp(wanted_labels{i}, leadfield.label{j})
					ordem(i) = j;
					break;
				end
			end
        end
        n_electrodes = n_wanted;
		eeg_output.label = wanted_labels;
	end
end
%============================================================================
%% Generate EEG channel signals from source currents
data = zeros(n_electrodes,n_time);
for i = 1:n_sources
	if source.inside(i)
        aux = leadfield.leadfield{i}(ordem,:);
		data = data + (aux * source.avg.mom{i});
	end
end
%============================================================================
%% Organize outputs
eeg_output.trial{trial_n} = data;
eeg_output.trialinfo = trial_n;
eeg_output.sampleinfo = [1 length(source.time)];

eeg_output.time{trial_n} = source.time;
eeg_output.fsample = round(1/abs(source.time(2)-source.time(1)));
%============================================================================

end