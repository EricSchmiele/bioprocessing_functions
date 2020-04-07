%============================================================================
% Function name.: data2ft
% Date..........: July 10, 2019
% Author........: Eric F Schmiele
%                 (eric.robotic@gmail.com)
% Description...:
%                 Generates a fieldtrip compatible structure with all the
%                 information from a given input EEG dataset.
%                    
% Parameters....: 
%                 data.....-> matrix or cell with the EEG data: if in a
%                             matrix format, it must be (nChan x nSamples);
%                             if in a cell format, it must be (1 x nTrials)
%                             with each trial being a (nChan x nSamples)
%                             matrix.
%                 channels.-> cell with the names of each EEG channel in the
%                             same order as in <data>. It must be an
%                             (nChan x 1) cell.
%                 sfreq....-> sample frequency of the data [Hz].
%                 chanunit.-> optional string with measuring unit for all
%                             channels.
%
% Return........:
%                 eeg_ft.-> presented EEG data in a fieldtrip compatible
%                           structure.
%============================================================================

function eeg_ft = data2ft(data, channels, sfreq, chanunit)

%============================================================================
%% Generate header
if ~isa(channels, 'cell')
	ME = MException('MyComponent:incorrectType', 'The input <channels> must be a cell');
	throw(ME);
end
nTrials = 1;
example_data = data;
if isa(data, 'cell')
	[lin, col] = size(data);
	if lin ~= col
		if col == 1
			data = data';
		elseif lin ~= 1
			ME = MException('MyComponent:incorrectSize', 'The input <data> must be a (1 x nTrials) cell');
			throw(ME);
		end
	end
	example_data = data{1};
	nTrials = size(data, 2);
end
[nChans, nSamples] = size(example_data);
if ~isa(channels, 'cell')
	ME = MException('MyComponent:incorrectType', 'The variable <channels> must be a cell');
	throw(ME);
else
	[lin, col] = size(channels);
	if lin ~= col
		if lin == 1
			channels = channels';
		elseif col ~= 1
			ME = MException('MyComponent:incorrectSize', 'The input <channels> must be a (nChan x 1) cell');
			throw(ME);
		end
	end
end
if size(channels, 1) ~= nChans
	ME = MException('MyComponent:incorrectSize', 'The number of channels must be the same in <channels> and <data>');
	throw(ME);
end
eeg_ft.hdr.nChans = nChans;
eeg_ft.hdr.label = channels;
eeg_ft.hdr.Fs = sfreq;
eeg_ft.hdr.nSamples = nSamples;
eeg_ft.hdr.nSamplesPre = 0;
eeg_ft.hdr.nTrials = nTrials;
%============================================================================
%% Generate trial
if ~isa(data, 'cell')
	eeg_ft.trial{1} = data;
else
	eeg_ft.trial = data;
end
%============================================================================
%% Generate time
time = 0;
for i = 1:(nSamples - 1)
	time(end + 1) = i/sfreq;
end
for i = 1:nTrials
	eeg_ft.time{1, i} = time;
end
%============================================================================
%% Generate sample frequency
eeg_ft.fsample = sfreq;
%============================================================================
%% Generate label
eeg_ft.label = channels;
%============================================================================
%% Generate infos
trialinfo = [];
sampleinfo = [];
for i = 1:nTrials
	trialinfo(i,1) = 1;
	sampleinfo(i,:) = [1 nSamples] + (i - 1)*nSamples;
end
eeg_ft.trialinfo = trialinfo;
eeg_ft.sampleinfo = sampleinfo;
%============================================================================
%% Channel unit
if nargin == 4 && ~isempty(chanunit)
	for i = 1:nChans
		aux{i,:} = chanunit;
	end
	eeg_ft.hdr.chanunit = aux;
end
%============================================================================

end