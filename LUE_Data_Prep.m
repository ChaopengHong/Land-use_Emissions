%% LUE_Data_Prep.m SCRIPT

% Prepares data for figures and files
% Takes model output and exports mat and excel files for figure-making and data-sharing
% Chaopeng Hong et al. 2020

%% Load in Data
clear

DataPath = '../Data';
OutMatFile = [DataPath '/LUE_Data.mat'];
OutExcelFile = [DataPath '/LUE_Data.xlsx'];

load([DataPath '/AEMatrix_cycle.mat'])

% AEMatrix (Emissions Matrix): 1,Countries; 2,Years; 3,Processes; 4,Products; 5,GHGs
% Drivers: 1,Countries; 2,Years; 3,Products; 4,Factors
ncountry = size(AEMatrix,1);
nyear = size(AEMatrix,2);
nprocess = size(AEMatrix,3);
nproduct = size(AEMatrix,4);
ngas = size(AEMatrix,5);
ndriver = size(Drivers,4);
nprodgroup = length(ProdGroupNames);
nregion = length(RegionNames);

load([DataPath '/AEMatrix_cycle_wFeed.mat'])
load([DataPath '/AEMatrix_cycle_GWP.mat'])
load([DataPath '/AEMatrix_MC_Accountings.mat'])
load([DataPath '/AEMatrix_cycle_MC_All.mat'])
load([DataPath '/AEMatrix_MC_Ag.mat'])
load([DataPath '/BLUE/BLUE_Sensitivity.mat'])
load([DataPath '/OtherDataset.mat'])
load([DataPath '/AEMatrix_cycle.mat'])

%% Country Totals
% Create Product Group Aggregates
AEMatrix_PGroup = zeros(ncountry,nyear,nprocess,nprodgroup,ngas);
Drivers_PGroup = zeros(ncountry,nyear,nprodgroup,ndriver);
for m=1:nprodgroup
    for i=1:nproduct
        if prod_categoryCodes(i) == m % Product aggregations - in prod_categoryCodes
            AEMatrix_PGroup(:,:,:,m,:) = AEMatrix_PGroup(:,:,:,m,:) + AEMatrix(:,:,:,i,:);
            Drivers_PGroup(:,:,m,:) = Drivers_PGroup(:,:,m,:) + Drivers(:,:,i,:);
        end
    end
end

% Population (P): people
P_country = sumDims(Drivers(:,:,:,1),3)*1000;
% Production (A): kilocalories
A_country_by_Product = squeeze(Drivers(:,:,:,8));
A_country_by_PGroup = squeeze(Drivers_PGroup(:,:,:,8));
A_country = sumDims(A_country_by_Product,3);
% Land (L): hectares (crop area + pasture area)
L_country_by_Product = squeeze(Drivers(:,:,:,4) + Drivers(:,:,:,10));
L_country_by_PGroup = squeeze(Drivers_PGroup(:,:,:,4) + Drivers_PGroup(:,:,:,10));
L_country = sumDims(L_country_by_Product,3);
% Emissions (E): Gt CO2eq
E_country = sumDims(AEMatrix,[3,4,5]);
E_country_by_GHG = sumDims(AEMatrix,[3,4]); 
E_country_by_Process = sumDims(AEMatrix,[4,5]);
E_country_by_Product = sumDims(AEMatrix,[3,5]);
E_country_by_PGroup = sumDims(AEMatrix_PGroup,[3,5]);

a_country = NanCheck(A_country./P_country);
l_country = NanCheck(L_country./A_country);
e_country = NanCheck(E_country./L_country);
f_country = NanCheck(E_country./A_country);

a_country_by_Product = NanCheck(A_country_by_Product./repmat(P_country,[1,1,nproduct]));
l_country_by_Product = NanCheck(L_country_by_Product./A_country_by_Product);
e_country_by_Product = NanCheck(E_country_by_Product./L_country_by_Product);
f_country_by_Product = NanCheck(E_country_by_Product./A_country_by_Product);

