%% LUE_Mainline.m SCRIPT

% Reads in and organizes LUC emissions from BLUE and AG emissions from raw FAO data
% into master matrices named 'AEMatrix' and 'Drivers'
% Chaopeng Hong et al. 2020

%% Initialize key vars and set any switches 
clear all

disp('Initializing...')
Years = 1961:2017; 
numprocesses = 12;
GWP = 100; %'100' sets to 100-year time horizon potentials, '20' to 20-year time horizon...

if GWP==100
    % Set Global Warming Potentials to AR5 100-year
    CH4_GWP = 34;
    N2O_GWP = 298;
end
if GWP==20
    % Set Global Warming Potentials to AR5 20-year
    CH4_GWP = 86;
    N2O_GWP = 268;
end

BLUEmode = 'Cycle'; % options: 'Cycle','Committed','Uniform'
AllocationMethod = 'area'; % options: 'area','production','calory','production_change','area_change'
BLUEscenario = 'Base';

DataPath = '../Data';
addpath(DataPath);
addpath([DataPath '/FAOdata']);
addpath([DataPath '/BLUE']);

%% Read in FAO codes

disp('Reading in FAO data...')

[countryCodes,countryNames] = codes.country;
[cropCodes, cropNames] = codes.crops;
[livestockCodes,livestockNames] = codes.livestock; 
[livestockprodCodes,livestockprodNames] = codes.livestockprods; 
[livestockprodCodes2,livestockprodNames2] = codes.livestockprods2; 
[forestprodCodes,forestprodNames] = codes.forestprods; 

allCodes = [cropCodes ; livestockCodes ; forestprodCodes]; 
allNames = [cropNames; livestockNames ; forestprodNames]; 
prodCodes = [cropCodes ; livestockprodCodes  ; forestprodCodes];
prodNames = [cropNames ; livestockprodNames ; forestprodNames];
prodCodes2 = [cropCodes ; livestockprodCodes2  ; forestprodCodes];
prodNames2 = [cropNames ; livestockprodNames2 ; forestprodNames];

ProdGroupNames = {'Wood','Pork','Beef','Chicken','Other Meat','Dairy','Cereals','Veg','Fruit','Pulses','Oil Crops','Fiber','Spices','Sugar'};
RegionNames = {'Europe and Russia','Oceania','North America','Latin America','East Asia','Southeast Asia','South Asia','sub-Saharan Africa','Middle East','World'};
GasNames = {'CO2','CH4','N2O'};
ProcessNames = {'LUC-Crops','LUC-Pasture','LUC-Forest','Fertilizer','Enteric Ferm.','Manure Management','Rice','Manure-Soil','Manure-Pasture','Residues','Burning','Peatland'};
DriversNames = {'Population [1000]','Ag Production [t]','Wood Production [m3]','Crop Area [ha]','Livestock Head','Pasture Area [ha]','Forest Area [ha]','Ag Production [kcal]','Ag Production [$]','Livestock Area [ha]'};


%% GET FAO DATA (Drivers)

% if raw=1, readFAO.m code will read raw files from FAO (assuming all commas ...
% have been removed and the lastFAOyear var is correctly specified)
raw=1;
lastFAOyear=2017;

% Population Data from FAO in 1000's people
EoI=511; %total population, both sexes, in thousands; EoI: placeholder FAO Element of Interest
[F1_Population,countries,codes] = readFAO('Population_E_All_Data.csv',raw,lastFAOyear,EoI);
F1_Population = squeeze(reorder(F1_Population,countries,countryCodes));
F1_Population = NanCheck(F1_Population(:,1:size(Years,2))); %Nancheck and cut off extra years...

% Crop Production, in metric tons
EoI=5510; %crop production
[CropProduction,countries,codes]  = readFAO('Production_Crops_E_All_Data.csv',raw,lastFAOyear,EoI);
CropProduction = reorder(CropProduction,countries,countryCodes); 
CropProduction = reorder(CropProduction,codes,allCodes);
CropProduction = NanCheck(CropProduction(:,:,1:size(Years,2)));

% Livestock Production in metric tons
EoI=5510; %livestock production, tons
[LivestockProduction,countries,lscodes]  = readFAO('Production_LivestockPrimary_E_All_Data.csv',raw,lastFAOyear,EoI);
LivestockProduction = reorder(LivestockProduction,countries,countryCodes); 
LivestockProduction = reorder(LivestockProduction,lscodes,prodCodes);
LivestockProduction = NanCheck(LivestockProduction(:,:,1:size(Years,2)));

