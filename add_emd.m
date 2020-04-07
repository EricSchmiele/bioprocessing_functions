%============================================================================
% Function name.: add_emd
% Date..........: May 8, 2019
% Author........: Eric F Schmiele
%                 (eric.robotic@gmail.com)
% Description...:
%                 Adds the path for the earth mover's distance functions
%                 folder to the current workspace.
%
% Parameters....: 
%                 bioprocessing_path.-> optional input: string with the path
%                                       to the BIOPROCESSING_FUNCTIONS
%                                       folder.
%                                       Default: path in the
%                                       bioprocessing_path.mat file.
%============================================================================

function add_emd(bioprocessing_path)

%============================================================================
%% Manage inputs
if nargin < 1
	aux = load('bioprocessing_path');
	bioprocessing_path = aux.bioprocessing_path;
end
%============================================================================
%% Add path
addpath(strcat(bioprocessing_path, '\emd'));
%build_emd;
%============================================================================
%% Refresh bioprocessing_path
save('bioprocessing_path', 'bioprocessing_path');
%============================================================================

end