%% Regional Totals
% Create Regional Aggregates
Regional_AEMatrix = zeros(nregion,nyear,nprocess,nproduct,ngas);
Regional_Drivers = zeros(nregion,nyear,nproduct,ndriver);
Regional_AEMatrix(end,:,:,:,:) = sum(AEMatrix,1); % last region is global total
Regional_Drivers(end,:,:,:) = sum(Drivers,1);
for n=1:nregion-1
    for i=1:ncountry
        if regionCodes(i) == n % Regional aggregations - in regionCodes
            Regional_AEMatrix(n,:,:,:,:) = Regional_AEMatrix(n,:,:,:,:) + AEMatrix(i,:,:,:,:);
            Regional_Drivers(n,:,:,:) = Regional_Drivers(n,:,:,:) + Drivers(i,:,:,:);
        end
    end
end
% Create Product Group Aggregates
Regional_AEMatrix_PGroup = zeros(nregion,nyear,nprocess,nprodgroup,ngas);
Regional_Drivers_PGroup = zeros(nregion,nyear,nprodgroup,size(Drivers,4));
for m=1:nprodgroup
    for i=1:nproduct
        if prod_categoryCodes(i) == m
            Regional_AEMatrix_PGroup(:,:,:,m,:) = Regional_AEMatrix_PGroup(:,:,:,m,:) + Regional_AEMatrix(:,:,:,i,:);
            Regional_Drivers_PGroup(:,:,m,:) = Regional_Drivers_PGroup(:,:,m,:) + Regional_Drivers(:,:,i,:);
        end
    end
end

% Population (P): people
P_reg = sumDims(Regional_Drivers(:,:,:,1),3)*1000;
% Production (A): kilocalories
A_reg_by_Product = squeeze(Regional_Drivers(:,:,:,8));
A_reg_by_PGroup = squeeze(Regional_Drivers_PGroup(:,:,:,8));
A_reg = sumDims(A_reg_by_Product,3);
% Land (L): hectares (crop area + pasture area)
L_reg_by_Product = squeeze(Regional_Drivers(:,:,:,4) + Regional_Drivers(:,:,:,10));
L_reg_by_PGroup = squeeze(Regional_Drivers_PGroup(:,:,:,4) + Regional_Drivers_PGroup(:,:,:,10));
L_reg = sumDims(L_reg_by_Product,3);
L_reg_Crop = sumDims(Regional_Drivers(:,:,:,4),3);
L_reg_Pasture = sumDims(Regional_Drivers(:,:,:,10),3);
% Emissions (E): Gt CO2eq
E_reg = sumDims(Regional_AEMatrix,[3,4,5]);
E_reg_by_GHG = sumDims(Regional_AEMatrix,[3,4]); 
E_reg_by_Process = sumDims(Regional_AEMatrix,[4,5]);
E_reg_by_Product = sumDims(Regional_AEMatrix,[3,5]);
E_reg_by_PGroup = sumDims(Regional_AEMatrix_PGroup,[3,5]);
E_reg_LUC = sumDims(Regional_AEMatrix(:,:,[1,2,3,12],:,:),[3,4,5]);
E_reg_Ag = sumDims(Regional_AEMatrix(:,:,4:11,:,:),[3,4,5]);

a_reg = NanCheck(A_reg./P_reg);
l_reg = NanCheck(L_reg./A_reg);
e_reg = NanCheck(E_reg./L_reg);
f_reg = NanCheck(E_reg./A_reg);


