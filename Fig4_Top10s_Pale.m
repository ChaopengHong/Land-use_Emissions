clear

DataPath = '../Data';
load([DataPath '/LUE_Data.mat'])
load([DataPath '/OtherDataset.mat'])
load([DataPath '/ColorsMaps.mat'])

FigurePath = '../Figures/Fig4';
if ~exist(FigurePath,'dir')
    mkdir(FigurePath)
end

color_all = {'GrayMap','BlueMap','PurpleMap','GreenMap','OrangeMap','RedMap'};

%% Intensities of the key Pale factors by country - Top n countries 
for palefactor=1:6
    
    prodtitle = 'kcal of ag prod';
    if palefactor==1 % E, emissions
        Values_All = [E_country(:,end),E_country_end_CIs(:,2),E_country_end_CIs(:,3),E_country(:,1)];
        Values_tot = E_reg(end,end);
        factortitle = 'Gt CO2eq emissions';
    else if palefactor==2 %A, ag prod
            Values_All = [A_country(:,end),A_country(:,end),A_country(:,end),A_country(:,1)];
            Values_tot = A_reg(end,end);
            factortitle = prodtitle;
        else if palefactor==3 %a, ag prod per capita
                Values_All = [a_country(:,end),a_country(:,end),a_country(:,end),a_country(:,1)];
                Values_tot = a_reg(end,end);
                factortitle = strcat(prodtitle,'/capita');
            else if palefactor==4 %l, land intensity of ag prod
                    Values_All = [l_country(:,end),l_country(:,end),l_country(:,end),l_country(:,1)];
                    Values_tot = l_reg(end,end);
                    factortitle = strcat('Hectares/',prodtitle);
                else if palefactor==5 %e, emissions intensity of land use
                        Values_All = 1e9*[e_country(:,end),e_country_end_CIs(:,2),e_country_end_CIs(:,3),e_country(:,1)];
                        Values_tot = 1e9*e_reg(end,end);
                        factortitle = 't CO2eq/hectare';
                    else if palefactor==6 %f, emissions intensity of ag prod
                            Values_All = 1e9*[f_country(:,end),f_country_end_CIs(:,2),f_country_end_CIs(:,3),f_country(:,1)];
                            Values_tot = 1e9*f_reg(end,end);
                            factortitle = strcat('t CO2eq/',prodtitle);
                        end
                    end
                end
            end
        end
    end
    
    % Identify Top n countries for the pale factor
    ne = 30; % only select from the top ne highest-emitting countries in the most recent year
    n = 10; % top n countries will be plotted
    EmisSort = E_country(:,end);
    [Es,cind]=sort(EmisSort(:),'descend');
    Values_All(cind(ne+1:end),:) = 0;
    Dupe = Values_All(:,1);
    for scanner = 1:n
        [~, Index(scanner)] = max(Dupe);
        Dupe(Index(scanner)) = -inf;
    end
    
    results = flipud(Values_All(Index,1));
    results_low = flipud(Values_All(Index,2));
    results_upp = flipud(Values_All(Index,3));
    results_st = flipud(Values_All(Index,4));
    labels = flipud(countryNames(Index));
    
    figure
    hb = barh(results);
    text(results,1:n,labels);
    set(gca, 'YTick', 1:n, 'YTickLabel', num2str(round(results,8)));
    set(gca,'ylim',[0.35 (n+0.65)])
    xlabel(factortitle);
    
    hold on
    hs = scatter(results_st,1:n,110,flipud(GDP2017(Index)),'filled','MarkerEdgeColor','black');
    eval(['MyColor = flipud(' char(color_all(palefactor)) '(1:55,:));']);
    colormap(MyColor);
    caxis([5000,30000]);
    hb.FaceColor = 'flat';
    hb.CData = hs.CData;
    
    hold on
    errorbar(results,1:n,results-results_low,results_upp-results,'horizontal','.','MarkerSize',0.01,'Color','black','LineWidth',1,'CapSize',12);
    if palefactor>=3
        plot([Values_tot Values_tot],[0.35 (n+0.65)],'r-','LineWidth',1)
    end
    
    ax = gcf;
    ax.PaperPositionMode = 'auto';
    print(gcf,'-depsc','-painters', '-r600', strcat(FigurePath,'/Figure [Pale_Top10s_country-',num2str(palefactor),']'));
    
