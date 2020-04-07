%============================================================================
% Function name.: get_features
% Date..........: August 2, 2017
% Author........: Eric F Schmiele
%                 (eric.robotic@gmail.com)
% Description...:
%                 returns the values of one or more features extracted from a
%                 given signal data set. The features should be determined by
%                 the user.
%                    
% Parameters....:
%                 data.....-> input data set with signal target epochs
%                             (channels x samples x epoch), if the epochs are
%                             separated in different cell (given a specified
%                             target) each cell should still follow the
%                             dimention pattern and at the end their features
%                             will be concatenated.
%                 varargin.-> vector with string names of the features to be
%                             extracted. The possible features to be
%                             extracted are:
%                             kurt.-> kurtosis value (help kurtosis);
%                             mean.-> mean value (help mean);
%                             mav..-> mean absolute value (help getMAV);
%                             pow..-> power calculated using the normalized
%                                     power spectral density, requires the
%                                     sampling frequency and optionaly the
%                                     frequency intervals to calculate the
%                                     power (help power_freq_range), example:
%                                     get_features(data, 'pow', sampFreq,
%                                     lowFreq, highFreq);
%                             skw..-> skewness value (help skewness);
%                             ssc..-> slope sign change value (help getSSC);
%                             std..-> standard deviation value (help std);
%                             wl...-> waveform length value (help getWL);
%                             zc...-> zero crossing value (help getZC).
%
% Return........:
%                 total_features.-> values of the desired features extracted
%                                   from the data set in the user required
%                                   order (channels x features x epoch),
%                                   given that if the data set was fed in
%                                   separate cells then all the epochs of
%                                   different cells will beconcatenated in
%                                   order.
%============================================================================

function total_features = get_features(data, varargin)

%============================================================================
%% Manage inputs
freqs = {};
opt = {};
for i = 1:length(varargin)
    if isnumeric(cell2mat(varargin(i)))
        freqs(end + 1) = varargin(i);
    else
        opt(end + 1) = varargin(i);
    end
end

total_features = [];
if isempty(varargin)
    disp('Features not specified');
    return;
end
%============================================================================
%% Determine feature extraction functions to be used
functions = {};
for i = 1:length(opt)
    switch(lower(cell2mat(opt(i))))
        case 'mean'
            functions{i} = @(x) mean(x);
        case 'mav'
            functions{i} = @(x) getMAV(x);
        case 'zc'
            functions{i} = @(x) getZC(x);
        case 'wl'
            functions{i} = @(x) getWL(x);
        case 'ssc'
            functions{i} = @(x) getSSC(x);
        case 'std'
            functions{i} = @(x) std(x);
        case 'kurt'
            functions{i} = @(x) kurtosis(x);
        case 'skw'
            functions{i} = @(x) skewness(x);
        case 'pow'
            if length(freqs) == 1
                freqs(2) = {0};
                freqs(3) = {cell2mat(freqs(1)) / 2};
            elseif length(freqs) ~= 3
                disp('Power extraction info not specified');
                return;
            end
            functions{i} = @(x) power_freq_range(x, cell2mat(freqs(1)), cell2mat(freqs(2)), cell2mat(freqs(3)));
        otherwise
            disp('Invalid feature option');
            return;
    end
end
%============================================================================
%% Manage input data set
if iscell(data)
    total_iterations = length(data);
    raw_data = cell2mat(data(1));
else
    total_iterations = 1;
    raw_data = data;
end
%============================================================================
%% Extract features
features = [];
for current_iteration = 1:total_iterations
    if current_iteration > 1
        raw_data = cell2mat(data(current_iteration));
    end
    for cur_epoch = 1:size(raw_data, 3)
        block = [];
        for cur_channel = 1:size(raw_data, 1)
            line = [];
            for cur_func = 1:length(functions)
                line = [line functions{cur_func}(raw_data(cur_channel,:,cur_epoch))];
            end
            block = [block; line];
        end
        if isempty(features)
            features = block;
        else
            features(:,:,size(features, 3) + 1) = block;
        end
    end
end
%============================================================================
%% Manage outputs
total_features = permute(features, [3 2 1]);
%============================================================================

end