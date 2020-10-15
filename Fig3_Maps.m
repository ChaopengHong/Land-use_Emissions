clear

DataPath = '../Data';
load([DataPath '/LUE_Data.mat'])
load([DataPath '/ColorsMaps.mat'])

FigurePath = '../Figures/Fig3';
if ~exist(FigurePath,'dir')
    mkdir(FigurePath)
end

% Choose specific year for single-year figure
IndexYear = length(Years);


%% Fill Pale factor fields in Global_FAO geostruct

% Add factor fields to the Global geostruct
for i = 1:numel(Global)
    Global(i).a = 0;
    Global(i).l = 0;
    Global(i).e = 0;
    Global(i).f = 0;
end

numregs = size(a_country,1);
for i = 1:numel(Global)
    for j = 1:numregs
        if Global(i).Region == j
            Global(i).a = mean(a_country(j,IndexYear));
            Global(i).l = mean(l_country(j,IndexYear));
            Global(i).e = mean(e_country(j,IndexYear));
            Global(i).f = mean(f_country(j,IndexYear));
        end
    end
end

%Set bounds so that maps not all one color...
for var=1:4
    
    plotrange = 1; %number of standard deviations to show on maps/colorscales
    if var==1
        vals=mean(a_country(:,IndexYear),2);
        maxval(var) = mean(vals) + (plotrange*std(vals));
        minval(var) = mean(vals) - (plotrange*std(vals));
    else if var==2
            vals=mean(l_country(:,IndexYear),2);
            maxval(var) = mean(vals);
            minval(var) = mean(vals) - (plotrange*std(vals));
        else if var==3
                vals=mean(e_country(:,IndexYear),2);
                maxval(var) = mean(vals);
                minval(var) = mean(vals) - (plotrange*std(vals));
            else if var==4
                    vals=mean(f_country(:,IndexYear),2);
                    maxval(var) = mean(vals) + (plotrange*std(vals));
                    minval(var) = mean(vals) - (plotrange*std(vals));
                end
            end
        end
    end
    
    if minval(var)<0
        minval(var)=0;
    end
    
end

%% Figure - Tryptych of Pale factor maps

%% Panel x (a - Ag production per capita) = variable 1
var=1;
makeplot=1;
MyColor = flipud(PurpleMap);

if makeplot==1
    
    % Bound colorscale and reset values in Global
    for i = 1:numel(Global)
        if Global(i).a <= minval(var)
            Global(i).a = minval(var);
            Global(i).tag;
        end
    end
    for i = 1:numel(Global)
        if Global(i).a >= maxval(var)
            Global(i).a = maxval(var);
            Global(i).tag;
        end
    end
    
    figure('color','white','Name','Ag prod per capita')
    axesm('MapProjection','eckert4'); % Eckert IV projection
    framem on; gridm off; mlabel off; plabel off; % Turn off the labels
    framem('FlineWidth',0.01,'FEdgeColor','black')
    title('Ag prod per capita')
    setm(gca,'FLatLimit',[-60 83],'FLonLimit',[-174 186],'MapLonLimit',[-174 186],'Origin',[],...
        'FFaceColor',[0.80 0.80 0.86]);
    
    MapColor = makesymbolspec('Polygon', {'a', [minval(var) maxval(var)], 'FaceColor',...
        MyColor, 'EdgeColor', MyColor, 'LineWidth', 0.001});
    geoshow(Global, 'DisplayType', 'polygon','SymbolSpec', MapColor);
    
    caxis([minval(var) maxval(var)])
    colormap (MyColor)
    colorbar
    
    print(gcf,'-depsc','-painters', '-r200', strcat(FigurePath,'/Figure [Map_a]'));
    
end %if makeplot


%% Panel x (l - Land per unit ag prod) = variable 2
var=2;
makeplot=1;
MyColor = flipud(BlueMap);

