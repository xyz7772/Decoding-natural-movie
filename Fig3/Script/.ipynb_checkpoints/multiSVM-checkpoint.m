function [averaged_acc weights_matrix] = multiSVM(act,unit_idx,random_num1,random_num2)
%%
trainnum=1; %repeat prediction n times (The final accuracy will be the average of these n iterations.)
N_frames=30;
tempout=zeros(1,trainnum); % extract accuracy 
model=cell(1,N_frames); % use for SVMmodel
s_trial=[];
weights_matrix =[];
accuracy_saved=[];
    % Initialize the variables to store the predictions and scores
    predictions = cell(1, N_frames);
    scores = cell(1, N_frames);
    accuracy = zeros(1, N_frames);

 %separate data, 80% data as train set, 20% data as test set
    size1=size(act,1);
    size2=size(act,2); %repeat number
    size3=size(act,3); %class number
    n1=floor(0.8*size2);%50% train
    n2=floor(0.2*size2);%50% test
    
    %set random numbers for train sets and test sets
    Repeat=[1:size2];
    for i_trial=1:trainnum

    rng('shuffle');

    % train data
    train_data = act;

    % test data
    test_labels=zeros(n2*30,1);
    test_features=[];

    for test_data_n=1:N_frames
        test_data = train_data(unit_idx,random_num2,test_data_n)';
        test_features = [test_features;test_data];
        % test data true labels (answers)
        test_labels(1+(test_data_n-1)*n2:n2*test_data_n)= test_data_n;
    end

  % define 30 classes (30 frames)
    for i=1:N_frames
        class_p = train_data(unit_idx,random_num1,i)';
        class_n = [];
        for j = 1:N_frames
            if j ~= i
                class_n = [class_n; train_data(unit_idx,random_num1,j)'];
            end
        end

        train_features= [class_p;class_n];

        % positive is 1, negative is -1
        n_positive = size(class_p, 1);
        n_negative = size(class_n, 1);
        train_labels= [ones(n_positive,1);-1*ones(n_negative,1)];

        % individually train 30 models
        model = fitcsvm(train_features,train_labels,'ClassNames',{'-1','1'});  
        
        % Get the weights
        weights = model.Beta;
        
        % Add the weights to the weights matrix
        weights_matrix = [weights_matrix; weights'];
        
        models{i} = model;

    end
% Initialize the variables to store the predictions and scores
scores = zeros(n2 * N_frames, N_frames);
predictions = zeros(n2 * N_frames, 1);

% For each model...
for i = 1:N_frames
    % Get the indices of the test samples for the current class
    indices = find(test_labels == i);
    
    % Predict the test features for the current class and store the scores
    [~, score] = predict(models{i}, test_features(indices, :));
    
    scores(indices, i) = score(:, 2);  % Store the scores of the positive class
end

% For each test sample...
for i = 1:size(scores, 1)
    % Select the class with the highest score
    [~, predictions(i)] = max(scores(i, :));
end

% Calculate the accuracy of the predictions
accuracy = 100*(sum(predictions == test_labels) / length(test_labels));
accuracy_saved=[accuracy_saved;accuracy]
end

averaged_acc=nanmean(accuracy_saved);

%fprintf('-----multiclass SVM finished-----\n\n')
end