%============================================================================  
% Function name.: trialfun_using_trigger_signal
% Date..........: August 29, 2019
% Author........: Eric F Schmiele
%                 (eric.robotic@gmail.com)
% Description...:
%                 Calculates the begining and ending of each trial in a
%                 dataset given a channel with trigger signals, or given the
%                 indexes of said cue signal. It can also calculate these
%                 values given an external event, granted that the following
%                 values are given: indexes of these external events; data
%                 trigger channel or data trigger indexes; external trigger
%                 channel or external trigger indexes. It follows the same
%                 input system of fieldtrip functions.
%                    
% Parameters....:
%                 cfg.trialdef.data_fsample..-> sampling frequency of the
%                                               dataset that will be
%                                               separated [Hz].
%                 cfg.trialdef.eventvalue....-> cell with vector with values
%                                               (names) for each trial, if it
%                                               has only one value: every
%                                               trial is considered from the
%                                               same event.
%                 cfg.trialdef.trigchan......-> trigger channel from the
%                                               dataset used to synchronize
%                                               the dataset signals with the
%                                               external stimulus.
%                 cfg.trialdef.trig_idx......-> trigger indexes from the
%                                               dataset used to synchronize
%                                               the dataset signals with the
%                                               external stimulus (use
%                                               instead of trigchan).
%                 cfg.trialdef.min_diff......-> optional input: minimal
%                                               difference between two
%                                               trigger signals [s].
%                                               Default: 2s.
%                 cfg.trialdef.max_diff......-> optional input: maximum
%                                               difference between two
%                                               trigger signals [s].
%                                               Default: 10s.
%                 cfg.trialdef.threshrate....-> optional input: rate of
%                                               difference between maximum
%                                               and minimum to be
%                                               considered as a trigger.
%                                               (see
%                                               get_index_from_trigger)
%                                               Default: 0.5.
%                 cfg.trialdef.prestim.......-> time to be considered before
%                                               trigger signal [s].
%                 cfg.trialdef.poststim......-> time to be considered after
%                                               trigger signal [s].
%                 cfg.trialdef.exteventindex.-> vector with indexes of the
%                                               onset points from the
%                                               external events's channel.
%                 cfg.trialdef.eventpertrig..-> optional input: number of
%                                               events that occur between
%                                               each trigger moment.
%                                               Default: 1.
%                 cfg.trialdef.exttrigchan...-> trigger channel from the
%                                               external channels used to
%                                               synchronize the external
%                                               stimulus with the dataset
%                                               signals.
%                 cfg.trialdef.exttrig_idx...-> trigger index from the
%                                               external channels used to
%                                               synchronize the external
%                                               stimulus with the dataset
%                                               signals (use instead of
%                                               exttrigchan).
%                 cfg.trialdef.ext_fsample...-> sampling frequency of
%                                               external channel [Hz].
%
% Return........:
%                 trl.......-> matrix with begining and ending indexes, and
%                              duration of each trial.
%                 event.....-> value (name) of each trial.
%                 stimindex.-> indexes of the stimulus itself, not
%                              considering the prestim interval.
%============================================================================  

function [trl, event, stimindex] = trialfun_using_trigger_signal(cfg)

%============================================================================  
%% Manage variables and inputs
trl = [];
trialdef = cfg.trialdef;
min_diff_sp = 2*trialdef.data_fsample;
if isfield(trialdef, 'min_diff')
    min_diff_sp = trialdef.min_diff*trialdef.data_fsample; %change to user given value
end
max_diff_sp = 10*trialdef.data_fsample;
if isfield(trialdef, 'max_diff')
    max_diff_sp = trialdef.max_diff*trialdef.data_fsample; %change to user given value
end
threshrate_sp = 0.5;
if isfield(trialdef, 'threshrate')
    threshrate_sp = trialdef.threshrate; %change to user given value
end
data_fsample = trialdef.data_fsample;
%============================================================================  
%% Determine dataset trigger indexes
if ~isfield(trialdef, 'trig_idx')
	dataset_trigger_indexes = get_index_from_trigger(trialdef.trigchan, 1, min_diff_sp, max_diff_sp, 1, threshrate_sp);
else
	dataset_trigger_indexes = trialdef.trig_idx;
end

%check sizes of trigger indexes found and events expected
if length(trialdef.eventvalue) ~= 1
	if length(dataset_trigger_indexes) ~= length(trialdef.eventvalue)
		ME = MException('MyComponent:incorrectSizes', 'The sizes of eventvalue and dataset found triggers are different.\nCheck the values of eventvalue, min_diff and max_diff');
		throw(ME);
	end
else
	name = trialdef.eventvalue{1};
	for i = 1:length(dataset_trigger_indexes) - 1
		trialdef.eventvalue{end + 1} = name;
	end
end
%============================================================================  
%% Synchronize external event indexes
if isfield(trialdef, 'exteventindex')
	
	%external trigger indexes
	ext_fsample = trialdef.ext_fsample;
	if ~isfield(trialdef, 'exttrig_idx')
		min_diff_sp = transform_position(min_diff_sp, data_fsample, ext_fsample);
		max_diff_sp = transform_position(max_diff_sp, data_fsample, ext_fsample);
		external_trigger_indexes = get_index_from_trigger(trialdef.exttrigchan, 0, min_diff_sp, max_diff_sp, 1, threshrate_sp);
	else
		external_trigger_indexes = trialdef.exttrig_idx;
	end

	%check sizes of trigger indexes found and the number of external events
	if ~isfield(trialdef, 'eventpertrig')
		trialdef.eventpertrig = 1;
	end
	if length(trialdef.exteventindex)/trialdef.eventpertrig ~= length(external_trigger_indexes)
		ME = MException('MyComponent:incorrectSizes', 'The sizes of external events indexes and external found triggers are different.\nCheck the values of exteventindex, eventpertrig, min_diff and max_diff');
		throw(ME);
	end

	index_diff = trialdef.exteventindex - external_trigger_indexes;
	index_diff = transform_position(index_diff, ext_fsample, data_fsample);

	if(length(dataset_trigger_indexes) ~= length(external_trigger_indexes))
		ME = MException('MyComponent:incorrectSizes', 'The sizes of external and dataset found triggers are different.\nCheck the values of min_diff and max_diff');
		throw(ME);
	end
	trial_indexes = dataset_trigger_indexes + index_diff;
else
	trial_indexes = dataset_trigger_indexes;
end
%============================================================================  
%% Calculate begining and ending indexes and value for each trial
for i = 1:length(trial_indexes)
	begsample = trial_indexes(i) - trialdef.prestim*data_fsample;
  	endsample = trial_indexes(i) + trialdef.poststim*data_fsample - 1;
  	offset = -trialdef.prestim*data_fsample;
  	%event_name = trialdef.eventvalue{1}(i); % remember the trigger (=condition) for each trial
  	trl(end + 1, :) = round([begsample endsample offset]); 
end
event = trialdef.eventvalue;
stimindex = trial_indexes;
%============================================================================  

end