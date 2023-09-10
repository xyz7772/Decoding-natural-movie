%% Introdcution
%This SVMDecoder can automatically read all files and all regions.
%% load data

clear all;
close all;
clc;

path_name = 'D:\2022\下半年\all files\';
addpath(path_name);

%read all mat files
namelist = dir([path_name '/*.mat']); %change this based on your data
Region_name=[];
Accuracy = [];
unit_all=[];
N_frames = 30;
%% union all sessions
len = length(namelist); %length(namelist);
for namei = 1:len
    file_name{namei}=namelist(namei).name;
    filex= load(file_name{namei});
    filex_temp= filex.unit_regs;
    unit_all= union(unit_all,filex_temp);
end
unit_all
%read unit one by one
for unit_i=1:length(unit_all)
    unit=unit_all(unit_i);
    Data = struct;

%if this region is not exist, label NAN and go to next session
    for namei = 1:len
    file_name{namei}=namelist(namei).name;
    filex= load(file_name{namei});
   
    while strcmp(filex.unit_regs, unit)==0
        if namei<len
            Data.value(namei)=nan;
            namei=namei+1;
            file_name{namei}=namelist(namei).name;
            filex= load(file_name{namei});
            
        else
            Data.value(namei)=nan;
        break
        end
    end

    if namei >=len && all(strcmp(filex.unit_regs, unit)==0)
        break
    end
%% find specific neurons

    unit_idx = find(strcmp(filex.unit_regs, unit));
    frame_i = 1;
    frame_j = 1;
    temp_output = zeros(N_frames); % Temporarily save all accuracy data under this loo
%% set up xtrain, ytrain, xtest, ytest

    trainnum = 10;%Run times 
    [accuracy,temp_output] = mySVMdecoder(trainnum,filex,N_frames,unit_idx,temp_output);
    temp_output=temp_output/trainnum; %average matrix
%% Overall accuracy

    overall_accuracy = nanmean(temp_output(:));
    Data.value(namei) = overall_accuracy;
    Data.region = unit;
    region_temp = Data.region; %for correct output
    end
    
    if exist('region_temp') ==1 %save output to activity table 

        Region_name=[Region_name;string(Data.region)];
        Accuracy=[Accuracy;Data.value];
        activity_table=table(Region_name,Accuracy)
    end

    clear region_temp
end

%% sort
activity_table.Average=nanmean(activity_table.Accuracy')';
activity_table.Std=nanstd(activity_table.Accuracy')';
activity_table=sortrows(activity_table,'Average','descend')

bar(table2array(activity_table(:,"Accuracy"))',table2array(activity_table(:,"Region_name")))
ylim([0 100])
yticks([0 50 100])
ylabel('Accuracy') 

print(['boxplot_figure.png'], '-dpng', '-r300');
save('boxplotfile.mat', 'activity_table')
