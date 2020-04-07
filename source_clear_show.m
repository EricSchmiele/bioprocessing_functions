%============================================================================
% Function name.: source_clear_show
% Date..........: July 8, 2019
% Author........: Eric F Schmiele
%                 (eric.robotic@gmail.com)
% Description...:
%                 Clear the information which is not needed for using the
%                 function sources_in_time.
%
% Parameters....: 
%                 input_source.-> source type struct in the fieldtrip format.
%                 total_avg....-> flag for keeping all information in the 
%                                 avg struct.
%                                 Default: 0.
% Return........:
%                 output_source.-> source type struct in the fieldtrip
%                                  format.
%============================================================================

function output_source = source_clear_show(input_source, total_avg)

%============================================================================
%% Manage inputs
if nargin < 2
    total_avg = 0;
end
%============================================================================
%% Clear structs
output_source = input_source;
output_source = rmfield(output_source, 'tri');
output_source = rmfield(output_source, 'method');
output_source = rmfield(output_source, 'cfg');
if ~total_avg
    output_source.avg = rmfield(output_source.avg, 'ori');
    output_source.avg = rmfield(output_source.avg, 'mom');
end
%============================================================================

end