if makeplot==1
    
    % Cap colorscale
    for i = 1:numel(Global)
        if Global(i).l <= minval(var)
            Global(i).l = minval(var);
            Global(i).tag;
        end
    end
    for i = 1:numel(Global)
        if Global(i).l >= maxval(var)
            Global(i).l = maxval(var);
            Global(i).tag;
        end
    end
    
    figure('color','white','Name','Land per unit ag prod')
    axesm('MapProjection','eckert4'); % Eckert IV projection
    framem on; gridm off; mlabel off; plabel off; % Turn off the labels
    framem('FlineWidth',0.01,'FEdgeColor','black')
    title('Land per unit ag prod')
    setm(gca,'FLatLimit',[-60 83],'FLonLimit',[-174 186],'MapLonLimit',[-174 186],'Origin',[],...
        'FFaceColor',[0.80 0.80 0.86]);
    
    MapColor = makesymbolspec('Polygon', {'l', [minval(var) maxval(var)], 'FaceColor',...
        MyColor, 'EdgeColor', MyColor, 'LineWidth', 0.001});
    geoshow(Global, 'DisplayType', 'polygon','SymbolSpec', MapColor);
    
    caxis([minval(var) maxval(var)])
    colormap (MyColor)
    colorbar
    
    print(gcf,'-depsc','-painters', '-r200', strcat(FigurePath,'/Figure [Map_l]'));
    
end %if makeplot


%% Panel x (e - Emissions per unit land) = variable 3

% Cap colorscale
var=3;
makeplot=1;
MyColor = flipud(OrangeMap);

if makeplot==1
    
    % Bound colorscale and reset values in Global
    for i = 1:numel(Global)
        if Global(i).e <= minval(var)
            Global(i).e = minval(var);
            Global(i).tag;
        end
    end
    for i = 1:numel(Global)
        if Global(i).e >= maxval(var)
            Global(i).e = maxval(var);
            Global(i).tag;
        end
    end
    
    figure('color','white','Name','Emissions per unit land')
    axesm('MapProjection','eckert4'); % Eckert IV projection
    framem on; gridm off; mlabel off; plabel off; % Turn off the labels
    framem('FlineWidth',0.01,'FEdgeColor','black')
    title('Emissions per unit land')
    setm(gca,'FLatLimit',[-60 83],'FLonLimit',[-174 186],'MapLonLimit',[-174 186],'Origin',[],...
        'FFaceColor',[0.80 0.80 0.86]);
    
    MapColor = makesymbolspec('Polygon', {'e', [minval(var) maxval(var)], 'FaceColor',...
        MyColor, 'EdgeColor', MyColor, 'LineWidth', 0.001});
    geoshow(Global, 'DisplayType', 'polygon','SymbolSpec', MapColor);
    
    caxis([minval(var) maxval(var)])
    colormap (MyColor)
    colorbar
    
    print(gcf,'-depsc','-painters', '-r200', strcat(FigurePath,'/Figure [Map_e]'));
    
end %if makeplot


%% Panel x (f - Emissions per unit ag prod) = variable 4

% Cap colorscale
var=4;
makeplot=1;
MyColor = flipud(RedMap);

if makeplot==1
    
    % Bound colorscale and reset values in Global
    for i = 1:numel(Global)
        if Global(i).f <= minval(var)
            Global(i).f = minval(var);
            Global(i).tag;
        end
    end
    for i = 1:numel(Global)
        if Global(i).f >= maxval(var)
            Global(i).f = maxval(var);
            Global(i).tag;
        end
    end
    
    figure('color','white','Name','Emissions per unit ag prod')
    axesm('MapProjection','eckert4'); % Eckert IV projection
    framem on; gridm off; mlabel off; plabel off; % Turn off the labels
    framem('FlineWidth',0.01,'FEdgeColor','black')
    title('Emissions per unit ag prod')
    setm(gca,'FLatLimit',[-60 83],'FLonLimit',[-174 186],'MapLonLimit',[-174 186],'Origin',[],...
        'FFaceColor',[0.80 0.80 0.86]);
    
    MapColor = makesymbolspec('Polygon', {'f', [minval(var) maxval(var)], 'FaceColor',...
        MyColor, 'EdgeColor', MyColor, 'LineWidth', 0.001});
    geoshow(Global, 'DisplayType', 'polygon','SymbolSpec', MapColor);
    
    caxis([minval(var) maxval(var)])
    colormap (MyColor)
    colorbar
    
    print(gcf,'-depsc','-painters', '-r200', strcat(FigurePath,'/Figure [Map_f]'));
    
end %if makeplot

close all
