
for i = 1:4
    if i == 1
file_name = 'all units';
    elseif i == 2
file_name = 'VISp';
    elseif i == 3
file_name = 'LGd';
    elseif i == 4
file_name = 'CA1';
    end

load([file_name '.mat']);

figure()
subplot(111)
hold on
imagesc(temp_output, [50,100])

colorbar()
axis image

xlabel('Image # (class 1)')
ylabel('Image # (class 2)')

set(gca, 'LineWidth', 1, 'FontSize', 17, 'TickDir', 'out', 'TickLength',[.01,.01])

print(['Acc_' file_name '.png'], '-dpng');
end