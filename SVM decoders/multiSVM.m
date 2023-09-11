function [averaged_acc, weights_matrix] = multiSVM(act, unit_idx, random_num1, random_num2)
    % Configuration settings
    trainnum = 1; % Number of training iterations
    N_frames = 30;

    % Initialize variables
    tempout = zeros(1, trainnum);
    model = cell(1, N_frames);
    s_trial = [];
    weights_matrix = [];
    accuracy_saved = [];
    predictions = cell(1, N_frames);
    scores = cell(1, N_frames);
    accuracy = zeros(1, N_frames);

    % Dataset sizes and partitions
    size1 = size(act, 1);
    size2 = size(act, 2);
    size3 = size(act, 3);
    n1 = floor(0.8 * size2);
    n2 = floor(0.2 * size2);
    Repeat = [1:size2];

    for i_trial = 1:trainnum
        rng('shuffle');

        % Training data
        train_data = act;

        % Test data setup
        test_labels = zeros(n2 * 30, 1);
        test_features = [];
        for test_data_n = 1:N_frames
            test_data = train_data(unit_idx, random_num2, test_data_n)';
            test_features = [test_features; test_data];
            test_labels(1 + (test_data_n - 1) * n2 : n2 * test_data_n) = test_data_n;
        end

        % Define classes and train models
        for i = 1:N_frames
            class_p = train_data(unit_idx, random_num1, i)';
            class_n = [];
            for j = 1:N_frames
                if j ~= i
                    class_n = [class_n; train_data(unit_idx, random_num1, j)'];
                end
            end

            train_features = [class_p; class_n];
            train_labels = [ones(size(class_p, 1), 1); -1 * ones(size(class_n, 1), 1)];

            % Train SVM
            model = fitcsvm(train_features, train_labels, 'ClassNames', {'-1', '1'});
            weights = model.Beta;
            weights_matrix = [weights_matrix; weights'];
            models{i} = model;
        end

        % Test the models
        scores = zeros(n2 * N_frames, N_frames);
        for i = 1:N_frames
            indices = find(test_labels == i);
            [~, score] = predict(models{i}, test_features(indices, :));
            scores(indices, i) = score(:, 2);
        end

        [~, predictions] = max(scores, [], 2);

        % Calculate accuracy
        accuracy_saved = [accuracy_saved; 100 * (sum(predictions == test_labels) / length(test_labels))];
    end

    averaged_acc = nanmean(accuracy_saved);
end