% Combine Crop and Livestock Production
F2_AgProduction = CropProduction + LivestockProduction;

% Wood Production in cubic meters
EoI=5516; %production, cubic meters
[WoodProduction,countries,codes]  = readFAO('Forestry_E_All_Data.csv',raw,lastFAOyear,EoI);
WoodProduction = reorder(WoodProduction,countries,countryCodes); 
WoodProduction = reorder(WoodProduction,codes,prodCodes);
F3_ForestryProduction = NanCheck(WoodProduction(:,:,1:size(Years,2))); %Nancheck and cut off extra years...

% Crop Area Harvested in hectares
EoI=5312; %area harvested
[F4_CropArea,countries,codes]  = readFAO('Production_Crops_E_All_Data.csv',raw,lastFAOyear,EoI);
F4_CropArea = reorder(F4_CropArea,countries,countryCodes); 
F4_CropArea = reorder(F4_CropArea,codes,allCodes);
F4_CropArea = NanCheck(F4_CropArea(:,:,1:size(Years,2)));

% Land Area in thousands of hectares
EoI=5110; 
[LandArea,countries,landcodes]  = readFAO('Inputs_Land_E_All_Data.csv',raw,lastFAOyear,EoI);
LandArea = reorder(LandArea,countries,countryCodes);
for i=1:size(landcodes,1)
    if landcodes(i,1) == 6655 %Permanent meadows and pastures
        pastureindex = i;
    end
    if landcodes(i,1) == 6663 %Forest
        forestindex = i;
    end
end 

% Pasture Area in hectares
F6_PastureArea = squeeze(LandArea(:,pastureindex,:)) .* 1e3; %convert from thousands of hectares to hectares
F6_PastureArea = NanCheck(F6_PastureArea(:,1:size(Years,2)));

% Forest Area in hectares
F7_ForestArea = squeeze(LandArea(:,forestindex,:)) .* 1e3; %convert from thousands of hectares to hectares
F7_ForestArea = NanCheck(F7_ForestArea(:,1:size(Years,2)));

% Livestock Head
EoI=5320; %livestock production, head
[temp1,countries,lscodes]  = readFAO('Production_LivestockPrimary_E_All_Data.csv',raw,lastFAOyear,EoI);
temp1 = reorder(temp1,countries,countryCodes); 
temp1 = reorder(temp1,lscodes,prodCodes); 
EoI=5313; %layers, 1000 head
[temp2,countries,lscodes]  = readFAO('Production_LivestockPrimary_E_All_Data.csv',raw,lastFAOyear,EoI);
temp2 = reorder(temp2,countries,countryCodes); 
temp2 = reorder(temp2,lscodes,prodCodes); 
EoI=5321; %broilers, 1000 head
[temp3,countries,lscodes]  = readFAO('Production_LivestockPrimary_E_All_Data.csv',raw,lastFAOyear,EoI);
temp3 = reorder(temp3,countries,countryCodes); 
temp3 = reorder(temp3,lscodes,prodCodes); 
EoI=5318; %milk animals, head
[temp4,countries,lscodes]  = readFAO('Production_LivestockPrimary_E_All_Data.csv',raw,lastFAOyear,EoI);
temp4 = reorder(temp4,countries,countryCodes); 
temp4 = reorder(temp4,lscodes,prodCodes); 
F5_LivestockHead = temp1 + temp2 + temp3 + temp4;
F5_LivestockHead = NanCheck(F5_LivestockHead(:,:,1:size(Years,2)));

% calculate areas occupied by different livestock types using livestock density
load('OtherDataset.mat','LivestockDensities')
F6_LivestockArea = zeros(size(F5_LivestockHead));
for type = 162:168 % layers, broilers, dairy cows, sheep and goats, non-dairy cows, buffaloes, pigs
    for reg = 1:size(F5_LivestockHead,1)
        for yr = 1:size(F5_LivestockHead,3)
            F6_LivestockArea(reg,type,yr) = F5_LivestockHead(reg,type,yr) ./  LivestockDensities(reg,type).* 100; % convert from square km to hectares
        end
    end
end
% adjusted to match national pasture areas from the FAO
F6_LivestockArea = NanCheck(F6_LivestockArea.*permute(repmat(F6_PastureArea./squeeze(sum(F6_LivestockArea,2)),[1,1,size(F6_LivestockArea,2)]),[1,3,2]));

