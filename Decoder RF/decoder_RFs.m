
% file_names = {'all_units_from1session',
% 'V1_random',
% %'V1_hv',
% 'CA1'
% };

file_names = {'All_units_Lbv'
    'All_units_Hbv',
};

% titles = file_names;

titles = {'Image CC (Natural movie)',
    'All units (Low behav. var.)',
    'All units (High behav. var.)'
    };

load('./selected_frames.mat');

SF = double(selected_frames);

N = size(SF, 1);
W = size(SF, 2);
H = size(SF, 3);

SFr = reshape(SF, [N, W*H])';
cc_SF = corr(SFr);

cc_all = [];

figure('Position',[100,100,1400,700])

subplot(2,length(file_names)+1,1); 
%title('CC (Image RFs)', 'FontWeight','normal'); hold on
title(titles{1}, 'FontWeight','normal'); hold on

imagesc(cc_SF, [0,1])
colorbar()
axis image

xlabel('Natural Image #')
ylabel('Natural Image #')

set(gca, 'LineWidth', 1, 'FontSize', 17, 'TickDir', 'out', 'TickLength',[.01,.01])

for ijk = 1:length(file_names)

    file_name = file_names{ijk};
    load(['act_coefficient_' file_name '.mat']);

    RF = pagemtimes((c * mean_data_test), SF);
    RFr = reshape(RF, [N, W*H])';
    cc_RF = corr(RFr);

    cc = corr(RFr, SFr)';

    cc_all{ijk} = abs(diag(cc));

    %cc_all{ijk} = reshape(abs(cc_RF),1,[]);

subplot(2,length(file_names)+1,ijk+1); 
title(titles{ijk+1}, 'FontWeight','normal', 'Interpreter','none'); 
%title(file_name, 'FontWeight','normal', 'Interpreter','none'); 
%title(['CC (Decod. RFs)'], 'FontWeight','normal'); 
hold on
imagesc(cc_RF, [0,1])
colorbar()

xlabel('Decoder Image')

if ijk == 1
    ylabel('Decoder Image')
end

axis image
set(gca, 'LineWidth', 1, 'FontSize', 17, 'TickDir', 'out', 'TickLength',[.01,.01])

% - 

subplot(2,length(file_names)+1,length(file_names)+1+ijk+1)
hold on
%plot(abs(diag(cc)), '-o')
%bar(cc_all{ijk}, 'FaceColor','k')

imagesc(cc, [0,1])
colorbar()

axis image

xlabel('Decoder Image')

if ijk == 1
ylabel('Image Frame')
end

%ylim([0,1])

set(gca, 'LineWidth', 1, 'FontSize', 17, 'TickDir', 'out', 'TickLength',[.01,.01])

end

subplot(2,4,5)
hold on
for ijk = 1:length(file_names)
plot(ijk*ones(size(cc_all{ijk}))+(.5-rand(size(cc_all{ijk})))/4, ...
    cc_all{ijk}, 'ko')

plot(ijk, nanmean(cc_all{ijk}(:)), 'k+', 'MarkerSize',15, 'LineWidth',2)
end

xticks([1,2])
xticklabels(file_names)%, 'Interpreter', 'none')
xticklabels({'Low', 'High'})
xlabel('Behavourial variability')

ylabel('|CC| (Decod. Image, Actual Image)')
xlim([0,length(file_names)+1])

plot([1,2],[1,1],'k-', 'LineWidth',2)
text(1.5,1.025, '***', 'FontSize',15)
ylim([-.05,1.05])

set(gca, 'LineWidth', 1, 'FontSize', 15, 'TickDir', 'out', 'TickLength',[.01,.01])

print('decoder_RFs_CC.png', '-dpng')


