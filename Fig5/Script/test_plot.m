
load('/Users/sadra/teaching/Projects-BSc-MSc/Yizhou/Data/Fig4/GLM_output.mat');

N = length(actual_fr);

%beh_par = all_spd;
beh_par = all_ppw;

ids_bl1 = 1:300;
ids_bl2 = 301:600;

ccd0 = [];
ccd1 = []; ccd2 = [];
ccd12 = []; ccd21 = [];

mse = [];
bhd_all = [];
bhmd = []; 
ccmd = [];
for ijk = 1:N 

    cc0=corr(actual_fr{ijk}, predicted_fr{ijk}, 'rows', 'complete');
    ccd0 = [ccd0, diag(cc0)'];

%     cc1=corr(actual_fr{ijk}(ids_bl1,:), predicted_fr{ijk}(ids_bl1,:), 'rows', 'complete');
%     cc2=corr(actual_fr{ijk}(ids_bl2,:), predicted_fr{ijk}(ids_bl2,:), 'rows', 'complete');
% 
%     ccd1 = [ccd1, diag(cc1)'];
%     ccd2 = [ccd2, diag(cc2)'];
% 
%     cc12=corr(actual_fr{ijk}(ids_bl1,:), predicted_fr{ijk}(ids_bl2,:), 'rows', 'complete');
%     cc21=corr(actual_fr{ijk}(ids_bl2,:), predicted_fr{ijk}(ids_bl1,:), 'rows', 'complete');
% 
%     ccd12 = [ccd12, diag(cc12)'];
%     ccd21 = [ccd21, diag(cc21)'];

    mse = [mse, meansqerror{ijk}];

%     beh_z = zscore(beh_par{ijk});
%     bhd = beh_z(ids_bl1) - beh_z(ids_bl2);
% 
%     bhd_all = [bhd_all, nanmean(bhd)*ones(1,size(predicted_fr{ijk},2))];
% 
%     bhmd = [bhmd, nanmean(bhd)];
%     
%     ccmd = [ccmd, nanmean(diag(cc1)) + nanmean(diag(cc2)) - nanmean(diag(cc12)) - nanmean(diag(cc21))];

%     figure()
%     imagesc(cc)
%     colorbar()
%     axis image
end

% figure()
% 
% subplot(121)
% hold on
% 
% bins = [0:.1/5:1];
% 
% histogram(ccd1, bins, 'EdgeColor', 'k', 'DisplayStyle','stairs', 'linewidth',1)
% histogram(ccd2, bins, 'EdgeColor', 'k', 'DisplayStyle','stairs', 'linewidth',1)
% 
% 
% histogram(ccd12, bins, 'EdgeColor', 'r', 'DisplayStyle','stairs', 'linewidth',1)
% histogram(ccd21, bins, 'EdgeColor', 'r', 'DisplayStyle','stairs', 'linewidth',1)
% 
% subplot(122)
% hold on
% 
% plot((bhmd), ccmd, 'o')

%%

% for ijk = 1:N %[21, 25] %1:N 
%     cc2=corr(actual_fr{ijk}', predicted_fr{ijk}', 'rows', 'complete');
% 
%     figure()
% subplot(211); title(num2str(ijk))
% imagesc(cc2)
% colorbar()
% axis image
% 
% subplot(212)
% plot(all_spd{ijk})
% 
% end