%% Data for Table 1
FF_CO2 = 35836.6; % Mt in 2017
Oth_CH4 = 7456.6; % Mt CO2-eq in 2017
Oth_N2O = 869.7; % Mt CO2-eq in 2017
E_world_by_Product_Gas = sumDims(Regional_AEMatrix_PGroup(end,end,:,:,:),[1,2,3])*1e3;
E_world_by_Product_Gas(15,:) = sum(E_world_by_Product_Gas(1:14,:),1);
E_world_by_Product_Gas(:,4) = sum(E_world_by_Product_Gas(:,1:3),2);
E_world_by_Product_Gas(:,5) = E_world_by_Product_Gas(:,4)./repmat(E_world_by_Product_Gas(15,4),[15,1]);
E_world_by_Product_Gas(:,6) = E_world_by_Product_Gas(:,4)./repmat(E_world_by_Product_Gas(15,4)+FF_CO2+Oth_CH4+Oth_N2O,[15,1]);
E_world_by_Product_Gas_MC = squeeze(AEMatrix_All_WYPgG(end,:,:,:,:))*1e3;
E_world_by_Product_Gas_MC(15,:,:,:) = sum(E_world_by_Product_Gas_MC(1:14,:,:,:),1);
E_world_by_Product_Gas_MC(:,4,:,:) = sum(E_world_by_Product_Gas_MC(:,1:3,:,:),2);
E_world_by_Product_Gas_MC(:,5,:,:) = E_world_by_Product_Gas_MC(:,4,:,:)./repmat(E_world_by_Product_Gas_MC(15,4,:,:),[15,1,1,1]);
E_world_by_Product_Gas_MC(:,6,:,:) = E_world_by_Product_Gas_MC(:,4,:,:)./(repmat(E_world_by_Product_Gas_MC(15,4,:,:),[15,1,1,1])+...
                                     permute(repmat(FF_CO2+Oth_CH4*CH4_Ranges+Oth_N2O*N2O_Ranges,[15,1,1,6]),[1,3,2,4]));
E_world_by_Product_Gas_CIs = calCIs(E_world_by_Product_Gas_MC);
E_world_by_Product_Gas_lower = squeeze(E_world_by_Product_Gas_CIs(:,:,2));
E_world_by_Product_Gas_upper = squeeze(E_world_by_Product_Gas_CIs(:,:,3));

%% Data for Figure 1 & ED4
E_reg_tmp = sumDims(Regional_AEMatrix_PGroup,[4,5]);
E_reg_by_Process_pos = E_reg_tmp;
E_reg_by_Process_pos(E_reg_by_Process_pos<0) = 0;
E_reg_by_Process_neg = E_reg_tmp;
E_reg_by_Process_neg(E_reg_by_Process_neg>0) = 0;

E_reg_tmp = sumDims(Regional_AEMatrix_PGroup,4);
E_reg_by_GHG_pos = E_reg_tmp;
E_reg_by_GHG_pos(E_reg_by_GHG_pos<0) = 0;
E_reg_by_GHG_neg = E_reg_tmp;
E_reg_by_GHG_neg(E_reg_by_GHG_neg>0) = 0;
E_reg_by_GHG_pos = sumDims(E_reg_by_GHG_pos,3);
E_reg_by_GHG_neg = sumDims(E_reg_by_GHG_neg,3);

E_reg_tmp = sumDims(Regional_AEMatrix_PGroup,5);
E_reg_by_PGroup_pos = E_reg_tmp;
E_reg_by_PGroup_pos(E_reg_by_PGroup_pos<0) = 0;
E_reg_by_PGroup_neg = E_reg_tmp;
E_reg_by_PGroup_neg(E_reg_by_PGroup_neg>0) = 0;
E_reg_by_PGroup_pos = sumDims(E_reg_by_PGroup_pos,3);
E_reg_by_PGroup_neg = sumDims(E_reg_by_PGroup_neg,3);

E_world_tmp = permute(E_reg_tmp(1:9,:,:),[2,3,1]);
E_world_by_Region_pos = E_world_tmp;
E_world_by_Region_pos(E_world_by_Region_pos<0) = 0;
E_world_by_Region_neg = E_world_tmp;
E_world_by_Region_neg(E_world_by_Region_neg>0) = 0;
E_world_by_Region_pos = sumDims(E_world_by_Region_pos,2);
E_world_by_Region_neg = sumDims(E_world_by_Region_neg,2);

