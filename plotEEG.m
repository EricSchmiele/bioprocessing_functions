%============================================================================
% Function name.: plotEEG
% Date..........: July 12, 2018
% Author........: Eric F Schmiele
%                 (eric.robotic@gmail.com)
% Description...:
%                 Plots the signals from each EEG channel in the same figure.
%                    
% Parameters....: 
%                 signal.-> EEG signal (channels x time) or
%                           (channels x time x epochs).
%                 freq...-> sampling frequency for the horizontal axis.
%                 labels.-> cell with names of each channel.
%============================================================================

function plotEEG(signal, freq, labels)

%============================================================================
%% Manage inputs
if nargin < 2
    %if range is not given a vector from 1 to the length of the EEG signal
    %is created
    freq = 1;
end

if nargin < 3
    %if the labels are not given a vector with numbers is created instead
    for i = 1:size(signal,1)
        labels(i) = {num2str(i)};
    end
end
%============================================================================
%% Plot
%prepareauxiliary variables
n_channels = size(signal, 1);
color_map = lines(n_channels);
period = 1/freq;
x = 0:period:period*(size(signal,2)-1);

s = size(labels);
if s(1) == 1
    labels = fliplr(labels);
elseif s(2) == 1
    labels = flipud(labels);
end

%calculate offset between each EEG channel so they are all presented in
%the same figure
offset = [];
for i = 1:n_channels
    offset(i) =  abs(max(signal(i,:)));
    offset(i) =  offset(i) + abs(min(signal(i,:)));
end

offset_total = 1.2 * max(offset);
line = zeros(size(signal(n_channels,:)));
ypos = [];
for i = n_channels:-1:1
    i_inv = n_channels + 1 - i;
    ypos(i_inv) = offset_total*(n_channels-i);
    
    signal_to_plot = signal(i,:) + ypos(i_inv);
    line_to_plot = line + ypos(i_inv);
    
    plot(x, line_to_plot, 'k');
    hold on;
    plot(x, signal_to_plot, 'color', color_map(i,:));
    hold on;
end

set(gca, 'Ytick', ypos, 'YtickLabel', labels);
%============================================================================

end
        