% Lookup my item category codes
[~,~,InRaw] = xlsread('FAO_Codebooks.xls','item_category_key');
ItemLookup=[];
%1 is FAO item code
ItemLookup(:,1) = cell2mat(InRaw(:,2));
%2 is item category code assignments (1-14, see ProdGroupNames)
ItemLookup(:,2) = cell2mat(InRaw(:,3));
Item_calories = cell2mat(InRaw(:,5)); %kcal per 100 grams
prod_categoryCodes=[];
for p=1:size(prodCodes,1) %countries
    for lookloop=1:size(ItemLookup,1)
        if prodCodes(p,1)==ItemLookup(lookloop,1)
            prod_categoryCodes(p,1) = ItemLookup(lookloop,2);
        end
    end
end

% Calculate the nutritional content (calories) of agricultural production
F8_AgProduction_kcal = zeros(size(F2_AgProduction));
CropProduction_kcal = zeros(size(CropProduction));
LivestockProduction_kcal = zeros(size(LivestockProduction));
for i=1:size(F2_AgProduction,2) %by item
    %1e6 grams per ton, and Item_calories in units of kcal/100 grams
    F8_AgProduction_kcal(:,i,:) = F2_AgProduction(:,i,:) .* Item_calories(i) .* 1e4; 
    CropProduction_kcal(:,i,:) = CropProduction(:,i,:) .* Item_calories(i) .* 1e4; 
    LivestockProduction_kcal(:,i,:) = LivestockProduction(:,i,:) .* Item_calories(i) .* 1e4; 
end

% Value of Production, in thousands of constant intl dollars
EoI=152; %Gross Production Value (constant 2004-2006 1000s of I$)
[ValueProduction,countries,codes]  = readFAO('Value_of_Production_E_All_Data.csv',raw,lastFAOyear,EoI); %k$
ValueProduction = reorder(ValueProduction,countries,countryCodes); 
ValueProduction = reorder(ValueProduction,codes,prodCodes2);
ValueProduction = NanCheck(ValueProduction(:,:,1:size(Years,2)) .* 1e3); %convert to straight up dollars
F9_AgProduction_dollars = ValueProduction;


% Calculate changes in area/production
CropArea = F4_CropArea;
PastureArea = F6_PastureArea;
LivestockArea = F6_LivestockArea;
WoodArea = F7_ForestArea;

CropArea_Chg = cat(3,CropArea(:,:,1), diff(CropArea,1,3)); 
CropProduction_Chg = cat(3,CropProduction(:,:,1), diff(CropProduction,1,3)); 
LivestockArea_Chg = cat(3,LivestockArea(:,:,1), diff(LivestockArea,1,3)); 
LivestockProduction_Chg = cat(3,LivestockProduction(:,:,1), diff(LivestockProduction,1,3)); 
CropArea_Chg(CropArea_Chg<0) = 0;
CropProduction_Chg(CropProduction_Chg<0) = 0;
LivestockArea_Chg(LivestockArea_Chg<0) = 0;
LivestockProduction_Chg(LivestockProduction_Chg<0) = 0;

% Lookup Herrero region codes
[~,~,InRaw] = xlsread('FAO_Codebooks.xls','LS_region_key');
Lookup(:,1) = cell2mat(InRaw(:,2)); % FAO country code
Lookup(:,2) = cell2mat(InRaw(:,3)); % Herrero region code assignments (SJD assigned)
for c=1:size(countryCodes,1)
    for lookloop=1:size(Lookup,1)
        if countryCodes(c,1)==Lookup(lookloop,1)
            regionCodes(c,1) = Lookup(lookloop,2);
        end
    end
end

save ([DataPath '/Basics.mat'],'Years','allCodes','prodCodes','livestockCodes','LivestockProduction','LivestockProduction_kcal','LivestockProduction_Chg','F5_LivestockHead',...
    'CropProduction','CropProduction_kcal','CropProduction_Chg','CropArea','CropArea_Chg','PastureArea','LivestockArea','LivestockArea_Chg','WoodProduction','WoodArea','countryCodes','F2_AgProduction','ProcessNames','GasNames','RegionNames','ProdGroupNames');


%% Create Master 'Drivers' Matrix

disp('Building "Drivers" matrix...')