%% Data for Figure 2 & ED3
e_reg_LUC = NanCheck(E_reg_LUC./L_reg);
f_reg_LUC = NanCheck(E_reg_LUC./A_reg);
e_reg_Ag = NanCheck(E_reg_Ag./L_reg);
f_reg_Ag = NanCheck(E_reg_Ag./A_reg);

LUC_Ratio = NanCheck(E_reg_LUC./E_reg);
Ag_Ratio = NanCheck(E_reg_Ag./E_reg);
LUC_Ratio(LUC_Ratio<0) = 0; % shares are of emissions only, neglecting any carbon uptake
Ag_Ratio(Ag_Ratio>1) = 1;

Change_E = E_reg./repmat(E_reg(:,1),[1,length(Years)])-1;
Change_P = P_reg./repmat(P_reg(:,1),[1,length(Years)])-1;
Change_a = a_reg./repmat(a_reg(:,1),[1,length(Years)])-1;
Change_l = l_reg./repmat(l_reg(:,1),[1,length(Years)])-1;
Change_e = e_reg./repmat(e_reg(:,1),[1,length(Years)])-1;
Change_f = f_reg./repmat(f_reg(:,1),[1,length(Years)])-1;
Change_E_LUC = E_reg_LUC./repmat(E_reg_LUC(:,1),[1,length(Years)])-1;
Change_E_Ag = E_reg_Ag./repmat(E_reg_Ag(:,1),[1,length(Years)])-1;
Change_e_LUC = e_reg_LUC./repmat(e_reg_LUC(:,1),[1,length(Years)])-1;
Change_e_Ag = e_reg_Ag./repmat(e_reg_Ag(:,1),[1,length(Years)])-1;
Change_f_LUC = f_reg_LUC./repmat(f_reg_LUC(:,1),[1,length(Years)])-1;
Change_f_Ag = f_reg_Ag./repmat(f_reg_Ag(:,1),[1,length(Years)])-1;
Change_A = A_reg./repmat(A_reg(:,1),[1,length(Years)])-1;
Change_L = L_reg./repmat(L_reg(:,1),[1,length(Years)])-1;
Change_L_Crop = L_reg_Crop./repmat(L_reg_Crop(:,1),[1,length(Years)])-1;

%% Data for Figure 4
E_country_end_CIs = calCIs(AEMatrix_All_Cend);
e_country_end_CIs = NanCheck(E_country_end_CIs./repmat(L_country(:,end),[1,3]));
f_country_end_CIs = NanCheck(E_country_end_CIs./repmat(A_country(:,end),[1,3]));
A_world_by_PGroup = squeeze(A_reg_by_PGroup(end,:,:));
E_world_by_PGroup = squeeze(E_reg_by_PGroup(end,:,:));
L_world_by_PGroup = squeeze(L_reg_by_PGroup(end,:,:));
a_world_by_PGroup = NanCheck(A_world_by_PGroup./squeeze(repmat(P_reg(end,:),[1,1,nprodgroup])));
l_world_by_PGroup = NanCheck(L_world_by_PGroup./A_world_by_PGroup);
e_world_by_PGroup = NanCheck(E_world_by_PGroup./L_world_by_PGroup);
f_world_by_PGroup = NanCheck(E_world_by_PGroup./A_world_by_PGroup);
E_world_by_PGroup_CIs = calCIs(sumDims(AEMatrix_All_WYPgG,3));
e_world_by_PGroup_CIs = NanCheck(E_world_by_PGroup_CIs./repmat(L_world_by_PGroup,[1,1,3]));
f_world_by_PGroup_CIs = NanCheck(E_world_by_PGroup_CIs./repmat(A_world_by_PGroup,[1,1,3]));
A_reg_by_PGroup_dollars = squeeze(Regional_Drivers_PGroup(:,:,:,9));
dollars_per_kcal_PGroup = NanCheck(A_reg_by_PGroup_dollars./A_reg_by_PGroup);

