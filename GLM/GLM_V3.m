% Do dataset_separation
clear all;close all;clc;
path_name = '/rds/general/user/jx622/home/All'; % you dataset location
addpath(path_name);
folder = '/rds/general/user/jx622/home/All'; % you dataset location
file_list = dir(fullfile(folder, '*.mat'));

% Create two empty cell arrays
dataset1 = {};
dataset2 = {};
% Traverse all files
for i=1:length(file_list)
    % Load the file
    filex = load(file_list(i).name);
    % Check if the file meets the condition
    if size(filex.act,2) == 20
        % Add the file name to the end of dataset1
        dataset1{end+1} = file_list(i).name;
    elseif size(filex.act,2) == 60
        % Add the file name to the end of dataset2
        dataset2{end+1} = file_list(i).name;
   
        %dataset1{end+1} = file_list(i).name;
    end
end

% session_name=[];
x=[];
y=[];
m=[];
yidx=[];
%% loop files in dataset#
for file_i=1:length(dataset1)
    %filex=load(file_list(file_i).name);
    filex=load(dataset1{file_i});
     unit= {'VISp'};
     unit_idx = find(strcmp(filex.unit_regs, unit));
     if isempty(unit_idx)==1
        continue
     end
     
     %allocate empty vectors
     mse_output=[]; %save mse data
     M=[]; %save beta coefficients
     p_firing_rate=[]; %save predicted firing rate
     a_firing_rate=[];

    %% Define response variable
    % Permute the dimensions of filex.act
    filex.act = permute(filex.act, [1 3 2]);

    % Set the number of frames and repeats
    num_frames = size(filex.spd,2);
    num_repeats = size(filex.spd,1);

    % Initialize the final vector
    final_vector = zeros(1, num_frames*num_repeats*num_frames);

    % Create the first set of repeating frames
    for i = 1:num_frames
        frame = zeros(1, num_frames);
        frame(i) = 1;
        repeat_start_idx = (i-1)*num_frames*num_repeats + 1;
        repeat_end_idx = repeat_start_idx + num_frames*num_repeats - 1;
        final_vector(repeat_start_idx:repeat_end_idx) = repmat(frame, 1, num_repeats);
    end
    
    % Reshape the final vector into 30 variables, each containing num_frame x num_repeats data points
    for i = 1:num_frames
        start_idx = (i-1)*num_repeats*num_frames + 1;
        end_idx = start_idx + num_repeats*num_frames - 1;
        S{i} = reshape(final_vector(start_idx:end_idx), num_frames*num_repeats, []);
    end
    
    % Preallocate new matrix
    newS = zeros(size(S{1}, 1), length(S));
    
    % Loop through each cell of S and put it in a separate column of newS
    for i = 1:length(S)
        newS(:, i) = S{i};
    end
    
    stimulus = newS; % Define stimulus variables

    %% define response variable
    response = reshape(filex.act, size(filex.act,1),[num_repeats*num_frames])'; % Reshape data to be 600 x n
    select_response=response(:,unit_idx);

    %% get the firing rate of each unit and fitted by GLM
    for fire_i=1:length(unit_idx)
    firing_rate = response(:,unit_idx(fire_i)); % Compute firing rate for each neuron
    
    % Normalization
    %firing_rate = firing_rate/ mean(firing_rate);
    firing_rate = (firing_rate - min(firing_rate)) / (max(firing_rate) - min(firing_rate));
    %firing_rate = (firing_rate - mean(firing_rate)) / std(firing_rate);

    
    % Fit GLM model
    X = [stimulus]; % Construct design matrix
    model = glmfit(X, firing_rate, 'normal'); % Fit GLM using normal distribution
    
    % Evaluate model
    yfit = glmval(model, X,"identity"); % Compute predicted firing rate
    p_firing_rate=[p_firing_rate yfit];
    mse = mean((firing_rate - yfit).^2); %computed the mean squared error 
    mse_output=[mse_output mse];

    %if mse>=0.5
    % Interpret results
    M=[M model]; % Extract coefficients for predictor variables and save in each loop
    %end
    
    end
    
    for i=1:size(M,2)

    subset = M(2:size(stimulus,2)+1, i);
    [y1, yi] = max(subset);
    yidx=[yidx yi]; 

    end

end
disp('finished')
clc;
% session_name=[];
idx=1;
%yidx=[];
%% loop files in dataset#
M=[];
% Initialize the cell arrays
predicted_fr = cell(1, length(dataset1));
actual_fr = cell(1, length(dataset1));
meansqerror = cell(1, length(dataset1));
all_speed= cell(1, length(dataset1));
all_pph= cell(1, length(dataset1));
all_ppw=cell(1, length(dataset1));