Drivers = zeros(size(countryCodes,1),size(Years,2),size(prodCodes,1),7);
% Dimensions: 1,Countries; 2,Years; 3,FAO Items; 4,Factors

Drivers(:,:,1,1) = squeeze(F1_Population); %factor 1=population in thousands of people
Drivers(:,:,:,2) = permute(F2_AgProduction,[1,3,2]); %factor 2=production in metric tons
Drivers(:,:,:,3) = permute(F3_ForestryProduction,[1,3,2]); %factor 3=production in m^3
Drivers(:,:,:,4) = permute(F4_CropArea,[1,3,2]); %factor 4=crop area harvested in hectares
Drivers(:,:,:,5) = permute(F5_LivestockHead,[1,3,2]); %factor 5=head of livestock in absolute numbers
Drivers(:,:,1,6) = F6_PastureArea; %factor 6=Pasture area in hectares
Drivers(:,:,:,10) = permute(F6_LivestockArea,[1,3,2]);
Drivers(:,:,1,7) = F7_ForestArea; %factor 7=Forested area in hectares
Drivers(:,:,:,8) = permute(F8_AgProduction_kcal,[1,3,2]); %factor 8=production in kilocalories
Drivers(:,:,:,9) = permute(F9_AgProduction_dollars,[1,3,2]); %factor 9=production in constant international dollars


%% GET BLUE DATA (LUC Emissions)

disp('Reading in BLUE data...')

load(['BLUE_' BLUEscenario '.mat'],['LUCems_BLUE_' lower(BLUEmode)])
eval(['LUCems_BLUE = LUCems_BLUE_' lower(BLUEmode) ';'])
load('peat-emissions.mat','LUCems_Peat')

% Process 1: Clearing for Crops
P1_LUCems_crops = LUCems_BLUE(:,:,1);
P1_LUCems_crops = permute(P1_LUCems_crops,[1,3,2]);

% Process 2: Clearing for Pasture
P2_LUCems_pasture = LUCems_BLUE(:,:,2);
P2_LUCems_pasture = permute(P2_LUCems_pasture,[1,3,2]);

% Process 3: Wood Harvest minus Regrowth on Abandoned Land
P3_LUCems_wood = LUCems_BLUE(:,:,3);
P3_LUCems_wood = permute(P3_LUCems_wood,[1,3,2]);

% Process 12: Peat emissions
P12_LUCems_peat = LUCems_Peat;


%% Now Allocate LUCems to specific FAO items...

disp('Re-allocating emissions related to LUC to related products...')

%LUCems from cropland to Crops
type = 'crops';
method = AllocationMethod;
P1_LUCems_crops = allocate(P1_LUCems_crops,type,method);

%LUCems from pasture to Livestock
type = 'livestock';
method = AllocationMethod;
P2_LUCems_pasture = allocate(P2_LUCems_pasture,type,method);

%LUCems from forestry to Wood
type = 'wood';
method = 'production';
P3_LUCems_wood = allocate(P3_LUCems_wood,type,method);

%LUCems from peat
type = 'crops';
method = AllocationMethod;
P12_LUCems_peat = allocate(P12_LUCems_peat,type,method);


%% Import AG Emissions Data (from the FAOSTAT Website)

disp('Reading in FAO agricultural emissions data...')

% Ag Emissions are in gigagrams 
Gg_to_Gt = 1e-6; %convert Gg to Gt

% Process 4: Fertilizer N2O
EoI=72303; %N2O Emissions from synthetic fertilizers
[P4_AGems_fertilizer,countries,codes]  = readFAO('Emissions_Agriculture_Synthetic_Fertilizers_E_All_Data.csv',raw,lastFAOyear,EoI);
P4_AGems_fertilizer = reorder(P4_AGems_fertilizer,countries,countryCodes);
P4_AGems_fertilizer = NanCheck(P4_AGems_fertilizer(:,:,1:size(Years,2))) .* Gg_to_Gt; %trim to latest BLUE year...
% Allocate fertilizer emissions to specific FAO items based on crop-specific fertilizer consumption data
type = 'crops';
method = 'fertilizer';
P4_AGems_fertilizer = allocate(P4_AGems_fertilizer,type,method);

