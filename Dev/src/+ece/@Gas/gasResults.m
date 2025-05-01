function [UsageAnnualTable,gasMoProfile,ThermUnitCost]=gasResults(obj)
gasStoveDryerTotalAnnlTherms=obj.gasAnalysis()
iCFA=obj.basicsTbl.value(3);
yrsAvg=obj.basicsTbl.value(24);
    %annual array
%find the annual totals for each year in each column in gas data, 
%as well as the annual average, and the percent of total usage
% cost, heating slope and kBtu/ft2
%array has 6 rows and is constructed for 3 years of data even if
%only 1 or 2 years has been supplied in the inputs. empty rows removed
%in later processing
%rows 1 to 3: annual totals each year each column, 
%row 4: average, row 5: fraction of total usage, row 6: kBtu/ft2

%annual total therms, col 1
if obj.NumberOfYears==3
   thermsAnnl = [sum(obj.UsageTable.therms(1:12)) sum(obj.UsageTable.therms(13:24), 'omitnan') ...
       sum(obj.UsageTable.therms(25:36), 'omitnan')]';
elseif obj.NumberOfYears==2
   thermsAnnl = [sum(obj.UsageTable.therms(1:12)) sum(obj.UsageTable.therms(13:24), 'omitnan') ...
       0]';
else
   thermsAnnl = [sum(obj.UsageTable.therms(1:12)) 0 0]';
end   
thermsAnnl(4) = sum(thermsAnnl(1:3) .* (thermsAnnl(1:3) ~= 0)) / sum((thermsAnnl(1:3) ~= 0));
thermsAnnl(5) = NaN;
thermsAnnl(6) = thermsAnnl(4) * 100/iCFA;
%adjusted use, should equal total annual therms, col 2
if obj.NumberOfYears==3
   adjUseAnnl = [sum(obj.UsageTable.adjTherms(1:12)) sum(obj.UsageTable.adjTherms(13:24), 'omitnan')...
            sum(obj.UsageTable.adjTherms(25:36), 'omitnan')]';
elseif obj.NumberOfYears==2
    adjUseAnnl = [sum(obj.UsageTable.adjTherms(1:12)) sum(obj.UsageTable.adjTherms(13:24), 'omitnan')...
            0]';
else
    adjUseAnnl = [sum(obj.UsageTable.adjTherms(1:12)) 0 0]';   
end
adjUseAnnl(4) = sum(adjUseAnnl(1:3) .* (adjUseAnnl(1:3) ~= 0)) / sum((adjUseAnnl(1:3) ~= 0));
adjUseAnnl(5) = adjUseAnnl(4)/thermsAnnl(4);
adjUseAnnl(6) = adjUseAnnl(4) * 100/iCFA;
%HDD65, col 3
if obj.NumberOfYears==3
   HDD65Annl = [sum(obj.UsageTable.HDD65(1:12)) sum(obj.UsageTable.HDD65(13:24), 'omitnan') ...
       sum(obj.UsageTable.HDD65(25:36), 'omitnan')]';
elseif obj.NumberOfYears==2  
   HDD65Annl = [sum(obj.UsageTable.HDD65(1:12)) sum(obj.UsageTable.HDD65(13:24), 'omitnan') ...
       0]';    
else
   HDD65Annl = [sum(obj.UsageTable.HDD65(1:12)) 0 0]';
end
HDD65Annl(4) = sum(HDD65Annl(1:3) .* (HDD65Annl(1:3) ~= 0)) / sum((HDD65Annl(1:3) ~= 0));
HDD65Annl(5) = NaN;
HDD65Annl(6) = NaN;
%gas use for stoves and dryers in therms, col 4
if obj.NumberOfYears==3
   stoveDryerAnnl = [gasStoveDryerTotalAnnlTherms gasStoveDryerTotalAnnlTherms ...
            gasStoveDryerTotalAnnlTherms]';
elseif obj.NumberOfYears==2
   stoveDryerAnnl = [gasStoveDryerTotalAnnlTherms gasStoveDryerTotalAnnlTherms ...
            0]';    
else
   stoveDryerAnnl = [gasStoveDryerTotalAnnlTherms 0 0]';
end
stoveDryerAnnl(4) = gasStoveDryerTotalAnnlTherms;
stoveDryerAnnl(5) = gasStoveDryerTotalAnnlTherms / thermsAnnl(4);
stoveDryerAnnl(6) = stoveDryerAnnl(4) * 100/iCFA;  

%Gas usage for DHW in therms, col 5
if obj.NumberOfYears==3
   DHWAnnl = [sum(obj.UsageTable.DHWTherms(1:12)) sum(obj.UsageTable.DHWTherms(13:24), 'omitnan') ...
            sum(obj.UsageTable.DHWTherms(25:36), 'omitnan')]';
elseif obj.NumberOfYears==2   
   DHWAnnl = [sum(obj.UsageTable.DHWTherms(1:12)) sum(obj.UsageTable.DHWTherms(13:24), 'omitnan') ...
            0]';    
else
   DHWAnnl = [sum(obj.UsageTable.DHWTherms(1:12)) 0 0]';
end
DHWAnnl(4) = sum(DHWAnnl(1:3) .* (DHWAnnl(1:3) ~= 0)) / sum((DHWAnnl(1:3) ~= 0));
DHWAnnl(5) = DHWAnnl(4)/thermsAnnl(4);
DHWAnnl(6) = DHWAnnl(4) * 100/iCFA;
%gas use for space heat in therms, col 6
if obj.NumberOfYears==3
   htgAnnl = [sum(obj.UsageTable.SpaceHeatTherms(1:12)) sum(obj.UsageTable.SpaceHeatTherms(13:24), 'omitnan') ...
       sum(obj.UsageTable.SpaceHeatTherms(25:36), 'omitnan')]';
