%============================================================================
% Function name.: choose_inputs
% Date..........: July 11, 2017
% Author........: Eric F Schmiele
%                 (eric.robotic@gmail.com)
% Description...:
%                 Creates a matrix with input vectors for a classifier based
%                 on the chosen positions of a initial feature matrix.
%                    
% Parameters....: 
%                 features.-> matrix with feature values to be chosen for the
%                             input vectors (occurances x size(chosen)).
%                 chosen...-> vector or matrix indicating which features are
%                             to be used for the input vectors; if a feature
%                             should be used, then its position should have a
%                             value of 1, or 0 otherwise.
%
% Return........:
%                 inputs.-> matrix of input vectors (occurances x features).
%============================================================================

function inputs = choose_inputs(features, chosen)

%============================================================================
%% Input separation
inputs = [];
for i = 1:size(chosen, 1)
    for j = 1:size(chosen, 2)
        if chosen(i,j)
            inputs = [inputs features(:,j,i)];
        end
    end
end
%============================================================================

end