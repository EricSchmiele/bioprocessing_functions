%============================================================================
% Function name.: eeg_corr
% Date..........: July 15, 2019
% Author........: Eric F Schmiele
%                 (eric.robotic@gmail.com)
% Description...:
%                 Calculates the correlation between two eeg signals.
%
% Parameters....: 
%                 eeg1..-> eeg type struct in the fieldtrip format. It must
%                          have the same channels and dimensions as the
%                          other, for comparison. It can also be just a
%                          matrix with the eeg signals.
%                 eeg2..-> eeg type struct in the fieldtrip format. It must
%                          have the same channels and dimensions as the
%                          other, for comparison. It can also be just a
%                          matrix with the eeg signals.
%                 trial.-> trial to be considered for the comparison.
% Return........:
%                 corr_total.-> total correlation between the signals (mean
%                               calculation from the correlations of each
%                               channel).
%                 corr_each..-> correlations of each channels individually.
%============================================================================

function [corr_total, corr_each] = eeg_corr(eeg1, eeg2, trial)

%============================================================================
%% Manage inputs
if isfield(eeg1, 'trial')
	aux = eeg1.trial{trial};
	if isfield(aux, 'avg')
		data1 = eeg1.trial{trial}.avg;
	else
		data1 = eeg1.trial{trial};
	end
elseif isfield(eeg1, 'avg')
	data1 = eeg1.avg;
else
    data1 = eeg1;
end
if isfield(eeg2, 'trial')
	aux = eeg2.trial{trial};
	if isfield(aux, 'avg')
		data2 = eeg2.trial{trial}.avg;
    else
		data2 = eeg2.trial{trial};
    end
elseif isfield(eeg2, 'avg')
    data2 = eeg2.avg;
else
	data2 = eeg2;
end
if size(data1) ~= size(data2)
	ME = MException('MyComponent:incorrectSize', 'The sizes of data from the inputs are not equal');
	throw(ME);
end
%============================================================================
%% Correlation
for i = 1:size(data1, 1)
	r = corrcoef(data1(i,:), data2(i,:));
	corr_each(i, 1) = r(1,2);
end
corr_total = mean(corr_each);
%============================================================================

end