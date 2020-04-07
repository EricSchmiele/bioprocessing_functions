%============================================================================ 
% Function name.: statistical_test
% Date..........: July 6, 2017
% Author........: Eric F Schmiele
%                 (eric.robotic@gmail.com)
% Description...:
%                 Returns the h and pvalue from the desired statistical test
%                 (ttest, kstest, ranksum, ttest with two groups or kstest
%                 with two groups).
%                    
% Parameters....: 
%                 group_1.-> data group 1.
%                 arg2....-> data group 2 or test choice (in the case of a
%                            test wity only one data group).
%                 arg3....-> test choice:
%                                         't' for ttest with one group;
%                                         'ks' for kstest with one group;
%                                         't2' for ttest with two groups;
%                                         'ks2' for ttest with two groups;
%                                         'rs' for ranksum with two groups.
%
% Return........:
%                 h.-> h value from required test.
%                 p.-> p value from required test.
%============================================================================

function [h, p] = statistical_test(group_1, arg2, arg3)

%============================================================================ 
%% Manage inputs
group_2 = [];
if nargin > 1
    if ischar(arg2)
        opt = arg2;
    else
        if nargin == 3
            opt = arg3;
        else
            opt = 't2';
        end
        group_2 = arg2;
    end
else
    opt = 't';
end
%============================================================================ 
%% Make required statistical test
h = [];
p = [];
switch opt
    case 'ks',
        for i = 1:size(group_1, 3)
            for j = 1:size(group_1, 2)
                [h(i,j), p(i,j)] = kstest(group_1(:,j,i));
            end
        end
    case 't',
        for i = 1:size(group_1, 3)
            for j = 1:size(group_1, 2)
                [h(i,j), p(i,j)] = ttest(group_1(:,j,i));
            end
        end
    case {'rs', 'rs2'},
        if ~isempty(group_2)
            for i = 1:size(group_1, 3)
                for j = 1:size(group_1, 2)
                    [p(i,j), h(i,j)] = ranksum(group_1(:,j,i), group_2(:,j,i));
                end
            end
        else
            disp('Incorrect input choice');
        end
    case 't2',
        if ~isempty(group_2)
            for i = 1:size(group_1, 3)
                for j = 1:size(group_1, 2)
                    [h(i,j), p(i,j)] = ttest(group_1(:,j,i), group_2(:,j,i));
                end
            end
        else
            disp('Incorrect input choice');
        end
    case 'ks2'
        if ~isempty(group_2)
            for i = 1:size(group_1, 3)
                for j = 1:size(group_1, 2)
                    [h(i,j), p(i,j)] = kstest2(group_1(:,j,i), group_2(:,j,i));
                end
            end
        else
            disp('Incorrect input choice');
        end
    otherwise
        disp('Incorrect input choice');
end
%============================================================================ 

end