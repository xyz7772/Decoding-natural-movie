clear all; close all; clc;
figure;

% Directory where your files are stored
% directory = 'D:\2022\下半年\all files';

% Get list of all files in the directory
fileList = dir(fullfile(directory, '*.mat'));

spd_dataset1 = [];
spd_dataset2 = [];

% Loop through each file to load and plot data
for i = 1:length(fileList)

    load(fullfile(directory, fileList(i).name));
    
    if size(spd, 1) == 20  % If the first dimension is 20
        spd_dataset1 = [spd_dataset1; abs(spd(:))];
    elseif size(spd, 1) == 60  % If the first dimension is 60
        spd_dataset2 = [spd_dataset2; abs(spd(:))];
    end
end
spd_dataset1(spd_dataset1 < 1) = 1;
spd_dataset2(spd_dataset2 < 1) = 1;
% Threshold line value
threshold = 2;
colorValue = [161/255, 216/255, 106/255];
textcolor= [219/255, 136/255, 196/255];


% Plot the data for dataset1
subplot(1, 2, 1);
optimalBinWidth1 = 1;
histogram(spd_dataset1, 'Normalization', 'probability', 'BinWidth', optimalBinWidth1, 'FaceColor', colorValue);
title('Dataset1');
xlabel('Speed (cm/s)');
ylabel('Probability Density');
ylim([0.001, 1]);
set(gca, 'yscale', 'log');
box off;
hold on;
plot([threshold, threshold], [0.001, 1], 'Color', textcolor);
text(threshold, 0.05, 'Speed = 2 cm/s', 'Color', textcolor, 'VerticalAlignment', 'bottom');
set(gca, 'xscale', 'log');

% Plot the data for dataset2
subplot(1, 2, 2);
optimalBinWidth2 = 1;
histogram(spd_dataset2, 'Normalization', 'probability', 'BinWidth', optimalBinWidth2, 'FaceColor', colorValue);
title('Dataset2');
xlabel('Speed (cm/s)');
ylim([0.001, 1]);
set(gca, 'yscale', 'log');
box off; 
hold on;
plot([threshold, threshold], [0.001, 1], 'Color', textcolor);
text(threshold, 0.05, 'Speed = 2 cm/s', 'Color', textcolor, 'VerticalAlignment', 'bottom');
set(gca, 'xscale', 'log');

