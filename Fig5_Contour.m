clear

DataPath = '../Data';
load([DataPath '/LUE_Data.mat'])

FigurePath = '../Figures/Fig5';
if ~exist(FigurePath,'dir') 
    mkdir(FigurePath)
end 

figure
syms x y
f = x*y;
colormap(jet(1000))
fcontour(f,[0,5.5e-15,0,7e6],'Fill','on','LevelList',[0.05,0.1,0.2,0.5,1,2,4,6,8,10,15,20,30]*1e-9)
colorbar

hold on
h = plot(f_reg_avg',a_reg_avg','-o','MarkerSize',4,'LineWidth',1);

set(gca,'xlim',[0,5.5e-15],'ylim',[0,7e6]);
xlabel('emissions per ag. prod (f)');
ylabel('ag. prod per capita (a)');
legend(h,RegionNames)

print(gcf,'-depsc','-painters', '-r600', [FigurePath,'/Figure [Contour_Paf]']);

close all
