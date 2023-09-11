
load('./GLM_output_MAXnormal.mat');

N = length(actual_fr);

beh_par = all_spd;
%beh_par = all_ppw;

ids_bl1 = 1:300;
ids_bl2 = 301:600;

ccd0 = [];
ccd1 = []; ccd2 = [];
ccd12 = []; ccd21 = [];

mse = [];
bhd_all = [];
bhmd = []; 
bhm = [];
ccmd = [];

ccL = []; ccH = [];
for ijk = 1:N 

    x = actual_fr{ijk};
    y = predicted_fr{ijk};

    cc0=corr(x, y, 'rows', 'complete');
    ccd0 = [ccd0, diag(cc0)'];

    [a,b] = max(diag(cc0));

    mse = [mse, meansqerror{ijk}];

    cc1=corr(x(ids_bl1,:), y(ids_bl1,:), 'rows', 'complete');
    ccd1 = [ccd1, diag(cc1)'];
    cc2=corr(x(ids_bl2,:), y(ids_bl2,:), 'rows', 'complete');
    ccd2 = [ccd2, diag(cc2)'];

    %

    beh_z = (beh_par{ijk});
    bhd = beh_z(ids_bl1) - beh_z(ids_bl2);

    bhd_all = [bhd_all, nanmean(bhd)*ones(1,size(predicted_fr{ijk},2))];
    %bhd_all = [bhd_all, nanmean(beh_z)*ones(1,size(predicted_fr{ijk},2))];

    bhmd = [bhmd, nanmean(bhd)];
    bhm = [bhm, nanmean(beh_par{ijk})];

    ccmd = [ccmd, nanmean(diag(cc0))];

    %

    % ccL = [ccL, diag(corr(x(beh_z<1,:)', y(beh_z<1,:)'))'];
    % ccH = [ccH, diag(corr(x(beh_z>1,:)', y(beh_z>1,:)'))'];

end

%%

% figure()
% hold on
% histogram(ccL)
% histogram(ccH)

plot_my_figs = 1;

if plot_my_figs


figure('Position',[100,100,500,400])

title('Best stimulus')
hold on

histogram(yidx, 'DisplayStyle','bar', 'FaceColor',[.1,.1,.1])%, 'LineWidth',2)

xlabel('Image #')
ylabel('# Units')

set(gca, 'LineWidth', 1, 'FontSize', 17, 'TickDir', 'out', 'TickLength',[.01,.01])

print('Yidx_dist.png', '-dpng')

%%

figure('Position',[100,100,800,400])

% title('MSE')
% hold on

subplot(121); hold on
histogram(mse, 'DisplayStyle','stairs', 'EdgeColor','k', 'LineWidth',2)

xlabel('MSE')
ylabel('# Units')

%xlim([0,.1])

set(gca, 'LineWidth', 1, 'FontSize', 17, 'TickDir', 'out', 'TickLength',[.01,.01])

subplot(122); hold on
histogram(ccd0, 'DisplayStyle','stairs', 'EdgeColor','k', 'LineWidth',2)

xlim([0,1])

xlabel('CC')
%ylabel('# Units')

set(gca, 'LineWidth', 1, 'FontSize', 17, 'TickDir', 'out', 'TickLength',[.01,.01])

print('MSE_CC_dist.png', '-dpng')

%%

figure('Position',[100,100,1000,400])
hold on
title(['CC: ' num2str(round(a,2)) ', MSE: ' num2str(round(meansqerror{ijk}(b),3))])

x = actual_fr{ijk}(:,b);
y = predicted_fr{ijk}(:,b);

plot(x, 'k', 'LineWidth',2)
plot(y, 'color','r', 'LineWidth',1)

legend('Actual', 'GLM fit')
legend boxoff

xlabel('Image frames')
ylabel('Activity (normalized)')

set(gca, 'LineWidth', 1, 'FontSize', 17, 'TickDir', 'out', 'TickLength',[.01,.01])

print('GLM_act_pred_example.png', '-dpng')

% - just a trace of activity

figure('Position',[100,100,1000,400])

plot(x, 'k', 'LineWidth',2)

axis off

print('act_example.png', '-dpng')

% - the R-square statistic, the F statistic and p value for the full model, and an estimate of the error variance
% x0 = model_coefficients(2,:)';
% y = ccd0';
% 
% x = x0;
% 
% x = x;%(x0>4);
% y = y;%(x0>4);
% 
% figure()
% 
% subplot(121)
% hold on
% 
% plot(x, y, 'ko')
% 
% [r2,pv]=my_regress(x,y);
% 
% r2
% 
% subplot(122)
% hold on
% bar([1,2], [nanmean(y(x<mean(x))),nanmean(y(x>mean(x)))]);
% [H,P,CI,STATS]=ttest2(y(x<.4),y(x>.4));
% 
% P


%%

figure('Position',[100,100,500,400])
subplot(111)
hold on
histogram((model_coefficients(4,:)),-30:.1:30)

xlabel('Interaction (best stim. x run. speed)')
ylabel('#')

set(gca, 'yscale', 'log', 'LineWidth', 1, 'FontSize', 17, 'TickDir', 'out', 'TickLength',[.01,.01])

ylim([.1,200])

print('coeff_interaction.png', '-dpng')

y1 = ccd0(abs(model_coefficients(4,:))<5);
y2 = ccd0(abs(model_coefficients(4,:))>5);

figure('Position',[100,100,400,400])
subplot(111)
hold on
bar([1,2], [nanmean(y1),nanmean(y2)], 'FaceColor','none', 'LineWidth',2)

plot(ones(size(y1)), y1, 'ko')
plot(ones(size(y2))*2, y2, 'ko')

xlim([0,3])

xticks([1,2])
xticklabels({'Small', 'Large'})

xlabel("Interactions")
ylabel('CC (actual, predicted)')

[h,p] = ttest2(y1,y2)

plot([1,2],[0.95,.95], 'k-', 'LineWidth',2.5)
text(1.5,.985, 'N.S.', 'FontSize',15)

set(gca, 'LineWidth', 1, 'FontSize', 17, 'TickDir', 'out', 'TickLength',[.01,.01])

print('CC_coeff_bar.png', '-dpng')


end

%%
% 
% figure()
% histogram(yidx)
% 
% xlabel('Image #')
% ylabel('Unit #')
% 
% set(gca, 'LineWidth', 1, 'FontSize', 17, 'TickDir', 'out', 'TickLength',[.01,.01])
% 
% print('dist_yidx.png', '-dpng')

%%

% r2_all = [];
% for ijk = 1:N 
% 
% figure()
% hold on
% plot(actual_fr{ijk}, predicted_fr{ijk}, 'k.')
% [r2,pv]=my_regress(actual_fr{ijk}, predicted_fr{ijk});
% text(0.1,.9,['r2: ' num2str(round(r2,2))])
% 
% r2_all = [r2_all, r2];
% 
% end
