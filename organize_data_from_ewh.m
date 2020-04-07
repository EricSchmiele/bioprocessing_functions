% Function name.: organize_data_from_ewh
% Date..........: April 6, 2020
% Author........: Eric F Schmiele
%                 (eric.robotic@gmail.com)
% Description...:
%                 Organizes the data from eeg data collections during elbow,
%                 wrist and hand movements (from Ofner2017) and calculates
%                 the ESI signals from these. 
%
% Parameters....: 
%                 subject.-> Number of the subject folder to be considered
%                            Default: 1;
%                 runnum..-> Number of the trial run to be analysed
%                            Default: 1;
%                 jump_to.-> Array with steps that should be performed or not
%                            Default: all steps performed: [1 2 3 4 5]
%                            1: Raw data reading, separation and removal of
%                               NaNs
%                            2: EEG preprocessing and EOG removal
%                            3: Delimit movement beginning moments
%                            4: Transform EEG signals into timelocked
%                               analysis
%                            5: ESI calculation

function organize_data_from_ewh(subject, runnum, jump_to)

%============================================================================
%% Add needed paths
addpath('BIOPROCESSING_FUNCTIONS'); % add the full path to the BIOPROCESSING_FUNCTIONS folder
add_fieldtrip;
%============================================================================
%% Manage inputs
if nargin < 1 || isempty(subject)
	subject = 1;
end
if nargin < 2 || isempty(runnum)
	runnum = 1;
end
if nargin < 3 || isempty(jump_to)
	jump_to = [1 2 3 4 5];
