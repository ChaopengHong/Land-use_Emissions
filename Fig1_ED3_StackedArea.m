clear

DataPath = '../Data';
load([DataPath '/LUE_Data.mat'])

FigurePath = '../Figures/Fig1_ED3';
if ~exist(FigurePath,'dir') 
    mkdir(FigurePath)
end 

Types = {'Region','Process','Product','Gas'};
Ylims_low = [ -1 -0.4 -1 -1.8 -1 -1.8 -1 -1.8 -0.4 -8];
Ylims_upp = [  3  1.2  3  5.4  3  5.4  3  5.4  1.2 22];

for ireg = 1:length(RegionNames)
    for itype = 1:length(Types)
        
        if itype ==1 && ireg<length(RegionNames)
            continue;
        end

        if itype ==1
            LegendNames = RegionNames(1:9);
            Values_pos = E_world_by_Region_pos;
            Values_neg = E_world_by_Region_neg;
            vind = [4 8 6 1 7 5 3 2 9];
        elseif itype ==2
            LegendNames = ProcessNames;
            Values_pos = squeeze(E_reg_by_Process_pos(ireg,:,:));
            Values_neg = squeeze(E_reg_by_Process_neg(ireg,:,:));
            vind = [1 5 3 2 7 12 9 6 4 8 10 11 13];
        elseif itype ==3
            LegendNames = ProdGroupNames;
            Values_pos = squeeze(E_reg_by_PGroup_pos(ireg,:,:));
            Values_neg = squeeze(E_reg_by_PGroup_neg(ireg,:,:));
            vind = [7 3 1 11 6 8 5 10 13 2 9 14 12 4 15];
        elseif itype ==4
            LegendNames = GasNames;
            Values_pos = squeeze(E_reg_by_GHG_pos(ireg,:,:));
            Values_neg = squeeze(E_reg_by_GHG_neg(ireg,:,:));
            vind = [1 2 3];
        end
        
%         Values_pos_Allyears = sumDims(Values_pos,1);
%         [~,vind] = sort(Values_pos_Allyears,'descend');
        
        figure
        h1 = area(Years,Values_pos(:,vind));
        hold on
        h2 = area(Years,Values_neg(:,vind));
        hold on
        plot(Years,sum(Values_pos+Values_neg,2),'k-','LineWidth',2)
        mycolor = colormap(jet(length(vind)));
        for b=1:length(vind)
            h1(b).FaceColor = mycolor(b,:);
            h2(b).FaceColor = mycolor(b,:);
        end
        set(gca,'xlim',[1960 Years(end)],'ylim',[Ylims_low(ireg) Ylims_upp(ireg)]);
        xlabel('Years')
        ylabel('GHG emissions (Gt CO2-eq per year)');
        legend(LegendNames(vind))
        
        print(gcf,'-depsc','-painters', '-r600', strcat(FigurePath,'/Figure [StackedArea-',char(RegionNames(ireg)),'-By-',char(Types(itype)),']'));
        
    end
end

close all
