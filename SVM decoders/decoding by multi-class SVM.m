clc; clear all; close all;
path_name = 'All';
addpath(path_name);
folder = 'All';
file_list = dir(fullfile(folder, '*.mat'));

all_regions = {};
min_units = 20;

for file_i = 1:length(file_list)
    filex = load(file_list(file_i).name);
    unit_regs = filex.unit_regs(:);
    all_regions = [all_regions; unique(unit_regs)];
end

all_regions = unique(all_regions);

result_table = array2table(nan(length(file_list), length(all_regions)), 'VariableNames', all_regions);

for file_i = 1:length(file_list)
    filex = load(file_list(file_i).name); 
    if size(filex.spd,1)>20
        continue
    end

    unique_regions = unique(filex.unit_regs);
    % Perform decoding for 20 units
    Repeat=[1:size(filex.act,2)];
    n1=floor(0.8*size(filex.act,2));%50% train

    random_num1 = Repeat(randperm(numel(Repeat),n1)); %repeat index for training %Repeat(1:10)
    random_num2 = setdiff(Repeat, random_num1); %repeat index for testing
    
    for region_i = 1:length(unique_regions)
        region = unique_regions{region_i};
        unit_indices = find(strcmp(filex.unit_regs, region));
        
        if length(unit_indices) >= 2
            selected_elements = unit_indices;
            [accuracy w]= multiSVM(filex.act, selected_elements,random_num1,random_num2);
            result_table.(region)(file_i) = accuracy;
        else
            result_table.(region)(file_i) = NaN;
        end
    end
    fprintf('-----%d done-----\n\n',file_i)
end

save('SuperMulticlass_decoding_accuracy_All_units.mat', 'result_table');
