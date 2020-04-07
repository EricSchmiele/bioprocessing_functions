% Function name.: correct_onset
% Date..........: April 6, 2020
% Author........: Eric F Schmiele
%                 (eric.robotic@gmail.com)
% Description...:
%                 Corrects the trial information found from slope analysis to
%                 adequate to a prior known trial marking as to correctly
%                 select only the trials of interest.
%
% Parameters....: 
%                 signal.-> Signal with markers delimiting the prior trial
%                           knowledge;
%                 trl....-> Trial information to be corrected.

function trl_out = correct_onset(signal, trl)

%============================================================================
%% Manage inputs
%============================================================================
%% Initialize variables
trl_out = trl;
%============================================================================
%% Determine points of slope sign change (SSC)
slope = diff(signal);
ssc = zeros(size(slope));
for i = 2:length(slope)
	aux1 = slope(i-1) > 0;
	aux2 = slope(i) > 0;
	if aux1~=aux2 || slope(i)==0
		ssc(i) = 1;
	end
end
%============================================================================
%% Find closest SSC
for i = 1:size(trl, 1)
	for j = trl(i,1)-trl(i,3):-1:1
		if ssc(j)
			trl_out(i,1) = j + trl(i,3);
			trl_out(i,2) = trl_out(i,1) + (trl(i,2) - trl(i,1));
			break;
		end
	end
end
%============================================================================

end
