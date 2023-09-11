clear all;
close all;
clc;

% Dataset location
folder = '/rds/general/user/jx622/home/All';
file_list = dir(fullfile(folder, '*.mat'));

dataset1 = {};
dataset2 = {};

for i = 1:length(file_list)
    % Load the file
    filex = load(file_list(i).name);
    
    if size(filex.act, 2) == 20
        dataset1{end + 1} = file_list(i).name;
    elseif size(filex.act, 2) == 60
        dataset2{end + 1} = file_list(i).name;
    end
end

x = [];
y = [];
m = [];
yidx = [];

for file_i = 1:length(dataset1)
    filex = load(dataset1{file_i});
    unit = {'VISp'};
    unit_idx = find(strcmp(filex.unit_regs, unit));
    
    if isempty(unit_idx) == 1
        continue
    end

    % Allocate empty vectors
    mse_output = [];
    M = [];
    p_firing_rate = [];
    a_firing_rate = [];
    
    filex.act = permute(filex.act, [1 3 2]);
    num_frames = size(filex.spd, 2);
    num_repeats = size(filex.spd, 1);
    final_vector = zeros(1, num_frames * num_repeats * num_frames);
    
    % Create the first set of repeating frames
    for i = 1:num_frames
        frame = zeros(1, num_frames);
        frame(i) = 1;
        repeat_start_idx = (i - 1) * num_frames * num_repeats + 1;
        repeat_end_idx = repeat_start_idx + num_frames * num_repeats - 1;
        final_vector(repeat_start_idx:repeat_end_idx) = repmat(frame, 1, num_repeats);
    end

    for i = 1:num_frames
        start_idx = (i - 1) * num_repeats * num_frames + 1;
        end_idx = start_idx + num_repeats * num_frames - 1;
        S{i} = reshape(final_vector(start_idx:end_idx), num_frames * num_repeats, []);
    end

    newS = zeros(size(S{1}, 1), length(S));

    for i = 1:length(S)
        newS(:, i) = S{i};
    end

    stimulus = newS;

    response = reshape(filex.act, size(filex.act, 1), [num_repeats * num_frames])';
    select_response = response(:, unit_idx);

    % Get the firing rate of each unit and fit by GLM
    for fire_i = 1:length(unit_idx)
        firing_rate = response(:, unit_idx(fire_i));
        firing_rate = (firing_rate - min(firing_rate)) / (max(firing_rate) - min(firing_rate));

        X = [stimulus];
        model = glmfit(X, firing_rate, 'normal');

        % Evaluate model
        yfit = glmval(model, X, "identity");
        p_firing_rate = [p_firing_rate yfit];
        mse = mean((firing_rate - yfit).^2);
        mse_output = [mse_output mse];
        M = [M model];
    end
    
    for i = 1:size(M, 2)
        subset = M(2:size(stimulus, 2) + 1, i);
        [y1, yi] = max(subset);
        yidx = [yidx yi];
    end
end

disp('finished');
clc;

% Initialization
idx = 1;
M = [];
predicted_fr = cell(1, length(dataset1));
actual_fr = cell(1, length(dataset1));
meansqerror = cell(1, length(dataset1));
all_speed = cell(1, length(dataset1));
all_pph = cell(1, length(dataset1));
all_ppw = cell(1, length(dataset1));

for file_i = 1:length(dataset1)
    filex = load(dataset1{file_i});
    unit = {'VISp'};
    unit_idx = find(strcmp(filex.unit_regs, unit));

    if isempty(unit_idx) == 1
        continue
    end

    p_firing_rate = [];
    a_firing_rate = [];
    mse_values = [];

    filex.act = permute(filex.act, [1 3 2]);
    num_frames = size(filex.spd, 2);
    num_repeats = size(filex.spd, 1);
    final_vector = zeros(1, num_frames * num_repeats * num_frames);
    
    % Create the first set of repeating frames
    for i = 1:num_frames
        frame = zeros(1, num_frames);
        frame(i) = 1;
        repeat_start_idx = (i - 1) * num_frames * num_repeats + 1;
        repeat_end_idx = repeat_start_idx + num_frames * num_repeats - 1;
        final_vector(repeat_start_idx:repeat_end_idx) = repmat(frame, 1, num_repeats);
    end

    % Reshape the final vector into 30 variables
    for i = 1:num_frames
        start_idx = (i - 1) * num_repeats * num_frames + 1;
        end_idx = start_idx + num_repeats * num_frames - 1;
        S{i} = reshape(final_vector(start_idx:end_idx), num_frames * num_repeats, []);
    end

    % Preallocate new matrix
    newS = zeros(size(S{1}, 1), length(S));

    % Loop through each cell of S and put it in a separate column of newS
    for i = 1:length(S)
        newS(:, i) = S{i};
    end

    stimulus = newS;

    behavior1 = filex.spd';
    behavior1 = behavior1(:);
    spd = (behavior1 - min(behavior1(:))) / (max(behavior1(:)) - min(behavior1(:)));

    behavior2 = filex.pph';
    behavior2 = behavior2(:);
    pph = behavior2;

    behavior3 = filex.ppw';
    behavior3 = behavior3(:);
    ppw = behavior3;

    behavior4 = filex.pph_z';
    behavior4 = behavior4(:);
    pph_z = behavior4;

    response = reshape(filex.act, size(filex.act, 1), [num_repeats * num_frames])';
    select_response = response(:, unit_idx);

    for fire_i = 1:length(unit_idx)
        firing_rate = response(:, unit_idx(fire_i));
        firing_rate = (firing_rate - min(firing_rate)) / (max(firing_rate) - min(firing_rate));

        % MAX stimulus
        s = stimulus(:, yidx(idx));
        
        % Add interaction term between stimulus and behavior1
        interaction = s.*spd;

        % Fit GLM model
        X = [s behavior1 interaction];
        model = glmfit(X, firing_rate, 'normal');

        % Evaluate model
        yfit = glmval(model, X, "identity");
        p_firing_rate = [p_firing_rate yfit];
        a_firing_rate = [a_firing_rate firing_rate];
        mse = mean((firing_rate - yfit).^2);
        mse_values = [mse_values mse];
        M = [M model];
        idx = idx + 1;
    end

    all_spd{file_i} = spd;
    all_pph{file_i} = pph;
    all_ppw{file_i} = ppw;
    predicted_fr{file_i} = p_firing_rate;
    actual_fr{file_i} = a_firing_rate;
    meansqerror{file_i} = mse_values;
end

model_coefficients = M;

save('GLM_output.mat', 'model_coefficients', 'predicted_fr', 'actual_fr', 'yidx', 'dataset1', 'meansqerror', 'all_spd', 'all_pph', 'all_ppw');
