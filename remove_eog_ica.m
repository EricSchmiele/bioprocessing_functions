%============================================================================
% Function name.: remove_eog_ica
% Date..........: August 23, 2019
% Author........: Eric F Schmiele
%                 (eric.robotic@gmail.com)
% Description...:
%                 Uses ICA to separate the components of the channels in the
%                 dataset and eliminates the ones that are most related to
%                 EOG signals using correlation coeficients. It follows the
%                 same input system of fieldtrip functions.
%                    
% Parameters....:
%                 cfg.eogchan.-> cell with labels of channels related to EOG
%                                in the input dataset (usualy eog1, eog2,
%                                Fp1, Fp2).
%                 cfg.exteog..-> matrix with external signals of EOG
%                                channels. If this is used, then eogchan
%                                will be ignored.
%                 input.......-> dataset to be manipulated.
%
% Return........:
%                 output.-> dataset already manipulated.
%============================================================================

function output = remove_eog_ica(cfg, input)

%============================================================================
%% Analyse components
cfg_in = [];
cfg_in.method = 'runica';
comp = ft_componentanalysis(cfg_in, input);
%============================================================================
%% Separate EOG related channels
if isfield(cfg, 'exteog')
    eog_related_channels = cfg.exteog;
else
    eog_related_channels = [];
    for j = 1:length(cfg.eogchan)
        for i = 1:length(input.label)
            if isequal(input.label{i}, cfg.eogchan{j})
                eog_related_channels(j,:) = input.trial{1}(i,:);
                break;
            end
        end
    end
end
%============================================================================
%% Check correlation between components and EOG related channels
comp_to_remove = [];
for j = 1:size(eog_related_channels, 1)
	for i = 1:length(comp.label)
		r = corrcoef(eog_related_channels(j,:), comp.trial{1}(i,:));
		if r(1,2) >= 0.1
			comp_to_remove(end + 1) = i;
		end
	end
end
comp_to_remove = unique(comp_to_remove);
%============================================================================
%% Remove components possibly related to EOG
cfg_in = [];
cfg_in.component = comp_to_remove;
output = ft_rejectcomponent(cfg_in, comp, input);
%============================================================================

end