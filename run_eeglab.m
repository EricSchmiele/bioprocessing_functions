%============================================================================
% Function name.: run_eeglab
% Date..........: May 13, 2019
% Author........: Eric F Schmiele
%                 (eric.robotic@gmail.com)
% Description...:
%                 Adds the path for the eeglab folder to the current
%                 workspace and runs the eeglab.
%
% Parameters....: 
%                 bioprocessing_path.-> optional input: string with the path
%                                       to the BIOPROCESSING_FUNCTIONS
%                                       folder.
%                                       Default: path in the
%                                       bioprocessing_path.mat file.
%============================================================================

function run_eeglab(bioprocessing_path)

%============================================================================
%% Manage inputs
if nargin < 1
	aux = load('bioprocessing_path');
	bioprocessing_path = aux.bioprocessing_path;
end
%============================================================================
%% Add path and run eeglab
addpath(strcat(bioprocessing_path, '\eeglab14_1_1b'));
eeglab
%============================================================================
%% Refresh bioprocessing_path
save(strcat(bioprocessing_path,'bioprocessing_path'), 'bioprocessing_path');
%============================================================================

end