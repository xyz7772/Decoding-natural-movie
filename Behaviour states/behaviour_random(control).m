all_accuracy_table = table();

for repeat_i = 1:5 % get 5 results
    new_column_name = ['Accuracy_', num2str(repeat_i)];
    temp_table = table();

    for session_i = 1:length(high_high_sessions) 
        filex = load(high_high_sessions{session_i});
        unique_units = unique(filex.unit_regs);
        
        for unit_idx = 1:length(unique_units)
            unit = unique_units(unit_idx);
            unit_idx = find(strcmp(filex.unit_regs, unit));
            
            if isempty(unit_idx)
                continue
            end

            n_repeats = size(filex.spd, 1);
            avgSpeed = mean(filex.spd, 2);
            numRepeats = round(0.8 * n_repeats);

            [~, idx] = sort(avgSpeed, 'descend');
            Repeat = 1:n_repeats;
            rng('shuffle');
            repeat1 = Repeat(randperm(numel(Repeat), numRepeats));
            repeat2 = setdiff(Repeat, repeat1);

            temp_output = zeros(30);
            
            for i = 1:N_frames 
                for j = 1:N_frames 
                    if j ~= i
                        xtrain1 = filex.act(unit_idx, repeat1, i);
                        xtrain2 = filex.act(unit_idx, repeat1, j);
                        xtrain = [xtrain1, xtrain2]';

                        ytrain = zeros(length(repeat1)*2, 1);
                        ytrain(1:length(repeat1)) = i;
                        ytrain(length(repeat1)+1:end) = j;

                        xtest1 = filex.act(unit_idx, repeat2, i);
                        xtest2 = filex.act(unit_idx, repeat2, j);
                        xtest = [xtest1, xtest2]';

                        ytest = zeros(length(repeat2)*2, 1);
                        ytest(1:length(repeat2)) = i;
                        ytest(length(repeat2)+1:end) = j;

                        % Train an SVM classifier
                        SVMModel = fitcsvm(xtrain, ytrain);
                        result = predict(SVMModel, xtest);
                        accuracy = sum(result == ytest) / length(ytest) * 100;

                        temp_output(i, j) = accuracy;
                    else
                        temp_output(i, j) = nan;
                    end
                end
            end

            new_row = table({high_high_sessions{session_i}}, {unit}, nanmean(temp_output(:)), 'VariableNames', {'SessionName', 'UnitName', new_column_name});
            temp_table = [temp_table; new_row];
        end
    end

    all_accuracy_table.(new_column_name) = temp_table.(new_column_name);
end

% Take average from 5 results
all_accuracy_table.Average_Accuracy = mean(all_accuracy_table{:,:}, 2);
