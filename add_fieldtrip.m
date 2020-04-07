%============================================================================
% Function name.: add_fieldtrip
% Date..........: May 13, 2019
% Author........: Eric F Schmiele
%                 (eric.robotic@gmail.com)
% Description...:
%                 Adds the path for the FieldTrip folder to the current
%                 workspace. It also adds the path for the default source
%                 files.
%
% Parameters....: 
%                 bioprocessing_path.-> optional input: string with the path
%                                       to the BIOPROCESSING_FUNCTIONS
%                                       folder.
%                                       Default: path in the
%                                       bioprocessing_path.mat file.
%============================================================================

function add_fieldtrip(bioprocessing_path)

%============================================================================
%% Manage inputs
if nargin < 1
	aux = load('bioprocessing_path');
	bioprocessing_path = aux.bioprocessing_path;
end
%============================================================================
%% Add path and prepare defaults
addpath(strcat(bioprocessing_path, '\fieldtrip-20190419'));
ft_defaults
%============================================================================
%% Add path for default source files
addpath(strcat(bioprocessing_path, '\Source_Files'));
%============================================================================
%% Refresh bioprocessing_path
save(strcat(bioprocessing_path,'\bioprocessing_path'), 'bioprocessing_path');
%============================================================================

end