% Process 5: Enteric Fermentation CH4
EoI=72254; %CH4 Emissions from enteric fermentation
[P5_AGems_enteric,countries,codes]  = readFAO('Emissions_Agriculture_Enteric_Fermentation_E_All_Data.csv',raw,lastFAOyear,EoI);
P5_AGems_enteric = reorder(P5_AGems_enteric,countries,countryCodes);
P5_AGems_enteric = reorder(P5_AGems_enteric,codes,allCodes);
P5_AGems_enteric = NanCheck(P5_AGems_enteric(:,:,1:size(Years,2)))  .* Gg_to_Gt;

% Process 6: Manure Management CH4 
EoI=72256; %CH4 Emissions from manure management
[P6_AGems_manure_CH4,countries,codes]  = readFAO('Emissions_Agriculture_Manure_Management_E_All_Data.csv',raw,lastFAOyear,EoI);
P6_AGems_manure_CH4 = reorder(P6_AGems_manure_CH4,countries,countryCodes);
P6_AGems_manure_CH4 = reorder(P6_AGems_manure_CH4,codes,allCodes);
P6_AGems_manure_CH4 = NanCheck(P6_AGems_manure_CH4(:,:,1:size(Years,2)))  .* Gg_to_Gt;

% Process 6: Manure Management N2O 
EoI=72306; %N2O Emissions from manure management
[P6_AGems_manure_N2O,countries,codes]  = readFAO('Emissions_Agriculture_Manure_Management_E_All_Data.csv',raw,lastFAOyear,EoI);
P6_AGems_manure_N2O = reorder(P6_AGems_manure_N2O,countries,countryCodes);
P6_AGems_manure_N2O = reorder(P6_AGems_manure_N2O,codes,allCodes);
P6_AGems_manure_N2O = NanCheck(P6_AGems_manure_N2O(:,:,1:size(Years,2)))  .* Gg_to_Gt;

% Process 7: Rice Cultivation CH4 
EoI=72255; %CH4 Emissions from rice agriculture
[P7_AGems_rice,countries,codes]  = readFAO('Emissions_Agriculture_Rice_Cultivation_E_All_Data.csv',raw,lastFAOyear,EoI);
P7_AGems_rice = reorder(P7_AGems_rice,countries,countryCodes);
P7_AGems_rice = reorder(P7_AGems_rice,codes,allCodes);
P7_AGems_rice = NanCheck(P7_AGems_rice(:,:,1:size(Years,2)))  .* Gg_to_Gt;

% Process 8: Manure Applied to Soils N2O
EoI=72301; %N2O Emissions from manure applied to soils
[P8_AGems_manuresoil,countries,codes]  = readFAO('Emissions_Agriculture_Manure_applied_to_soils_E_All_Data.csv',raw,lastFAOyear,EoI);
P8_AGems_manuresoil = reorder(P8_AGems_manuresoil,countries,countryCodes);
P8_AGems_manuresoil = reorder(P8_AGems_manuresoil,codes,allCodes);
P8_AGems_manuresoil = NanCheck(P8_AGems_manuresoil(:,:,1:size(Years,2))) .* Gg_to_Gt;

% Process 9: Manure Left in Pasture N2O
EoI=72300; %N2O Emissions from manure left in pasture
[P9_AGems_manurepasture,countries,codes]  = readFAO('Emissions_Agriculture_Manure_left_on_pasture_E_All_Data.csv',raw,lastFAOyear,EoI);
P9_AGems_manurepasture = reorder(P9_AGems_manurepasture,countries,countryCodes);
P9_AGems_manurepasture = reorder(P9_AGems_manurepasture,codes,allCodes);
P9_AGems_manurepasture = NanCheck(P9_AGems_manurepasture(:,:,1:size(Years,2))) .* Gg_to_Gt;

% Process 10: Crop Residues N2O
EoI=72302; %N2O Emissions from crop residues
[P10_AGems_residues,countries,codes]  = readFAO('Emissions_Agriculture_Crop_Residues_E_All_Data.csv',raw,lastFAOyear,EoI);
P10_AGems_residues = reorder(P10_AGems_residues,countries,countryCodes);
P10_AGems_residues = reorder(P10_AGems_residues,codes,allCodes);
P10_AGems_residues = NanCheck(P10_AGems_residues(:,:,1:size(Years,2))) .* Gg_to_Gt;

