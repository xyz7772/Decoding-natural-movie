clc; clear all; close all;
path_name = 'All';
addpath(path_name);
folder = 'All';
file_list = dir(fullfile(folder, '*.mat'));

% Initialize an empty cell array to hold all regions
all_regions = {};
% Set the minimum number of units required
min_units = 20;

% Loop over all files to gather all unique regions
for file_i = 1:length(file_list)
    % Load the current file
    filex = load(file_list(file_i).name);
    
    % Convert 'unit_regs' to a column vector if it's not
    unit_regs = filex.unit_regs(:);
    
    % Add the unique regions from the current file to the cell array
    all_regions = [all_regions; unique(unit_regs)];
end

% Get a list of all unique regions across all files
all_regions = unique(all_regions);

% Initialize a table with one row for each file and one column for each region
result_table = array2table(nan(length(file_list), length(all_regions)), 'VariableNames', all_regions);

% Now continue with your parfor loop as before...

for file_i = 1:length(file_list)
    % Load the current file
    filex = load(file_list(file_i).name); 

    if size(filex.spd,1)>20
        continue
    end

    % Get a list of unique unit regions
    unique_regions = unique(filex.unit_regs);
    % Perform decoding for 20 units
    Repeat=[1:size(filex.act,2)];
    n1=floor(0.8*size(filex.act,2));%50% train

    random_num1 = Repeat(randperm(numel(Repeat),n1)); %repeat index for training %Repeat(1:10)
    random_num2 = setdiff(Repeat, random_num1); %repeat index for testing
    
    % For each unique region, check if it has enough units
    for region_i = 1:length(unique_regions)
        region = unique_regions{region_i};
        unit_indices = find(strcmp(filex.unit_regs, region));
        
        if length(unit_indices) >= 2
            selected_elements = unit_indices;
            [accuracy w]= multiSVM(filex.act, selected_elements,random_num1,random_num2);

            % Save the result to the table
            result_table.(region)(file_i) = accuracy;
        else
            % If there are not enough units, save NaN
            result_table.(region)(file_i) = NaN;
        end
    end
    fprintf('-----%d done-----\n\n',file_i)
end
% Save the table as a .mat file
save('SuperMulticlass_decoding_accuracy_All_units.mat', 'result_table');