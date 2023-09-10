
sp_keys = {'High', 'Low'};

for train_i = 1:2
    for test_i = 1:2
        
        train_key = sp_keys{train_i};
        test_key = sp_keys{test_i};

        res_name = ['train' train_key(1) 'test' test_key(1)];
        load(res_name);
       
        fig_title = ['Train ' train_key ' Speed, Test ' test_key ' Speed']; 
        
        y_lbl = ['Train ' train_key '- Test ' test_key];


% load x and y
x = all_accuracy_table.Average_Accuracy; % run behavior_random
y = results_table.Accuracy;

% define color
colorMap = containers.Map();
colorMap('VIS') = [0 0 1]; % visual cortex
colorMap('TH') = [1 0 0]; % thalamus 
colorMap('HPF') = [0 1 0]; % hippocampus 
colorMap('MB') = [1 0 1]; % midbrain 
colorMap('Other') = [0.5 0.5 0.5]; % others

% define regions
brainRegions = {
    {'HPF', 'CA1', 'SUB', 'POST', 'ProS', 'DG', 'CA3', 'CA2', 'PRE'}, 
    {'NOT', 'APN', 'LT', 'MB', 'OP', 'SCig', 'PPT', 'SCiw', 'MRN'},
    {'LGd', 'LP', 'LGv', 'IGL', 'IntG', 'LD', 'RT', 'PP', 'TH', 'POL', 'MGm', 'MGv', 'Eth', 'PO', 'SGN', 'VPL', 'PIL', 'VPM', 'MGd', 'PoT'},
    'VIS'
};

% find the color for each region
colorLabel = zeros(length(results_table.UnitName), 3);
for i = 1:length(results_table.UnitName)
    unitName = results_table.UnitName{i};
    colorKey = getColorKey(unitName, brainRegions, colorMap);
    colorLabel(i, :) = colorMap(colorKey);
end

% create scatter plot
figure; %
scatter(x, y, 70, colorLabel, 'filled'); 

% set up labels
ylabel(['Accuracy (' y_lbl ')']);
xlabel('Accuracy (Random Test-Train)');

%
xlim([50 100]);
ylim([50 100]);

axis image

%
set(gcf, 'Position', [0, 0, 600, 400]);

%
hold on;
plot([50, 100], [50, 100], 'k'); % 'k' black
hold off;

%
title(fig_title);
% legend
hold on;
h1 = scatter(nan, nan, [], [0 0 1], 'filled'); % blue
h2 = scatter(nan, nan, [], [1 0 0], 'filled'); % red
h3 = scatter(nan, nan, [], [0 1 0], 'filled'); % green
h4 = scatter(nan, nan, [], [1 0 1], 'filled'); % purple
h5 = scatter(nan, nan, [], [0.5 0.5 0.5], 'filled'); % grey
% if train_i == 1 && test_i == 1
lgd=legend([h1, h2, h3, h4, h5], {'Visual Cortex', 'Thalamus', 'Hippocampus', 'Midbrain', 'Others'}, 'Location', 'northwest');
lgd.Box='off';
% end

set(gca, 'LineWidth', 1, 'FontSize', 17, 'TickDir', 'out', 'TickLength',[.01,.01])


print(['./scatter_plot_' res_name '.png'], '-dpng', '-r300');

end
end


