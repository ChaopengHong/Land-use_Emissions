clear

DataPath = '../Data';
load([DataPath '/LUE_Data.mat'])

FigurePath = '../Figures/Fig2';
if ~exist(FigurePath,'dir')
    mkdir(FigurePath)
end

for ireg=1:length(RegionNames)
    
    figure('units','normalized','position',[0.2,0.2,0.3,0.7])
    hold on
    
    pMatrix(1,:) = Change_E(ireg,:)*100;
    pMatrix(2,:) = Change_P(ireg,:)*100;
    pMatrix(3,:) = Change_a(ireg,:)*100;
    pMatrix(4,:) = Change_l(ireg,:)*100;
    pMatrix(5,:) = Change_e(ireg,:)*100;
    pMatrix(6,:) = Change_f(ireg,:)*100;
    pMatrix(7,:) = LUC_Ratio(ireg,:)*100;
    pMatrix(8,:) = Ag_Ratio(ireg,:)*100;
    plot([Years(1)-1,Years(end)],[0,0],'black');
    p2 = plot(Years,pMatrix(2,:),'Color','b','LineWidth',2);
    p3 = plot(Years,pMatrix(3,:),'Color','m','LineWidth',2);
    p4 = plot(Years,pMatrix(4,:),'Color','g','LineWidth',2);
    p5 = plot(Years,pMatrix(5,:),'Color','y','LineWidth',2);
    p6 = plot(Years,pMatrix(6,:),'Color','r','LineWidth',2);
    p7 = plot(Years,pMatrix(7,:),'Color','c','LineWidth',2);
    p8 = plot(Years,pMatrix(8,:),'--','Color','c','LineWidth',2);
    p1 = plot(Years,pMatrix(1,:),'Color','k','LineWidth',4);
    text(ones(8,1)*Years(end),pMatrix(:,end),num2str(round(pMatrix(:,end))));
    lg = legend([p1,p2,p3,p4,p5,p6,p7,p8],'E','P','a','l','e','f','LUC-Ratio','Ag-Ratio');
    
    set(gca,'TickDir','out')
    set(gca,'xlim',[Years(1)-1,Years(end)],'ylim',[-100,200]);
    xlabel('Year');
    ylabel('Change Relative to 1961 (%)');
    set(lg,'position',[0.3,0.7,0.1,0.1]);
    set(lg,'box','off');
    
    box off
    ax2 = axes('Position',get(gca,'Position'),'XAxisLocation','top','YAxisLocation','right',...
        'Color','none','XColor','k','YColor','k');
    set(ax2,'YTick', []);
    set(ax2,'XTick', []);
    box on
    
    ax = gcf;
    ax.PaperPositionMode = 'auto';
    print(gcf,'-depsc','-painters', '-r600', strcat(FigurePath,'/Figure [PaleTrend-',char(RegionNames(ireg)),']'));
    
end

close all
