%============================================================================
% Function name.: source_windowing
% Date..........: August 02, 2019
% Author........: Eric F Schmiele
%                 (eric.robotic@gmail.com)
% Description...:
%                 Downsamples the source values according to the given window
%                 step, calculating the RMS value from a number of sources
%                 according to the window size. The new time vector and
%                 sampling frequency are also updated.
%
% Parameters....: 
%                 input_source.-> source type struct in the fieldtrip format.
%                 window_size..-> size of the time windows [s] which will be
%                                 used for calculating the RMS value.
%                 window_step..-> optional input having the step between each
%                                 window [s]. If the chosen step is smaller
%                                 than the period of the signal than it
%                                 will be forced to be equal to the period
%                                 of the signal.
%                                 Default: same as window_size.
%                 show_prog....-> optional flag to show the current progress
%                                 or not.
%                                 Default: 0.
% Return........:
%                 output_source.-> source type struct in the fieldtrip
%                                  format.
%============================================================================

function output_source = source_windowing(input_source, window_size, window_step, show_prog)

%============================================================================
%% Manage inputs
window_size = round(window_size * input_source.fsample);
if nargin < 3
    window_step = window_size;
else
	window_step = round(window_step * input_source.fsample);
    if window_step < 1
        window_step = 1;
    end
end
if nargin < 4
	show_prog = 0;
end
%============================================================================
%% Initialize other variables
space = {' '};
output_source = input_source;
t_max = length(input_source.time);
used_positions = [];
n_source = length(input_source.pos);
w_avg = input_source.avg;
w_avg.pow = zeros(n_source, 1);
for i = 1:n_source
	w_avg.mom{i} = zeros(3, 1);
end
%============================================================================
%% Calculate windows
current = 1;
for ini = 1:window_step:t_max;
	if show_prog
		fprintf('Windowing time stamp %d/%d\n', ini, t_max);
	end
	fim = ini + window_size;
	if fim > t_max
		break;
	end
	for i = 1:n_source
		if input_source.inside(i)
			% w_avg.pow(i,current) = rms_internal(input_source.avg.pow(i,ini:fim));
			% w_avg.mom{i}(:,current) = rms_internal(input_source.avg.mom{i}(:,ini:fim));
			w_avg.mom{i}(:,current) = mean(input_source.avg.mom{i}(:,ini:fim), 2);
		else
			w_avg.mom{i}(:,current) = [0; 0; 0];
		end
	end
	current = current + 1;
	used_positions = [used_positions fim];
end
%============================================================================
%% Update time and frequency
if show_prog
	disp('Organizing other required variables');
end
new_time = input_source.time(used_positions);
aux = new_time(2:end) - new_time(1:(end-1));
new_freq = round(1/mean(aux));
%============================================================================
%% Manage outputs
output_source.avg = w_avg;
output_source.time = new_time;
output_source.fsample = new_freq;
output_source = source_power(output_source, 1);
if show_prog
	disp('Windowing finished.');
end
%============================================================================

end

function output = rms_internal(input)

%============================================================================
%% Initialize other variables
n = size(input, 2);
%============================================================================
%% Calculate RMS
tmp = input.^2;
tmp = sum(input, 2);
tmp = tmp / n;
output = tmp.^(0.5);
%============================================================================

end