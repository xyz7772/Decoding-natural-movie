function accuracy = mySVMdecoder(filex, unit_idx)
    trainnum = 1;
    meanaccuracy = zeros(1, trainnum);

    size1 = size(filex.act);
    size2 = size1(2); % repeat number
    size3 = size1(3); % frame number
    temp_output = zeros(size3, size3);
    n1 = floor(0.8 * size2);
    n2 = floor(0.2 * size2);

    Repeat = [1:size2];
    rng('shuffle');
    random_num1 = Repeat(randperm(numel(Repeat), n1)); 
    random_num2 = setdiff(Repeat, random_num1);

    for train_i = 1:trainnum
        for i = 1:size3
            for j = 1:size3
                if j ~= i
                    % Define training and testing datasets
                    xtrain = [filex.act(unit_idx, random_num1, i), filex.act(unit_idx, random_num1, j)]';
                    ytrain = [ones(n1, 1) * i; ones(n1, 1) * j];

                    xtest = [filex.act(unit_idx, random_num2, i), filex.act(unit_idx, random_num2, j)]';
                    ytest = [ones(n2, 1) * i; ones(n2, 1) * j];

                    % Train SVM and predict
                    SVMModel = fitcsvm(xtrain, ytrain);
                    result = predict(SVMModel, xtest);

                    % Calculate accuracy
                    if length(result) == length(ytest)
                        temp_output(i, j) = temp_output(i, j) + sum(result == ytest) / length(ytest) * 100;
                    end
                else
                    temp_output(i, j) = nan;
                end
            end
        end
        meanaccuracy(train_i) = nanmean(temp_output(:));
    end

    accuracy = mean(meanaccuracy);
    fprintf('.');
end
