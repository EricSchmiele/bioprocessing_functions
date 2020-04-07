% Function name.: generate_emd_cost
% Date..........: July 15, 2019
% Author........: Eric F Schmiele
%                 (eric.robotic@gmail.com)
% Description...:
%                 Generates the costs for the EMD calculation based on the
%                 distances between the electrodes.
%
% Parameters....: 
%                 elecpos.-> electrode positions.
% Return........:
%                 costs.-> calculated costs based on the distances of
%                          electrode positions (nElectrodes x nElectrodes).

function costs = generate_emd_cost(elecpos)

%============================================================================
%% Manage inputs
%============================================================================
%% Calculate
n_pos = size(elecpos, 1);
costs = zeros(n_pos);
for i = 1:n_pos
	for j = 1:n_pos
		aux(:,1) = elecpos(i,1) - elecpos(j,1);
		aux(:,2) = elecpos(i,2) - elecpos(j,2);
		aux(:,3) = elecpos(i,3) - elecpos(j,3);
		costs(i,j) = norm(aux);
	end
end
%============================================================================
%% Manage outputs
%============================================================================

end