%============================================================================
% Function name.: find_on_and_offset
% Date..........: July 31, 2019
% Author........: Eric F Schmiele
%                 (eric.robotic@gmail.com)
% Description...:
%                 Finds and returns the indexes of on and offsets of bursts
%                 in a signal using Hilbert Transform and a reference
%                 interval within the signal.
%                    
% Parameters....: 
%                 signal...-> input signal.
%                 sampFreq.-> sampling frequency from input signal [Hz].
%                 options..-> 
%                             'T0'........-> begining of the reference
%                                            interval [ms].
%                                            Default: 0.
%                             'T1'........-> ending of the reference
%                                            interval [ms].
%                                            Default: 2000.
%                             'f_low'.....-> low frequency of the
%                                            filter [Hz].
%                                            Default: 2.
%                             'f_high'....-> high frequency of the
%                                            filter [Hz].
%                                            Default: sampFreq/2.
%                             'f_cut'.....-> cutoff frequency for the Hilbert
%                                            filter [Hz].
%                                            Default: 8.
%                             'order'.....-> order for the low and high
%                                            filters.
%                                            Default: 4.
%                             'order_env'.-> order for the Hilbert filter.
%                                            Default: 4.
%                             'nSDth'.....-> number of standard deviations to
%                                            consider for comparison with the
%                                            reference interval.
%                                            Default: 2.
%                             'min_len'...-> minimal burst length [ms].
%                                            Default: 0.
%                             'min_dist'..-> minimal distance between each
%                                            burst moment [ms].
%                                            Default: 2000.
%
% Return........:
%                 onset_index..-> position of onset of bursts within the
%                                 input signal.
%                 offset_index.-> position of offset of bursts within the
%                                 input signal.
%============================================================================

function [onset_index, offset_index] = find_on_and_offset(signal, sampFreq, varargin)

%============================================================================
%% Default inputs
varname = {'T0' 'T1' 'f_low' 'f_high' 'f_cut' 'order' 'order_env' 'nSDth' 'min_len' 'min_dist'};
value_vect = [0 2000 2 ((sampFreq / 2) - 1) 8 4 4 2 0 2000];
%============================================================================
%% Manage optional inputs
if nargin > 2
    i = 1;
    onset_index = [];
    offset_index = [];
    while i <= length(varargin)
        found = 0;
        for j = 1:length(varname)
            if strcmpi(cell2mat(varargin(i)), cell2mat(varname(j)))
                found = 1;
                i = i + 1;
                if isnumeric(cell2mat(varargin(i)))
                    value_vect(j) = cell2mat(varargin(i));
                else
                    disp('Invalid option value');
                    return;
                end
                break;
            end
        end
        if ~found
            disp('Invalid option');
            return;
        end
        i = i + 1;
    end
end
%============================================================================
%% Initialize input variables
T0 = value_vect(1);
T1 = value_vect(2);
f_low = value_vect(3);
f_high = value_vect(4);
f_cut = value_vect(5);
order = value_vect(6);
order_env = value_vect(7);
nSDth = value_vect(8);
min_len = value_vect(9);
min_dist = value_vect(10);
%============================================================================
%% Filters and Hilbert Transform
%prepare signal and reference interval
signal = signal - mean(signal);
x1 = 1 + round((T0 / 1000) * sampFreq);
x2 = 1 + round((T1 / 1000) * sampFreq);

%zero-phase digital butterworth filter (zero-phase distortion)
signalFilt = filter_no_dist(signal, order, [f_low f_high], sampFreq, 'bandpass');

%Hilbert transform
envHilb = abs(hilbert(signalFilt));
[envFilt] = filter_no_dist(envHilb, order_env, f_cut, sampFreq, 'low');
%============================================================================
%% Find burst start and end
%threshold from the reference interval
th = mean(envFilt(x1:x2)) + nSDth * std(envFilt(x1:x2));
minTh = max(envFilt) / 1000;
if(th < minTh)
    th = minTh;
end;

%localize points bellow the reference threshold
thVector = envFilt > th;
thVector(x1:x2) = 0; %ignor any detection from the reference interval (from x1 to x2)

%localize onset and offset points
ind_start = [0 (diff(thVector) > 0)] > 0;
ind_end = [0 (diff(thVector) < 0)] > 0;
ind_start = find(ind_start);
ind_end = find(ind_end);

%verify if there are still detected points
if(isempty(ind_start) || isempty(ind_end))
    audio_begin_index = [];
    return;
end
%============================================================================
%% Treatments
%verify if there are ends before starts
if ind_end(1) < ind_start(1)  
    ind_end(1) = []; % remove the first end
end

%verify if the number of starts and ends are the same
if length(ind_start) > length(ind_end)
    ind_start(length(ind_start)) = []; %remove the last element
end

%verify if there are still detected points
if(isempty(ind_start) || isempty(ind_end))
    audio_begin_index = [];
    return;
end

%organize burst start and end together correctly ===> [current_start current_end]
pairs = [];

%verify if the burst has the minimal length
%minimal burst length ===> ind_end(i) - ind_start(i) >= nptosMin
nptosMin = min_len * sampFreq;
npairs = length(ind_start);
for i = 1:npairs
    if (ind_end(i) - ind_start(i)) >= nptosMin
        pairs = [pairs; [ind_start(i) ind_end(i)]]; 
    end
end

%verify distance between burst starts
min_dist = 1 + round((min_dist / 1000) * sampFreq);
i = 1;
while (i < size(pairs, 1))
    first = pairs(i,1);
    second = pairs(i + 1,1);
    while (second - first < min_dist)
        %if the distance is less than minimum the second burst start is disconsidered
        pairs(i,2) = pairs(i + 1,2);
        pairs(i+1,:) = [];
        if (i >= size(pairs, 1))
            break;
        end
        second = pairs(i + 1,1);
    end
    i = i + 1;
end
%============================================================================
%% Prepare outputs
onset_index = pairs(:,1);
offset_index = pairs(:,2);
%============================================================================
%% Plot
% a = zeros(size(sEmg));
% b = zeros(size(sEmg));
% a(OnSetpairs(:,1)) = 1;
% b(OnSetpairs(:,2)) = 1;
% plot(sEmg);hold on;plot(a*100,'r');plot(b*100,'g');
%============================================================================

end