% Function name.: get_emd
% Date..........: July 15, 2019
% Author........: Eric F Schmiele
%                 (eric.robotic@gmail.com)
% Description...:
%                 Calculates the Earth Mover's Distance considering two EEG
%                 signals (one real and the other calculated) and the
%                 positions of their electrodes.
%
% Parameters....: 
%                 input_real.-> real signals (nElectrodes x nSamples).
%                 input_calc.-> calculated signals (nElectrodes x nSamples).
%                 positions..-> positions of electrodes (nElectrodes x 3).
% Return........:
%                 emd_array.-> values of the Earth Mover's Distance for each
%                              sample (1 x nSamples).

function emd_array = get_emd(input_real, input_calc, positions)

%============================================================================
%% Manage inputs
if sum(size(input_real)) ~= sum(size(input_calc)) || size(input_real, 1) ~= size(positions, 1)
	disp('Input sizes are not paired.')
	return;
end
%============================================================================
%% Add needed paths
add_emd();
%============================================================================
%% Calculate distances to get the costs
costs = generate_emd_cost(positions);
%============================================================================
%% Calculate EMD
emd_array = [];
for i = 1:size(input_real, 2)
	emd_array(:,i) = emd_mex(input_real(:,i)', input_calc(:,i)', costs);
end
%============================================================================
%% Manage outputs
%============================================================================

end