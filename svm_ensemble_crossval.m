%============================================================================ 
% Function name.: svm_ensemble_crossval
% Date..........: July 11, 2017
% Author........: Eric F Schmiele
%                 (eric.robotic@gmail.com)
% Description...:
%                 Runs an ensemble of SVM classifiers for the given inputs
%                 and targets considering a k-fold cross validation and
%                 returns the confusion matrices of each fold and the total
%                 confusion matrix.
%                    
% Parameters....: 
%                 X.-> inputs for the classifiers.
%                 Y.-> target vector.
%                 K.-> optional input: number of folds for the cross
%                      validation.
%                      Default: 4.
%
% Return........:

%                 total_confusion_test..-> confusion matrix of the average
%                                          from all test results in
%                                          percentage (#targets x #targets).
%                 confusions_test.......-> confusion matrices of test results
%                                          for each fold (#targets x #targets
%                                          x folds).
%                 total_confusion_train.-> confusion matrix of the average
%                                          from all train results in
%                                          percentage (#targets x #targets).
%                 confusions_train......-> confusion matrices of train
%                                          results for each fold (#targets
%                                          x #targets x folds).
%============================================================================ 

function [total_confusion_test, confusions_test, total_confusion_train, confusions_train] = svm_ensemble_crossval(X, Y, K)

%============================================================================ 
%% Manage inputs
%define K as 4 if it is not specified
if nargin ~= 3
    K = 4;
end

%define number of possible classes
num_classes = length(unique(Y));
%============================================================================ 
%% Prepare fold separation
%convert Y from cell to matrix if necessary
if iscell(Y)
    Y = cell2mat(Y);
end

% generates a vector with the same size as Y given that each position has
% an indication of which fold the current position belongs to
folds_indx = crossvalind('KFold', Y, K);
%============================================================================ 
%% Classification for each fold
confusions_train = [];
confusions_test = [];
for current_fold = 1:K
    msg = strcat('Fold: ', num2str(current_fold));
    disp(msg);
    X_train = [];
    Y_train = [];
    X_test = [];
    Y_test = [];
    %separate groups of training and testing considering the current fold
    for j = 1:size(X, 1)
        if folds_indx(j) == current_fold
            X_test = [X_test; X(j,:)];
            Y_test = [Y_test; Y(j)];
        else
            X_train = [X_train; X(j,:)];
            Y_train = [Y_train; Y(j)];
        end
    end
    % generate classifier model
    disp('Training');
    if num_classes < 3
        model = fitcsvm(X_train, Y_train, 'Standardize', true, 'KernelFunction', 'RBF', 'KernelScale', 'auto');
    else
        model = fitcecoc(X_train, Y_train);
    end
    %classify training data and generate confusion matrix
    disp('Classifying');
    Y_train_predicted = predict(model, X_train);
    confusions_train(:,:,current_fold) = confusionmat(Y_train, Y_train_predicted);
    %classify test data and generate confusion matrix
    Y_test_predicted = predict(model, X_test);
    confusions_test(:,:,current_fold) = confusionmat(Y_test, Y_test_predicted);
end
%============================================================================ 
%% Manage output
%calculate averages and present them in percentage form
total_confusion_train = sum(confusions_train, 3);
total_confusion_test = sum(confusions_test, 3);
total_confusion_train = percentage_confusion(total_confusion_train);
total_confusion_test = percentage_confusion(total_confusion_test);
disp('Done');
%============================================================================ 

end