function [UsageAnnualTable,waterMoProfile,GallonsCost]=waterResults(obj)
%annual array
%find the annual totals for each year in each column in water data,
%as well as the annual average, and the percent of total usage & cost
%array has 5 rows and is constructed for 3 years of data even if
%only 1 or 2 years has been supplied in the inputs. empty rows removed
%in later processing
%rows 1 to 3: annual totals each year each column,
%row 4: average, row 5: fraction of total usage

%annual total gallons, col 1
gallonsAnnl = [sum(obj.UsageTable.gallons(1:12)) sum(obj.UsageTable.gallons(13:24), 'omitnan') ...
    sum(obj.UsageTable.gallons(25:36), 'omitnan')]';
gallonsAnnl(4) = sum(gallonsAnnl(1:3) .* (gallonsAnnl(1:3) ~= 0)) / ...
    sum((gallonsAnnl(1:3) ~= 0));
gallonsAnnl(5) = NaN;
%adjusted use, should equal total annual gallons, col 2
adjUseAnnl = [sum(obj.UsageTable.adjGallons(1:12)) sum(obj.UsageTable.adjGallons(13:24), ...
    'omitnan') sum(obj.UsageTable.adjGallons(25:36), 'omitnan')]';
adjUseAnnl(4) = sum(adjUseAnnl(1:3) .* (adjUseAnnl(1:3) ~= 0)) / sum((adjUseAnnl(1:3) ~= 0));
adjUseAnnl(5) = adjUseAnnl(4) / gallonsAnnl(4);
%irrigation col 3
irrigation = [sum(obj.UsageTable.IrrigationGal(1:12)) sum(obj.UsageTable.IrrigationGal(13:24), ...
    'omitnan') sum(obj.UsageTable.IrrigationGal(25:36), 'omitnan')]';
irrigation(4) = sum(irrigation(1:3) .* (irrigation(1:3) ~= 0)) / sum((irrigation(1:3) ~= 0));
irrigation(5) = irrigation(4) / gallonsAnnl(4);
%cooling tower col 4
coolingTower = [sum(obj.UsageTable.CoolingTowerGal(1:12)) sum(obj.UsageTable.CoolingTowerGal(13:24), ...
    'omitnan') sum(obj.UsageTable.CoolingTowerGal(25:36), 'omitnan')]';
coolingTower(4) = sum(coolingTower(1:3) .* (coolingTower(1:3) ~= 0)) / sum((coolingTower(1:3) ~= 0));
coolingTower(5) = coolingTower(4) / gallonsAnnl(4);
%otherUses col 5
otherUses = [sum(obj.UsageTable.OtherGal(1:12)) sum(obj.UsageTable.OtherGal(13:24), ...
    'omitnan') sum(obj.UsageTable.OtherGal(25:36), 'omitnan')]';
otherUses(4) = sum(otherUses(1:3) .* (otherUses(1:3) ~= 0)) / sum((otherUses(1:3) ~= 0));
otherUses(5) = otherUses(4)/gallonsAnnl(4);
%residential col 6
residential = [sum(obj.UsageTable.ResidentialGal(1:12)) sum(obj.UsageTable.ResidentialGal(13:24), ...
    'omitnan') sum(obj.UsageTable.ResidentialGal(25:36), 'omitnan')]';
residential(4) = sum(residential(1:3) .* (residential(1:3) ~= 0)) / sum((residential(1:3) ~= 0));
residential(5) = residential(4) / gallonsAnnl(4);
%cost col 7
cost = [sum(obj.UsageTable.cost(1:12)) sum(obj.UsageTable.cost(13:24), ...
    'omitnan') sum(obj.UsageTable.cost(25:36), 'omitnan')]';
cost(4) = sum(cost(1:3) .* (cost(1:3) ~= 0)) / sum((cost(1:3) ~= 0));
cost(5) = NaN;

%make an array for each water account summarizing use for each year
UsageAnnualTable = [gallonsAnnl adjUseAnnl irrigation coolingTower ...
    otherUses residential cost];

%unit cost of water in the most recent year, $/gallon
GallonsCost=UsageAnnualTable(obj.NumberOfYears,7)/UsageAnnualTable(obj.NumberOfYears,1);

%monthly profile starting in January for use in level 2 calcs
% make an array from waterData for month and all uses (res & non-res)
waterMo = [obj.UsageTable.month, obj.UsageTable.adjGallons, obj.UsageTable.IrrigationGal, ...
    obj.UsageTable.CoolingTowerGal, obj.UsageTable.OtherGal, obj.UsageTable.ResidentialGal];
%rearrange the rows so January is first and average the values for each
%month in a second array that will be an output of the function
for n = 1:12
    y = waterMo(1:obj.numMonthsWaterData, 1) == n;
    waterMoProfile(n, 1:5) = sum(waterMo(1:obj.numMonthsWaterData, 2:6) .* y) / sum(y);
end
%5 columns are: total, and any irrigation, cooling tower, other, and residential
%rows are 12 months starting in January
%% Make table for the annual and monthly  use of the gas account
waterMoProfile=table([1:12]',waterMoProfile(:,1),waterMoProfile(:,2),waterMoProfile(:,3),waterMoProfile(:,4),waterMoProfile(:,5), ...
    VariableNames=["Month","TotalGallons","IrrigationGallons","CoolingTowerGallons","OtherUseGallons","ResidentialGallons"]);

UsageAnnualTable=table(["year 1"; "year 2"; "year 3"; "average"; ...
    "fraction of total"],UsageAnnualTable(:,1),UsageAnnualTable(:,2),UsageAnnualTable(:,3),UsageAnnualTable(:,4),UsageAnnualTable(:,5),UsageAnnualTable(:,6),UsageAnnualTable(:,7));
UsageAnnualTable.Properties.VariableNames=["parameter","AnnualGallons","adjustedAnnualGallons","IrrigationGallons","CoolingTowerGallons","OtherGallons","ResidentialGallons","CostAnnual"];
end