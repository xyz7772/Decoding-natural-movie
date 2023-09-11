clear all;
close all;
clc;

% Define path and add it
path_name = 'D:\2022\下半年\all files\';
addpath(path_name);

namelist = dir(fullfile(path_name, '*.mat'));
len = length(namelist);

unit_all = [];
for namei = 1:len
    filex = load(fullfile(path_name, namelist(namei).name));
    unit_all = union(unit_all, filex.unit_regs);
end
disp(unit_all);

Region_name = [];
Accuracy = [];
N_frames = 30;

% Process each unique unit
for unit_i = 1:length(unit_all)
    unit = unit_all(unit_i);
    Data = struct;

    for namei = 1:len
        filex = load(fullfile(path_name, namelist(namei).name));

        if ~any(strcmp(filex.unit_regs, unit))
            Data.value(namei) = nan;
            continue;
        end

        unit_idx = find(strcmp(filex.unit_regs, unit));
        temp_output = zeros(N_frames); % Temporarily save all accuracy data

        trainnum = 10; %Run times 
        [accuracy, temp_output] = mySVMdecoder(trainnum, filex, N_frames, unit_idx, temp_output);
        temp_output = temp_output/trainnum; % Average matrix

        Data.value(namei) = nanmean(temp_output(:));
        Data.region = unit;
    end

    Region_name = [Region_name; string(Data.region)];
    Accuracy = [Accuracy; Data.value];
    activity_table = table(Region_name, Accuracy);
end

activity_table.Average = nanmean(activity_table.Accuracy, 2);
activity_table.Std = nanstd(activity_table.Accuracy, 0, 2);
activity_table = sortrows(activity_table, 'Average', 'descend');

% Plot data
figure;
bar(table2array(activity_table(:,"Accuracy"))', table2array(activity_table(:,"Region_name")));
ylim([0 100]);
yticks([0 50 100]);
ylabel('Accuracy');
xlabel('Region Name');
title('Accuracy by Region');

print('boxplot_figure.png', '-dpng', '-r300');
save('boxplotfile.mat', 'activity_table');
