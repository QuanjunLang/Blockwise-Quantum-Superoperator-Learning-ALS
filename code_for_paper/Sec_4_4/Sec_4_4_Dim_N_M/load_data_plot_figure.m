clear all
clc
close all



load("N_M_change_p_2_recover_rate.mat")


figure;grid on
imagesc((all_N), (all_M), recover_rate')


set(gca, 'YDir', 'normal'); % Reverse y-axis to show smallest M at the bottom
xlabel('Dimension of Hilbert space: N')
ylabel('Number of observables: M_O')

set(gcf, 'Position',  [100, 100, 500, 380]);
set(findall(gcf,'-property','FontSize'),'FontSize',14);
tightfig;
colorbar
colormap(gray);
saveas(gcf, 'Sec_4_4_Necessary_data_size_Hilbert_space.pdf')

% close all
