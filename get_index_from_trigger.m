%============================================================================
% Function name.: get_index_from_trigger
% Date..........: October 9, 2018
% Author........: Eric F Schmiele
%                 (eric.robotic@gmail.com)
% Description...:
%                 Finds the trigger begining or ending moments from a trigger
%                 signal.
%                    
% Parameters....: 
%                 raw_trigger.-> pure trigger input signal.
%                 begin.......-> marker: 1.-> calculates begining;
%                                        0.-> calculates ending.
%                 min_diff....-> minimum difference between two triggers
%                                [sample points].
%                 max_diff....-> maximum difference between two triggers
%                                [sample points].
%                 user........-> optional input: logical flag for showing
%                                each found trigger point for the user to
%                                averiguate weather it really is a trigger
%                                point or not.
%                                Default = 0.
%                 threshrate..-> optional input: rate of difference between
%                                the maximun and minimum raw_trigger values
%                                to be considered as a real trigger point.
%                                Default = 0.5.
%
% Return........:
%                 index.-> index from trigger begining or ending positions.
%============================================================================

function index = get_index_from_trigger(raw_trigger, begin, min_diff, max_diff, user, threshrate)

%============================================================================
%% Manage inputs
if nargin < 5
    user = 0;
    threshrate = 0.5;
elseif nargin < 6
    threshrate = 0.5;
end
%============================================================================
%% Normalize pure trigger signal
if ((max(raw_trigger) ~= 1) || (min(raw_trigger) ~= 0))
    thresh = min(raw_trigger) + ((max(raw_trigger) - min(raw_trigger))*threshrate);
    trigger = raw_trigger > thresh;
else
    trigger = raw_trigger;
end
%============================================================================
%% Find trigger begining or ending positions
if (begin == 1)
    begin_trigger = [0 diff(trigger)>0]>0;
else
    begin_trigger = [0 diff(trigger)<0]>0;
end

index_begin_trigger = find(begin_trigger);
%============================================================================
%% Distance treatment
line0 = zeros(size(raw_trigger));
t = 1:length(raw_trigger);
m = max(raw_trigger);
i = 1;
while i < length(index_begin_trigger)
    %calculate distances between triggers
    difference = index_begin_trigger(i+1) - index_begin_trigger(i);
    %verify distances according to the minimum and maximum distances
    if difference < min_diff || difference > max_diff
        every = line0;
        current = line0;
        next = line0;
        every(index_begin_trigger) = 0.5*m;
        current(index_begin_trigger(i)) = 1.2*m;
        next(index_begin_trigger(i+1)) = 1.2*m;
        if user
            %show triggers of the current difference
            S = figure();
            plot(t, raw_trigger, 'k', t, every, 'r', t, current, 'g', t, next, 'b');
            legend('raw', 'triggers', 'current', 'next');
            %user chooses which one to be eliminated
            opt = questdlg('Eliminate current?', 'Eliminate trigger', 'Yes', 'No', 'Yes');
            close(S);
        else
            opt = 'Yes';
        end
        if strcmp(opt, 'No')
            index_begin_trigger(i+1) = [];
        else
            index_begin_trigger(i) = [];
        end
        if difference > max_diff
            i = i + 1;
        end
    else
        i = i + 1;
    end
end
%============================================================================
%% Organize outputs
index = index_begin_trigger;
%============================================================================

end