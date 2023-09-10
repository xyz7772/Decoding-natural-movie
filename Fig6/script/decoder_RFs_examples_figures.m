
file_names = {'All_units_Lbv'
    'All_units_Hbv',
};

titles = file_names;

load('./selected_frames.mat');

SF = double(selected_frames);

N = size(SF, 1);
W = size(SF, 2);
H = size(SF, 3);

SFr = reshape(SF, [N, W*H])';
cc_SF = corr(SFr);

ex_no = [10, 30];

figure('Position',[100,100,1200,400])


for ijk = 1:2
    subplot(2,3,(ijk-1)*3+1)

    hold on; title(['Image # ' num2str(ex_no(ijk))]);
    imagesc(squeeze(SF(ex_no(ijk),:,:)))
    axis image
    colormap('gray')
    xticks([]); yticks([])
    set(gca, 'ydir', 'reverse')
    set(gca, 'LineWidth', 1, 'FontSize', 15, 'TickDir', 'out', 'TickLength',[.01,.01])
end


cc_all = [];
for ijk = 1:length(file_names)

    file_name = file_names{ijk};
    load(['act_coefficient_' file_name '.mat']);

    RF = pagemtimes((c * mean_data_test), SF);
    RFr = reshape(RF, [N, W*H])';
    cc_RF = corr(RFr);

    cc = corr(RFr, SFr)';

    cc_all{ijk} = abs(diag(cc));

    [a,b]=sort(cc_all{ijk}, 'descend');

    for i = 1:2
        subplot(2,3,ijk+1+(i-1)*3); 
        hold on; title(['CC: ' num2str(round(cc_all{ijk}(ex_no(i)),2))])
        imagesc(squeeze(RF(ex_no(i),:,:)))
        axis image
        colormap('gray')
        xticks([]); yticks([])
        set(gca, 'ydir', 'reverse')
        set(gca, 'LineWidth', 1, 'FontSize', 15, 'TickDir', 'out', 'TickLength',[.01,.01])

    end


print(['example_decoder_RFs.png'], '-dpng')

end


