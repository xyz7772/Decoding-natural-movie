clear all;
close all;
clc;

path_name = 'D:\2022\下半年\all files\';
addpath(path_name);
%read all mat files
namelist = dir([path_name '/*.mat']); %change this based on your data

N_frames=30;
temp_output = zeros(30);

% Initialize variables to store specific session names
high_low_sessions = {};
low_low_sessions = {};
high_high_sessions = {};
low_high_sessions = {};

% Loop through sessions
for i = 1:length(namelist)
    session = namelist(i).name;
    
    % Load session data (replace this with your actual data loading)
    filex = load(session);
    
    % Split the session into two blocks
    n_repeats = size(filex.spd, 1);
    block1 = filex.spd(1:(n_repeats / 2),:);
    block2 = filex.spd((n_repeats / 2 + 1):end,:);
    HS=1;
    LS=1;
    
    % Calculate mean speed for each repeat

    for j=1:n_repeats 

    mean_speed_repeat =mean(filex.spd(j,:));
    if abs(mean_speed_repeat) >=2
        HS=HS+1;
    else
        LS=LS+1;
    end

    end

    % Store session names in specific variables
    if HS>=floor(0.8*n_repeats) && LS>=floor(0.2*n_repeats)
        high_low_sessions = [high_low_sessions, session];
    elseif HS==n_repeats
        high_high_sessions = [high_high_sessions, session];
    elseif LS==n_repeats
        low_low_sessions = [low_low_sessions, session];
    elseif LS>=floor(0.8*n_repeats) && HS>=floor(0.2*n_repeats)
        low_high_sessions = [low_high_sessions, session];
    end

end

% Create an empty table to store session names and accuracy values
results_table = table([], [], [], 'VariableNames', {'SessionName', 'UnitName', 'Accuracy'});

for session_i=1:length(high_high_sessions)
     filex = load(high_high_sessions{session_i});
        % get the unique name of the units
    unique_units = unique(filex.unit_regs);
        for unit_idx = 1:length(unique_units)
        unit = unique_units(unit_idx);
     unit_idx = find(strcmp(filex.unit_regs, unit));
     if isempty(unit_idx)
         continue
     end

     % get repeats
     n_repeats = size(filex.spd, 1);
     total_length=size(filex.spd,2);

     % take average
     avgSpeed = mean(filex.spd, 2);

    % repeats number
    numRepeats = round(0.8 * n_repeats);

    % sort based on speed
    [~, idx] = sort(avgSpeed, 'ascend');

    % select test and train repeats
    repeat1 = idx(1:numRepeats); %training top 80% (high speed)
    repeat2 = idx(numRepeats+1:n_repeats); %test low speed
    
    repeat1=randperm(n_repeats,numRepeats);
    repeat2=setdiff(1:n_repeats,repeat1);
 

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
        % add units to result table
        new_row = table({low_low_sessions{session_i}}, {unit}, nanmean(temp_output(:)), 'VariableNames', {'SessionName', 'UnitName', 'Accuracy'});
        results_table = [results_table; new_row];
        temp_output = zeros(30);
        end
end