end
%============================================================================
%% Load files
load('elec_aligned_icbm152_1005.mat');
load('motor_labels_ewh.mat');
%============================================================================
%% Step 1
if sum(jump_to==1)
	%========================================================================
	%% Read data file
	cfg = [];
	cfg.dataset = strcat('Dataset_elbow_wrist_hand\', num2str(subject), '\motorexecution_subject', num2str(subject), '_run', num2str(runnum), '.gdf');
	cfg.continuous = 'yes';
	all_raw = ft_preprocessing(cfg);
	%========================================================================
	%% Remove NaNs
	ini_nan = find(isnan(all_raw.trial{1}(1,:)), 1);
	all_raw.trial{1}(:,ini_nan:end) = [];
	all_raw.time{1}(:,ini_nan:end) = [];
	all_raw.sampleinfo(2) = length(all_raw.time{1});
	all_raw.hdr.nSamples = length(all_raw.time{1});
	all_raw.cfg.trl(2) = length(all_raw.time{1});
	%========================================================================
	%% Remove big spike at the begining
	% cfg = [];
	% cfg.trl = [501 164625 0];
	% cfg.event = '1';
	% all_raw = ft_redefinetrial(cfg, all_raw);
	% all_raw.sampleinfo(2) = length(all_raw.time{1});
	%========================================================================
	%% EEG
	cfg = [];
	cfg.channel = find(contains(all_raw.label, 'eeg'));
	if isempty(cfg.channel)
		cfg.channel = 1:61;
	end
	eeg_raw = ft_preprocessing(cfg, all_raw);
	eeg_raw.label = labels;
	eeg_raw.hdr.label = labels;
	eeg_raw.cfg.channel = labels;
	eeg_raw.elec = elec_aligned;
	%========================================================================
	%% EOG
	cfg.channel = find(contains(all_raw.label, 'eog'));
	eog_raw = ft_preprocessing(cfg, all_raw);
	%========================================================================
	%% Hand wrist and ewlbow
	% for subject 1
	cfg.channel = [find(strcmp(all_raw.label, 'ring_near')) find(strcmp(all_raw.label, 'GripPressure')) find(strcmp(all_raw.label, 'ProSupination')) find(strcmp(all_raw.label, 'Elbow'))];
	% for subject 2
	%cfg.channel = [find(strcmp(all_raw.label, 'ring_little')) find(strcmp(all_raw.label, 'GripPressure')) find(strcmp(all_raw.label, 'ProSupination')) find(strcmp(all_raw.label, 'Elbow'))];
	moves_raw = ft_preprocessing(cfg, all_raw);
	%========================================================================
	%% Save results
	save(strcat('raw_subject', num2str(subject), '_run', num2str(runnum)), 'all_raw', 'eeg_raw', 'eog_raw', 'moves_raw');
else
	load(strcat('raw_subject', num2str(subject), '_run', num2str(runnum), '.mat'));
end
%============================================================================
%% Clear
clear  all_raw cfg elec_aligned ini_nan labels;
%============================================================================
%% Step 2
if sum(jump_to==2)
	%========================================================================
	%% Preprocess EEG data
	cfg = [];
	% filters (lowpass 40Hz; highpass 1Hz; notch 50Hz)
	cfg.lpfilter = 'yes';
	cfg.lpfreq = 90;
	cfg.hpfilter = 'yes';
	cfg.hpfreq = 1;
	cfg.dftfilter = 'yes';
	cfg.dftfreq = [50 100];
	% baseline correction
	cfg.demean = 'yes'; % apply baseline correction
	cfg.baselinewindow  = [0 0.2]; % in seconds; remember to determine a piece of signal that is not of interest so it is capable to use it as baseline correction
	% read data and preprocess
	eeg_filt = ft_preprocessing(cfg, eeg_raw);
	%eeg_filt.trial{1} = filter_no_dist(eeg_filt.trial{1}, 4, [62 66], eeg_filt.fsample, 'notch');
	%eeg_filt.trial{1} = filter_no_dist(eeg_filt.trial{1}, 4, [98 102], eeg_filt.fsample, 'notch');
	%========================================================================
	%% Preprocess EOG data
	cfg = [];
	% filters (lowpass 10Hz; notch 50Hz)
	cfg.lpfilter = 'yes';
	cfg.lpfreq = 10;
	cfg.dftfilter = 'yes';
	cfg.dftfreq = [50 100];
	% read data and preprocess
	eog_filt = ft_preprocessing(cfg, eog_raw);
	%========================================================================
	%% Preprocess moves data
	moves_filt = ft_preprocessing(cfg, moves_raw);
	%========================================================================
	%% Remove EOG influence using ICA
	cfg = [];
	cfg.exteog = eog_filt.trial{1}(2:3,:);
	eeg_ab = remove_eog_ica(cfg, eeg_filt);
	%eeg_ab.trial{1} = filter_no_dist(eeg_ab.trial{1}, 4, [49 51], 512, 'notch');
	%========================================================================
	%% Save results
	save(strcat('filt_subject', num2str(subject), '_run', num2str(runnum)), 'eeg_ab', 'eeg_filt', 'eog_filt', 'moves_filt');
else
	load(strcat('filt_subject', num2str(subject), '_run', num2str(runnum), '.mat'));
end
%============================================================================
%% Clear
clear  cfg eeg_filt eeg_raw eog_filt eog_raw moves_raw;
%============================================================================
%% Step 3
if sum(jump_to==3)
	%========================================================================
	%% Delimit hand moments
	% hand opening
	% limit signal so only the needed information is considered 
	% for subject 1
	hand_input = limit_floor_and_ceiling(-moves_filt.trial{1}(1,:), 1.8);
	cfg = [];
	cfg.trialdef.eventvalue = {'opening'};
	cfg.trialdef.data_fsample = eeg_ab.fsample;
	cfg.trialdef.trigchan = hand_input;
	cfg.trialdef.min_diff = 5;
	cfg.trialdef.max_diff = 300;
	cfg.trialdef.prestim = 1;
	cfg.trialdef.poststim = 3;
	[hand_trl, hand_event, hand_index] = trialfun_using_trigger_signal(cfg);
	hand_trl = correct_onset(moves_filt.trial{1}(1,:), hand_trl);
	% hand closing
	% limit signal so only the needed information is considered
	a_hand_input = limit_floor_and_ceiling(moves_filt.trial{1}(4,:), 1.8);
	cfg.trialdef.eventvalue = {'closing'};
	cfg.trialdef.trigchan = a_hand_input;
	[a_trl, a_event, a_index] = trialfun_using_trigger_signal(cfg);
	a_trl = correct_onset(moves_filt.trial{1}(1,:), a_trl);
	% gather all hand information
	hand_trl = [hand_trl; a_trl];
	hand_event = [hand_event a_event];
	hand_index = [hand_index a_index];
	%========================================================================
	%% Delimit wrist moments
	% wrist pronation (?)
	% limit signal so only the needed information is considered 
	wrist_input = limit_floor_and_ceiling(-moves_filt.trial{1}(3,:), 1.8);
	cfg.trialdef.eventvalue = {'supination'};
	cfg.trialdef.trigchan = wrist_input;
	[wrist_trl, wrist_event, wrist_index] = trialfun_using_trigger_signal(cfg);
	wrist_trl = correct_onset(moves_filt.trial{1}(3,:), wrist_trl);
	% wrist supination (?)
	% limit signal so only the needed information is considered
	a_wrist_input = limit_floor_and_ceiling(moves_filt.trial{1}(3,:), 1.8);
	cfg.trialdef.eventvalue = {'pronation'};
	cfg.trialdef.trigchan = a_wrist_input;
	[a_trl, a_event, a_index] = trialfun_using_trigger_signal(cfg);
	a_trl = correct_onset(moves_filt.trial{1}(3,:), a_trl);
	% gather all wrist information
	wrist_trl = [wrist_trl; a_trl];
	wrist_event = [wrist_event a_event];
	wrist_index = [wrist_index a_index];
	%========================================================================
	%% Delimit elbow moments
	% elbow down
	% limit signal so only the needed information is considered 
	elbow_input = limit_floor_and_ceiling(-moves_filt.trial{1}(2,:), 1.8);
	cfg.trialdef.eventvalue = {'extension'};
	cfg.trialdef.trigchan = elbow_input;
	[elbow_trl, elbow_event, elbow_index] = trialfun_using_trigger_signal(cfg);
	elbow_trl = correct_onset(moves_filt.trial{1}(2,:), elbow_trl);
	% elbow up
	% limit signal so only the needed information is considered
	a_elbow_input = limit_floor_and_ceiling(moves_filt.trial{1}(2,:), 1.8);
	cfg.trialdef.eventvalue = {'flexion'};
	cfg.trialdef.trigchan = a_elbow_input;
	[a_trl, a_event, a_index] = trialfun_using_trigger_signal(cfg);
	a_trl = correct_onset(moves_filt.trial{1}(2,:), a_trl);
	% gather all elbow information
	elbow_trl = [elbow_trl; a_trl];
	elbow_event = [elbow_event a_event];
	elbow_index = [elbow_index a_index];
	%========================================================================
	%% Separate hand movement in EEG
	cfg = [];
	cfg.trl = hand_trl;
	cfg.event = hand_event;
	eeg_hand = ft_redefinetrial(cfg, eeg_ab);
	hand_trial = ft_redefinetrial(cfg, moves_filt);
	%========================================================================
	%% Separate wrist movement in EEG
	cfg = [];
	cfg.trl = wrist_trl;
	cfg.event = wrist_event;
	eeg_wrist = ft_redefinetrial(cfg, eeg_ab);
	wrist_trial = ft_redefinetrial(cfg, moves_filt);
	%========================================================================
	%% Separate elbow movement in EEG
	cfg = [];
	cfg.trl = elbow_trl;
	cfg.event = elbow_event;
	eeg_elbow = ft_redefinetrial(cfg, eeg_ab);
	elbow_trial = ft_redefinetrial(cfg, moves_filt);
	%========================================================================
	%% Save results
	save(strcat('trial_subject', num2str(subject), '_run', num2str(runnum)), 'eeg_hand', 'hand_trial', 'eeg_wrist', 'wrist_trial', 'eeg_elbow', 'elbow_trial');
else
	load(strcat('trial_subject', num2str(subject), '_run', num2str(runnum), '.mat'));
end
%============================================================================
%% Clear
clear  a_* cfg eeg_ab elbow_* event hand_* index moves_* trl wrist_*;
%============================================================================
%% Step 4
if sum(jump_to==4)
	%========================================================================
	%% Make tlck
	tlck_hand = eeg2tlck(eeg_hand);
	tlck_wrist = eeg2tlck(eeg_wrist);
	tlck_elbow = eeg2tlck(eeg_elbow);
	%========================================================================
	%% Calculate SNR
	% for i = 1:length(tlck_hand.trial)
	% 	tlck_hand.trial{i} = tlck_snr(tlck_hand.trial{i});
	% end
	%========================================================================
	%% Save results
	save(strcat('tlck_subject', num2str(subject), '_run', num2str(runnum)), 'tlck_hand', 'tlck_wrist', 'tlck_elbow');
else
	load(strcat('tlck_subject', num2str(subject), '_run', num2str(runnum), '.mat'));
end
%============================================================================
%% Clear space
clear eeg_*;
%============================================================================
%% Load other files
load('leadfield_icbm152_1005.mat');
load('vol_icbm152.mat');
%load('used_inside.mat');
%============================================================================
%% Step 5
%leadfield.inside = inside;
if sum(jump_to==5)
	%========================================================================
	%% Calculate sources and clear useless info
	source_hand = [];
	source_wrist = [];
	source_elbow = [];
	for i = 1:length(tlck_hand.trial)
		source_hand.trial{i} = source_calculation(tlck_hand.trial{i}, leadfield, vol, 'eloreta', 0);
	    source_hand.trial{i} = source_clear_show(source_hand.trial{i}, 1);
	    %source_hand.trial{i} = source_rad(source_hand.trial{i});
	end
	for i = 1:length(tlck_wrist.trial)
	    source_wrist.trial{i} = source_calculation(tlck_wrist.trial{i}, leadfield, vol, 'eloreta', 0);
	    source_wrist.trial{i} = source_clear_show(source_wrist.trial{i}, 1);
	    %source_wrist.trial{i} = source_rad(source_wrist.trial{i});
	end
	for i = 1:length(tlck_elbow.trial)
	    source_elbow.trial{i} = source_calculation(tlck_elbow.trial{i}, leadfield, vol, 'eloreta', 0);
	    source_elbow.trial{i} = source_clear_show(source_elbow.trial{i}, 1);
	    %source_elbow.trial{i} = source_rad(source_elbow.trial{i});
	end
	%========================================================================
	%% Save sources
	save(strcat('source_subject', num2str(subject), '_run', num2str(runnum)), 'source_hand', 'source_wrist', 'source_elbow', '-v7.3');
end
%============================================================================
%% Clear space
clear c* i inside m* tl* v*;
%============================================================================
%% Step 6
% if jump_to <= 6
% 	%========================================================================
% 	%% Load needed files
% 	load(strcat('trial_subject', num2str(subject), '_run', num2str(runnum), '.mat'), 'eeg_hand', 'eeg_wrist', 'eeg_elbow');
% 	eeg_calc_hand = eeg_hand;
% 	eeg_calc_wrist = eeg_wrist;
% 	eeg_calc_elbow = eeg_elbow;
% 	%========================================================================
% 	%% Clear space
% 	clear eeg_e* eeg_h* eeg_w*;
% 	%========================================================================
% 	%% Calculate EEG from sources
% 	for i = 1:length(source_hand.trial)
% 		disp(strcat('Calculating hand EEG trial ', 32, num2str(i)));
% 		eeg_calc_hand = source2eeg(eeg_calc_hand, source_hand.trial{i}, leadfield, i, eeg_calc_hand.label);
% 		disp(strcat('Calculating wrist EEG trial ', 32, num2str(i)));
% 		eeg_calc_wrist = source2eeg(eeg_calc_wrist, source_wrist.trial{i}, leadfield, i, eeg_calc_wrist.label);
% 		disp(strcat('Calculating elbow EEG trial ', 32, num2str(i)));
% 		eeg_calc_elbow = source2eeg(eeg_calc_elbow, source_elbow.trial{i}, leadfield, i, eeg_calc_elbow.label);
% 	end
% 	%========================================================================
% 	%% Save calculated EEGs
% 	save(strcat('calc_subject', num2str(subject), '_run', num2str(runnum)), 'eeg_calc_hand', 'eeg_calc_wrist', 'eeg_calc_elbow');
% end
%============================================================================
%% Clear and end
disp(strcat('Data organization ended'));
clear e* i* l* s*;

end