%% Data for Figure 5 (5-year average)
a_reg_avg = [  mean(a_reg(:,1:5),2), mean(a_reg(:,6:10),2),mean(a_reg(:,11:15),2),mean(a_reg(:,16:20),2),mean(a_reg(:,21:25),2),mean(a_reg(:,26:30),2),...
             mean(a_reg(:,31:35),2),mean(a_reg(:,36:40),2),mean(a_reg(:,41:45),2),mean(a_reg(:,46:50),2),mean(a_reg(:,51:57),2)];
f_reg_avg = [  mean(f_reg(:,1:5),2), mean(f_reg(:,6:10),2),mean(f_reg(:,11:15),2),mean(f_reg(:,16:20),2),mean(f_reg(:,21:25),2),mean(f_reg(:,26:30),2),...
             mean(f_reg(:,31:35),2),mean(f_reg(:,36:40),2),mean(f_reg(:,41:45),2),mean(f_reg(:,46:50),2),mean(f_reg(:,51:57),2)];

%% Data for Figure ED1
for iblue = 1:length(BLUEmodesNames)
    for imethod = 1:length(methods)
        eval(['E_world_by_PGroup_accounting(:,:,iblue,imethod) = calCIs(AEMatrix_All_Pg_' num2str(iblue) '_' num2str(imethod) ');'])
        eval(['E_world_by_Process_accounting(:,:,iblue,imethod) = calCIs(AEMatrix_All_Pc_' num2str(iblue) '_' num2str(imethod) ');'])
    end
end

%% Data for Figure ED5 (changes over the last decade)
E_country_by_Product_avg = squeeze(mean(E_country_by_Product(:,(end-10):end,:),2));
E_country_by_Product_chg = squeeze(E_country_by_Product(:,end,:)./E_country_by_Product(:,end-10,:)) - 1;
A_country_by_Product_chg = squeeze(A_country_by_Product(:,end,:)./A_country_by_Product(:,end-10,:)) - 1;
a_country_by_Product_chg = squeeze(a_country_by_Product(:,end,:)./a_country_by_Product(:,end-10,:)) - 1;
l_country_by_Product_chg = squeeze(l_country_by_Product(:,end,:)./l_country_by_Product(:,end-10,:)) - 1;
e_country_by_Product_chg = squeeze(e_country_by_Product(:,end,:)./e_country_by_Product(:,end-10,:)) - 1;
f_country_by_Product_chg = squeeze(f_country_by_Product(:,end,:)./f_country_by_Product(:,end-10,:)) - 1;

%% Data for Figure ED7
E_world_by_PGroup_wFeed = zeros(nyear,nprodgroup);
for m=1:nprodgroup
    for i=1:nproduct
        if prod_categoryCodes(i) == m
            E_world_by_PGroup_wFeed(:,m) = E_world_by_PGroup_wFeed(:,m) + E_world_by_Product_wFeed(:,i);
        end
    end
end

%% Data for Figure ED8
E_reg_by_GHG_nprctile = prctile(E_reg_by_GHG_ntimes,[2.5 5 10 16 25 75 84 90 95 97.5],4);
E_reg_Allgas_nprctile = prctile(sum(E_reg_by_GHG_ntimes,3),[2.5 5 10 16 25 75 84 90 95 97.5],4);
E_reg_by_GHG_mean = mean(E_reg_by_GHG_ntimes,4);

%% Data for Figure ED9
E_reg_Ag_ntimes = sumDims(AEMatrix_Ag_RgYPcG,[3,4]);
E_reg_Ag_ntimes(end+1,:,:) = sum(E_reg_Ag_ntimes(1:end,:,:),1);
E_reg_Ag_nprctile = prctile(E_reg_Ag_ntimes,[2.5 5 10 16 25 75 84 90 95 97.5],3);
E_reg_Ag_mean = mean(E_reg_Ag_ntimes,3);

