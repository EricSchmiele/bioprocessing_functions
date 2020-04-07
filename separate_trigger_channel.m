%============================================================================
% Function name.: separate_trigger_channel
% Date..........: December 14, 2017
% Author........: Eric F Schmiele
%                 (eric.robotic@gmail.com)
% Description...:
%                 Takes the trigger channel out of the list of channels from
%                 the trial field and places it into a new field called
%                 trigger. It follows the same input system of fieldtrip
%                 functions.
%                    
% Parameters....: 
%                 cfg.trigchan.-> name of channel from the dataset that
%                                 should be used as trigger channel.
%                 input........-> dataset to be manipulated.
%
% Return........:
%                 output.-> dataset already manipulated.
%============================================================================

function output = separate_trigger_channel(cfg, input)

%============================================================================
%% Initialize variables
output = input;
%============================================================================
%% Separate trigger channel
trigger = {};
for i = 1:length(input.label)
	if isequal(input.label{i}, cfg.trigchan)
		for j = 1:length(input.trial)
			trigger{j} = input.trial{j}(i,:);
			output.trial{j}(i,:) = [];
		end
		trigpos = i;
		break;
	end
end
output.trigger = trigger;
%============================================================================
%% Remove label name
new_label = {};
for i = 1:length(input.label)
	if i ~= trigpos;
		new_label{end + 1} = input.label{i};
	end
end
output.label = new_label;
%============================================================================

end