for file_i=1:length(dataset1)
    %filex=load(file_list(file_i).name);
     filex=load(dataset1{file_i});
     unit= {'VISp'};
     unit_idx = find(strcmp(filex.unit_regs, unit));
     if isempty(unit_idx)==1
        continue
     end
     
      %save beta coefficients
     p_firing_rate=[]; %save predicted firing rate
     a_firing_rate=[];

     mse_values = [];

    %% Define response variable
    % Permute the dimensions of filex.act
    filex.act = permute(filex.act, [1 3 2]);

    % Set the number of frames and repeats
    num_frames = size(filex.spd,2);
    num_repeats = size(filex.spd,1);

    % Initialize the final vector
    final_vector = zeros(1, num_frames*num_repeats*num_frames);

    % Create the first set of repeating frames
    for i = 1:num_frames
        frame = zeros(1, num_frames);
        frame(i) = 1;
        repeat_start_idx = (i-1)*num_frames*num_repeats + 1;
        repeat_end_idx = repeat_start_idx + num_frames*num_repeats - 1;
        final_vector(repeat_start_idx:repeat_end_idx) = repmat(frame, 1, num_repeats);
    end
    
    % Reshape the final vector into 30 variables, each containing num_frame x num_repeats data points
    for i = 1:num_frames
        start_idx = (i-1)*num_repeats*num_frames + 1;
        end_idx = start_idx + num_repeats*num_frames - 1;
        S{i} = reshape(final_vector(start_idx:end_idx), num_frames*num_repeats, []);
    end
    
    % Preallocate new matrix
    newS = zeros(size(S{1}, 1), length(S));
    
    % Loop through each cell of S and put it in a separate column of newS
    for i = 1:length(S)
        newS(:, i) = S{i};
    end
    
    stimulus = newS; % Define stimulus variables
    %% Define behavior variables
    
    behavior1 = filex.spd'; % Define behavioral variables and convert 20x 30 into 600 x 1
    behavior1 = behavior1(:);
    spd=(behavior1 - min(behavior1(:))) / (max(behavior1(:)) - min(behavior1(:)));
    
    behavior2 = filex.pph';
    behavior2 = behavior2(:);
    pph=behavior2;
    
    behavior3 = filex.ppw';
    behavior3 = behavior3(:);
    ppw=behavior3;
    
    behavior4 = filex.pph_z';
    behavior4 = behavior4(:);
    pph_z=behavior4;
    
    %% define response variable
    response = reshape(filex.act, size(filex.act,1),[num_repeats*num_frames])'; % Reshape data to be 600 x n
    select_response = response(:,unit_idx);

    %% get the firing rate of each unit and fitted by GLM
    for fire_i=1:length(unit_idx)
        firing_rate = response(:,unit_idx(fire_i)); % Compute firing rate for each neuron

        % Normalization
        %firing_rate = firing_rate/ mean(firing_rate);
        firing_rate = (firing_rate - min(firing_rate)) / (max(firing_rate) - min(firing_rate));
        %firing_rate = (firing_rate - mean(firing_rate)) / std(firing_rate);

        % MAX stimulus
        s=stimulus(:,yidx(idx)); % run GLM_V1.m first to get yidx
        %% Add interaction term between stimulus and behavior1
        interaction=s.*spd;

        % Fit GLM model
        X=[s behavior1 interaction]; % Construct design matrix
        model = glmfit(X, firing_rate, 'normal'); % Fit GLM using normal distribution

        % Evaluate model
        yfit = glmval(model, X,"identity"); % Compute predicted firing rate
        p_firing_rate=[p_firing_rate yfit];
        a_firing_rate=[a_firing_rate firing_rate];
        mse = mean((firing_rate - yfit).^2); %computed the mean squared error 

        %if mse<=0.5
        % Interpret results
        M=[M model]; % Extract coefficients for predictor variables and save in each loop
        %end
        idx=idx+1;

        %% plot GLM CF of speed against maximum stimulus for all sessions 
        if isempty(M)==1
            continue
        end
        mse_values=[mse_values mse];
    end
all_spd{file_i}= spd;
all_pph{file_i}= pph;
all_ppw{file_i}= ppw;
predicted_fr{file_i} = p_firing_rate;
actual_fr{file_i} =  a_firing_rate;
meansqerror{file_i} = mse_values;
end
model_coefficients=M;
% After the loop, save the variables to a .mat file
save('GLM_output.mat', 'model_coefficients', 'predicted_fr', 'actual_fr', 'yidx','dataset1','meansqerror','all_spd','all_pph','all_ppw');