%% Data for Figure ED10 & ED11
E_reg_LUC_nBLUE = squeeze(mean(sumDims(AEMatrix_All_RgYPc(:,:,[1,2,3,12],:,:),3),3));
E_reg_LUC_nBLUE(end+1,:,:) = sum(E_reg_LUC_nBLUE(1:end,:,:),1);
E_reg_nBLUE = E_reg_LUC_nBLUE + repmat(E_reg_Ag,[1,1,size(E_reg_LUC_nBLUE,3)]);
E_reg_MC = sumDims(AEMatrix_All_RgYPc,3);
E_reg_MC(end+1,:,:,:) = sum(E_reg_MC(1:end,:,:,:),1);
E_reg_CIs = calCIs(E_reg_MC);
E_reg_LUC_HN_BLUE = (E_reg_LUC_HN + E_reg_LUC(:,1:55))/2;
E_reg_HN = E_reg_LUC_HN + E_reg_Ag(:,1:55);
E_reg_HN_BLUE = E_reg_LUC_HN_BLUE + E_reg_Ag(:,1:55);

%% Data for Fig ED12
Change_E_nBLUE = E_reg_nBLUE./repmat(E_reg_nBLUE(:,1,:),[1,length(Years),1])-1;
Change_E_MC = E_reg_MC./repmat(E_reg_MC(:,1,:,:),[1,length(Years),1,1])-1;
Change_E_CIs = calCIs(Change_E_MC);
e_reg_HN_BLUE = NanCheck(E_reg_HN_BLUE./L_reg(:,1:55));
f_reg_HN_BLUE = NanCheck(E_reg_HN_BLUE./A_reg(:,1:55));
Change_E_HN_BLUE = E_reg_HN_BLUE./repmat(E_reg_HN_BLUE(:,1),[1,length(Years_HN)])-1;
Change_e_HN_BLUE = e_reg_HN_BLUE./repmat(e_reg_HN_BLUE(:,1),[1,length(Years_HN)])-1;
Change_f_HN_BLUE = f_reg_HN_BLUE./repmat(f_reg_HN_BLUE(:,1),[1,length(Years_HN)])-1;