% Process 11: Burning crop residues N2O
EoI=72307; %N2O Emissions from burning crop residues
[P11_AGems_burnresid_N2O,countries,codes]  = readFAO('Emissions_Agriculture_Burning_crop_residues_E_All_Data.csv',raw,lastFAOyear,EoI);
P11_AGems_burnresid_N2O = reorder(P11_AGems_burnresid_N2O,countries,countryCodes);
P11_AGems_burnresid_N2O = reorder(P11_AGems_burnresid_N2O,codes,allCodes);
P11_AGems_burnresid_N2O = NanCheck(P11_AGems_burnresid_N2O(:,:,1:size(Years,2))) .* Gg_to_Gt;

% Process 11: Burning crop residues CH4 
EoI=72257; %CH4 Emissions from burning crop residues
[P11_AGems_burnresid_CH4,countries,codes]  = readFAO('Emissions_Agriculture_Burning_crop_residues_E_All_Data.csv',raw,lastFAOyear,EoI);
P11_AGems_burnresid_CH4 = reorder(P11_AGems_burnresid_CH4,countries,countryCodes);
P11_AGems_burnresid_CH4 = reorder(P11_AGems_burnresid_CH4,codes,allCodes);
P11_AGems_burnresid_CH4 = NanCheck(P11_AGems_burnresid_CH4(:,:,1:size(Years,2))) .* Gg_to_Gt;


%% Create All-encompassing Matrix of Emissions in CO2eq

disp('Building "AEMatrix"...')
AEMatrix = zeros(size(countryCodes,1),size(Years,2),numprocesses,size(allCodes,1),3);
% Dimensions: 1,Countries; 2,Years; 3,Processes; 4,FAO Items; 5,GHGs

%Assign LUC Ems (all in Gt CO2)
AEMatrix(:,:,1,:,1) = permute(P1_LUCems_crops,[1,3,2]); %process 1=clearing for crops
AEMatrix(:,:,2,:,1) = permute(P2_LUCems_pasture,[1,3,2]);  %process 2=clearing for pasture
AEMatrix(:,:,3,:,1) = permute(P3_LUCems_wood,[1,3,2]);  %process 3=wood harvest less abandonment
AEMatrix(:,:,12,:,1) = permute(P12_LUCems_peat,[1,3,2]); %process 12=peat

%Assign Ag Ems (convert from Gt CH4 or N2O to Gt CO2)
AEMatrix(:,:,4,:,3) = permute(P4_AGems_fertilizer,[1,3,2]) .* N2O_GWP; %process 4=nitrogen fertilizer application
AEMatrix(:,:,5,:,2) = permute(P5_AGems_enteric,[1,3,2]) .* CH4_GWP;  %process 5=livestock enteric fermentation
AEMatrix(:,:,6,:,2) = permute(P6_AGems_manure_CH4,[1,3,2]) .* CH4_GWP;  %process 6=manure mgmt CH4
AEMatrix(:,:,6,:,3) = permute(P6_AGems_manure_N2O,[1,3,2]) .* N2O_GWP; %process 6=manure mgmt N2O
AEMatrix(:,:,7,:,2) = permute(P7_AGems_rice,[1,3,2]) .* CH4_GWP;  %process 7=rice CH4
AEMatrix(:,:,8,:,3) = permute(P8_AGems_manuresoil,[1,3,2]).* N2O_GWP;  %process 8=manure soil ems
AEMatrix(:,:,9,:,3) = permute(P9_AGems_manurepasture,[1,3,2]) .* N2O_GWP;  %process 9=pasture soil ems
AEMatrix(:,:,10,:,3) = permute(P10_AGems_residues,[1,3,2]) .* N2O_GWP;  %process 10=crop res ems
AEMatrix(:,:,11,:,3) = permute(P11_AGems_burnresid_N2O,[1,3,2]) .* N2O_GWP;  %process 11=burning N2O
AEMatrix(:,:,11,:,2) = permute(P11_AGems_burnresid_CH4,[1,3,2]) .* CH4_GWP;  %process 11=burning CH4

save ([DataPath '/AEMatrix_' lower(BLUEmode) '.mat'],'AEMatrix','Drivers','Years','countryNames','countryCodes','allNames','prodCodes','ProcessNames','GasNames','regionCodes','RegionNames','prod_categoryCodes','ProdGroupNames','DriversNames')
% save ([DataPath '/AEMatrix_' lower(BLUEmode) '_' AllocationMethod '.mat'],'AEMatrix','Drivers','Years','countryNames','countryCodes','allNames','prodCodes','ProcessNames','GasNames','regionCodes','RegionNames','prod_categoryCodes','ProdGroupNames','DriversNames')