elseif obj.NumberOfYears==2
   htgAnnl = [sum(obj.UsageTable.SpaceHeatTherms(1:12)) sum(obj.UsageTable.SpaceHeatTherms(13:24), 'omitnan') ...
       0]';   
else
   htgAnnl = [sum(obj.UsageTable.SpaceHeatTherms(1:12)) 0 0]';
end
htgAnnl(4) = sum(htgAnnl(1:3) .* (htgAnnl(1:3) ~= 0)) / sum((htgAnnl(1:3) ~= 0));
htgAnnl(5) = htgAnnl(4)/thermsAnnl(4);
htgAnnl(6) = htgAnnl(4) * 100/iCFA;
%cost of the gas, col 7
if obj.NumberOfYears==3
   costAnnl = [sum(obj.UsageTable.cost(1:12)) sum(obj.UsageTable.cost(13:24), 'omitnan') ...
       sum(obj.UsageTable.cost(25:36), 'omitnan')]';
elseif obj.NumberOfYears==2
   costAnnl = [sum(obj.UsageTable.cost(1:12)) sum(obj.UsageTable.cost(13:24), 'omitnan') ...
       0]';
else
   costAnnl = [sum(obj.UsageTable.cost(1:12)) 0 0]';    
end
costAnnl(4) = sum(costAnnl(1:3) .* (costAnnl(1:3) ~= 0)) / sum((costAnnl(1:3) ~= 0));
costAnnl(5) = NaN;
costAnnl(6) = NaN;
%heating slope, col 8
htgSlope = htgAnnl(1:4) ./ HDD65Annl(1:4);
htgSlope(HDD65Annl(1:4)==0)=0;
htgSlope(5) = NaN;
htgSlope(6) = NaN;
%put this annual summary data into a matrix 
UsageAnnualTable= [thermsAnnl adjUseAnnl HDD65Annl stoveDryerAnnl DHWAnnl ...
    htgAnnl costAnnl htgSlope];
%annual summary array columns and rows
%1 total use, 2 adj use, 3 HDD65, 4 stovesDryers, 5 DHW, 6 spaceHeat, 7 cost, 8 slope
%1 year 1
%2 year 2
%3 year 3
%4 average year
%5 fraction of total
%6 kBtu/ft2

%normalize recent actual space heat to average year weather
%define average year weather as average of the past 5 years or as input
%exclude HDDs in June, July, and August
[maxDateHist,maxDateHistIndx] = max(obj.histDDtbl.date);
z = month(obj.histDDtbl.date(maxDateHistIndx-(yrsAvg*365):maxDateHistIndx));
z = z ~= 6 & z ~= 7 & z ~= 8;
avgWeatherYrHDD65 = sum(obj.histDDtbl.HDD65(maxDateHistIndx - (yrsAvg*365):maxDateHistIndx) .* z)/yrsAvg;

%space heating in an average year. heating slope x average year HDD65
gasHtgAnnlNorml = avgWeatherYrHDD65 * UsageAnnualTable(4, 8);

%unit cost of gas in the most recent year, $/therm
ThermUnitCost = UsageAnnualTable(obj.NumberOfYears,7) / UsageAnnualTable(obj.NumberOfYears, 1); 


%monthly profile starting in January, and normalized 
% to average year weather. make an array from gasData 
gasMo = [obj.UsageTable.month,obj.UsageTable.StoveDryerTherms, obj.UsageTable.DHWTherms, ...
    obj.UsageTable.SpaceHeatTherms];
%rearrange the rows so January is first and average the values for each
%month
for n = 1:12
    y = gasMo(1:obj.numMonthsGasData, 1) == n;
    gasMoProfile(n, 1:3) = sum(gasMo(1:obj.numMonthsGasData, 2:4) .* y) / sum(y);
    
end

%normalize space heating profile
gasHeatAdj =  gasHtgAnnlNorml / sum(gasMoProfile(:, 3));
gasMoProfile(:, 3) = gasHeatAdj * gasMoProfile(:, 3);
%add up base, heating, and DHW to get total normalized gas usage monthly
%profile
gasMoProfile(:, 4) = sum(gasMoProfile(:, 1:3), 2, 'OmitNaN');

%% Make table for the annual and monthly use of the gas account
obj.MonthlyProfile=table([1:12]',gasMoProfile(:,1),gasMoProfile(:,2),gasMoProfile(:,3),gasMoProfile(:,4),VariableNames=["Month","StoveDryerTherms","DHWTherms","SpaceHeatTherms","TotalTherms"]);

UsageAnnualTable=table(["year 1"; "year 2"; "year 3"; "average"; ...
    "fraction of total"; "kBtu/ft2"],UsageAnnualTable(:,1),UsageAnnualTable(:,2),UsageAnnualTable(:,3),UsageAnnualTable(:,4),UsageAnnualTable(:,5),UsageAnnualTable(:,6),UsageAnnualTable(:,7),UsageAnnualTable(:,8));
UsageAnnualTable.Properties.VariableNames=["parameter","AnnualTherms","adjustedAnnualTherms","HDD65Annual","StoveDryerAnnualTherms","DHWAnnualTherms","HeatingAnnualTherms","CostAnnual","heatingSlope"];
obj.UsageAnnualTable=UsageAnnualTable;
end