%% Save
YearNames = cellfun(@(x){['Y' num2str(x)]},num2cell(Years));
writeTable(OutExcelFile,'1.1.LUEmis',E_reg,{'Area','Year'},RegionNames,YearNames)
writeTable(OutExcelFile,'1.2.LUEmis',permute(E_reg_by_Process,[1,3,2]),{'Area','Process','Year'},RegionNames,ProcessNames,YearNames)
writeTable(OutExcelFile,'1.3.LUEmis',permute(E_reg_by_GHG,[1,3,2]),{'Area','GHG','Year'},RegionNames,GasNames,YearNames)
writeTable(OutExcelFile,'1.4.LUEmis',permute(E_reg_by_PGroup,[1,3,2]),{'Area','Product Group','Year'},RegionNames,ProdGroupNames,YearNames)
writeTable(OutExcelFile,'1.5.LUEmis',permute(E_reg_by_Product,[1,3,2]),{'Area','Product','Year'},RegionNames,allNames,YearNames)
writeTable(OutExcelFile,'2.1.Population',P_reg,{'Area','Year'},RegionNames,YearNames)
writeTable(OutExcelFile,'3.1.AgProd',A_reg,{'Area','Year'},RegionNames,YearNames)
writeTable(OutExcelFile,'3.2.AgProd',permute(A_reg_by_PGroup,[1,3,2]),{'Area','Product Group','Year'},RegionNames,ProdGroupNames,YearNames)
writeTable(OutExcelFile,'3.3.AgProd',permute(A_reg_by_Product,[1,3,2]),{'Area','Product','Year'},RegionNames,allNames,YearNames)
writeTable(OutExcelFile,'4.1.AgLand',L_reg,{'Area','Year'},RegionNames,YearNames)
writeTable(OutExcelFile,'4.2.AgLand',permute(L_reg_by_PGroup,[1,3,2]),{'Area','Product Group','Year'},RegionNames,ProdGroupNames,YearNames)
writeTable(OutExcelFile,'4.3.AgLand',permute(L_reg_by_Product,[1,3,2]),{'Area','Product','Year'},RegionNames,allNames,YearNames)
writeTable(OutExcelFile,'5.1.a',a_reg,{'Area','Year'},RegionNames,YearNames)
writeTable(OutExcelFile,'5.2.l',l_reg,{'Area','Year'},RegionNames,YearNames)
writeTable(OutExcelFile,'5.3.e',e_reg,{'Area','Year'},RegionNames,YearNames)
writeTable(OutExcelFile,'5.4.f',f_reg,{'Area','Year'},RegionNames,YearNames)
writeTable(OutExcelFile,'6.1.LUEmis',E_country,{'Area','Year'},countryNames,YearNames)
writeTable(OutExcelFile,'6.2.LUEmis',permute(E_country_by_Process,[1,3,2]),{'Area','Process','Year'},countryNames,ProcessNames,YearNames)
writeTable(OutExcelFile,'6.3.LUEmis',permute(E_country_by_GHG,[1,3,2]),{'Area','GHG','Year'},countryNames,GasNames,YearNames)
writeTable(OutExcelFile,'6.4.LUEmis',permute(E_country_by_PGroup,[1,3,2]),{'Area','Product Group','Year'},countryNames,ProdGroupNames,YearNames)
writeTable(OutExcelFile,'6.5.LUEmis',permute(E_country_by_Product,[1,3,2]),{'Area','Product','Year'},countryNames,allNames,YearNames)
writeTable(OutExcelFile,'7.1.Population',P_country,{'Area','Year'},countryNames,YearNames)
writeTable(OutExcelFile,'8.1.AgProd',A_country,{'Area','Year'},countryNames,YearNames)
writeTable(OutExcelFile,'8.2.AgProd',permute(A_country_by_PGroup,[1,3,2]),{'Area','Product Group','Year'},countryNames,ProdGroupNames,YearNames)
writeTable(OutExcelFile,'8.3.AgProd',permute(A_country_by_Product,[1,3,2]),{'Area','Product','Year'},countryNames,allNames,YearNames)
writeTable(OutExcelFile,'9.1.AgLand',L_country,{'Area','Year'},countryNames,YearNames)
writeTable(OutExcelFile,'9.2.AgLand',permute(L_country_by_PGroup,[1,3,2]),{'Area','Product Group','Year'},countryNames,ProdGroupNames,YearNames)
writeTable(OutExcelFile,'9.3.AgLand',permute(L_country_by_Product,[1,3,2]),{'Area','Product','Year'},countryNames,allNames,YearNames)
writeTable(OutExcelFile,'10.1.a',a_country,{'Area','Year'},countryNames,YearNames)
writeTable(OutExcelFile,'10.2.l',l_country,{'Area','Year'},countryNames,YearNames)
writeTable(OutExcelFile,'10.3.e',e_country,{'Area','Year'},countryNames,YearNames)
writeTable(OutExcelFile,'10.4.f',f_country,{'Area','Year'},countryNames,YearNames)

clear AEMatrix_All_* AEMatrix_Ag_* LUCems_nBLUE_* E_reg_Ag_ntimes E_reg_by_GHG_ntimes
clear AEMatrix_wFeed E_reg_MC Change_E_MC E_reg_tmp i iblue imethod m n DataPath OutExcelFile FF_CO2 Oth_CH4 Oth_N2O
clear AEMatrix Drivers AEMatrix_PGroup Drivers_PGroup Regional_AEMatrix Regional_Drivers Regional_AEMatrix_PGroup Regional_Drivers_PGroup
save(OutMatFile)
