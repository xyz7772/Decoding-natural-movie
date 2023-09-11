clc; clear all; close all;
path_name = 'All';
addpath(path_name);
folder = 'All';
file_list = dir(fullfile(folder, '*.mat'));
% Initialize a cell array to store individual tables
result_tables = cell(length(file_list), 1);
min_units = 20; % Set the minimum number of units required

parfor file_i = 1:length(file_list)
    result_table = table();
    filex = load(file_list(file_i).name); 
    if size(filex.spd,1)>20
    continue
    end

    % Get a list of unique unit regions
    unique_regions = unique(filex.unit_regs);
    for region_i = 1:length(unique_regions)
        region = unique_regions{region_i};
        unit_indices = find(strcmp(filex.unit_regs, region));
        
        if length(unit_indices) >= min_units
            % Perform decoding
            rng shuffle
            random_indices = randperm(length(unit_indices), min_units);
            selected_elements = unit_indices(random_indices);
            accuracy = mySVMdecoder(filex, selected_elements);
            result_table.(region) = accuracy;
        else
            % If there are not enough units, save NaN
            result_table.(region) = NaN;
        end
    end
    result_tables{file_i} = result_table;
    fprintf('-----%d done-----\n\n',file_i)
end

save('binary_decoding_accuracy.mat', 'result_tables');
