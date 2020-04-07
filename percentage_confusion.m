%============================================================================
% Function name.: percentage_confusion
% Date..........: July 6, 2017
% Author........: Eric F Schmiele
%                 (eric.robotic@gmail.com)
% Description...:
%                 Transforms the values of a conrusion matrix into percentage
%                 values considering that each line sums up to 100%.
%                    
% Parameters....: 
%                 pure_confusion.-> input confusion matrix.
%
% Return........:
%                 percentage_confusion.-> confusion matrix with its values in
%                                         percentage.
%============================================================================

function percentage_confusion = percentage_confusion(pure_confusion)

%============================================================================
%% Calculate percentages
percentage_confusion = zeros(size(pure_confusion));
for k = 1:size(pure_confusion, 3)
    for i = 1:size(pure_confusion, 1)
        floor = sum(pure_confusion(i,:,k));
        for j = 1:size(pure_confusion, 2)
            percentage_confusion(i,j,k) = pure_confusion(i,j,k) / floor;
        end
    end
end
%============================================================================

end