end


%% Intensities of the key Pale factors by product
for palefactor=1:6
    
    prodtitle = 'kcal of ag prod';
    if palefactor==1 % E, emissions
        Values_All = [E_world_by_PGroup(end,:);E_world_by_PGroup_CIs(end,:,2);E_world_by_PGroup_CIs(end,:,3);E_world_by_PGroup(1,:)]';
        Values_tot = E_reg(end,end);
        factortitle = 'Gt CO2eq emissions';
    else if palefactor==2 %A, ag prod
            Values_All = [A_world_by_PGroup(end,:);A_world_by_PGroup(end,:);A_world_by_PGroup(end,:);A_world_by_PGroup(1,:)]';
            Values_tot = A_reg(end,end);
            factortitle = prodtitle;
        else if palefactor==3 %a, ag prod per capita
                Values_All = [a_world_by_PGroup(end,:);a_world_by_PGroup(end,:);a_world_by_PGroup(end,:);a_world_by_PGroup(1,:)]';
                Values_tot = a_reg(end,end);
                factortitle = strcat(prodtitle,'/capita');
            else if palefactor==4 %l, land intensity of ag prod
                    Values_All = [l_world_by_PGroup(end,:);l_world_by_PGroup(end,:);l_world_by_PGroup(end,:);l_world_by_PGroup(1,:)]';
                    Values_tot = l_reg(end,end);
                    factortitle = strcat('Hectares/',prodtitle);
                else if palefactor==5 %e, emissions intensity of land use
                        Values_All = 1e9*[e_world_by_PGroup(end,:);e_world_by_PGroup_CIs(end,:,2);e_world_by_PGroup_CIs(end,:,3);e_world_by_PGroup(1,:)]';
                        Values_tot = 1e9*e_reg(end,end);
                        factortitle = 't CO2eq/hectare';
                    else if palefactor==6 %f, emissions intensity of ag prod
                            Values_All = 1e9*[f_world_by_PGroup(end,:);f_world_by_PGroup_CIs(end,:,2);f_world_by_PGroup_CIs(end,:,3);f_world_by_PGroup(1,:)]';
                            Values_tot = 1e9*f_reg(end,end);
                            factortitle = strcat('t CO2eq/',prodtitle);
                        end
                    end
                end
            end
        end
    end
    
    dollars_per_kcal = squeeze(dollars_per_kcal_PGroup(end,end,:));
    
    % Remove Wood - 1
    Values_All(1,:) = [];
    dollars_per_kcal(1) = [];
    ProdGroupNames2 = ProdGroupNames;
    ProdGroupNames2(1) = [];

    % Sort the pale factor
    n = 13;
    Dupe = Values_All(:,1);
    for scanner = 1:n
        [~, Index(scanner)] = max(Dupe);
        Dupe(Index(scanner)) = -inf;
    end
    
    results = flipud(Values_All(Index,1));
    results_low = flipud(Values_All(Index,2));
    results_upp = flipud(Values_All(Index,3));
    results_st = flipud(Values_All(Index,4));
    labels = flipud(ProdGroupNames2(Index)');
    
    figure
    hb = barh(results);
    text(results,1:n,labels);
    set(gca, 'YTick', 1:n, 'YTickLabel', num2str(results));
    set(gca,'ylim',[0.35 (n+0.65)])
    xlabel(factortitle);
    
    hold on
    hs = scatter(results_st,1:n,110,flipud(dollars_per_kcal(Index)),'filled','MarkerEdgeColor','black');
    eval(['MyColor = flipud(' char(color_all(palefactor)) '(1:55,:));']);
    colormap(MyColor);
    caxis([0,0.0015]);
    hb.FaceColor = 'flat';
    hb.CData = hs.CData;
    
    hold on
    errorbar(results,1:n,results-results_low,results_upp-results,'horizontal','.','MarkerSize',0.01,'Color','black','LineWidth',1,'CapSize',12);
    if palefactor>=4
        plot([Values_tot Values_tot],[0.35 (n+0.65)],'r-','LineWidth',1)
    end
    
    ax = gcf;
    ax.PaperPositionMode = 'auto';
    print(gcf,'-depsc','-painters', '-r600', strcat(FigurePath,'/Figure [Pale_Product-',num2str(palefactor),']'));
    
end

close all
