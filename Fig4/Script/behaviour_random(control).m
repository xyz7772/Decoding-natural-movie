all_accuracy_table = table();

for repeat_i = 1:5
    %
    new_column_name = ['Accuracy_', num2str(repeat_i)];
    
    %
    temp_table = table();
    
    % For each session
    for session_i = 1:length(high_high_sessions) % change session name
        filex = load(high_high_sessions{session_i}); % change session name
        % get all unqiue units names
        unique_units = unique(filex.unit_regs);
        for unit_idx = 1:length(unique_units)
            unit = unique_units(unit_idx);
            unit_idx = find(strcmp(filex.unit_regs, unit));
            if isempty(unit_idx)
                continue
            end

              % get repeat numbers
     n_repeats = size(filex.spd, 1);
     total_length=size(filex.spd,2);

     % average speed
     avgSpeed = mean(filex.spd, 2);

    % need repeats
    numRepeats = round(0.8 * n_repeats);


    % return index
    [~, idx] = sort(avgSpeed, 'descend');
    
    %
    Repeat=[1:n_repeats];
    rng('shuffle');
    repeat1 = Repeat(randperm(numel(Repeat),numRepeats)); %random repeat index for training 
    repeat2 = setdiff(Repeat, repeat1); %random repeat index for testing

     for i= 1:N_frames 
            for j=1:N_frames 
                if j~=i;
            %% define xtrain, ytrain, xtest, ytest
                xtrain1 = filex.act(unit_idx,repeat1,i);
                xtrain2 = filex.act(unit_idx,repeat1,j); %negative
                xtrain = [xtrain1,xtrain2]';
            
                ytrain= zeros(length(repeat1)*2,1); %cell(n1,1);
                ytrain(1:length(repeat1))= i;
                ytrain(length(repeat1)+1:length(repeat1)*2)= j; 
                
                xtest1 = filex.act(unit_idx,repeat2,i);
                xtest2 = filex.act(unit_idx,repeat2,j); %negative
                xtest = [xtest1,xtest2]';
                
                ytest=zeros(length(repeat2)*2,1); %cell(n2,1);
                ytest(1:length(repeat2))= i; 
                ytest(length(repeat2)+1:2*length(repeat2))= j; 
        
        %% Train an SVM classifier using the processed data set
                SVMModel=fitcsvm(xtrain,ytrain);
        %% Predict
                result = predict(SVMModel, xtest);
                accuracy = sum(result == ytest) / length(ytest) * 100;
                temp_output(i,j) = accuracy;
           
                else
                    temp_output(i,j)=nan;
                    continue
                end
            end
  end

            % add unit name to new list
            new_row = table({high_high_sessions{session_i}}, {unit}, nanmean(temp_output(:)), 'VariableNames', {'SessionName', 'UnitName', new_column_name});
            temp_table = [temp_table; new_row];
            temp_output = zeros(30);
        end
    end
    
    
    
    % accuracy add to all_accuracy_table
    all_accuracy_table.(new_column_name) = temp_table.(new_column_name);
end

% take average
all_accuracy_table.Average_Accuracy = mean(all_accuracy_table{:,:}, 2);