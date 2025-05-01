function[gasStoveDryerTotalAnnlTherms]= gasAnalysis(obj)
%asigning values to some commonly used variables from the basics table
numUnits =  obj.basicsTbl.value(4);
numBR =  obj.basicsTbl.value(5);
avgNumBR = numBR/numUnits;
numOcc = obj.basicsTbl.value(10);
%correct for uneven billing periods which would skew the analysis
%adjust usage to 12 periods of equal duration in each yFanear
%usage per day times 365/12 for each billing period
obj.correct_billing()
%subtract gas stoves & dryers, which do not have a seasonal component
%from the total gas usage. analysis will then be on DHW & space heat
%which do have seasonal variation

if obj.Cooking==1  % %if this account serves gas stoves
    gasStoveAnnlTherms=obj.appliancesTbl.value(1)*(ece.Reference.StoveDataTbl.constant(7)+avgNumBR* ...
        ece.Reference.StoveDataTbl.avgNumBRmult(7));
else
    gasStoveAnnlTherms=0;
end

if obj.ClothesDryer==1 %if this accouint serves gas dryers
    gasInUnitDryerAnnlTherms=obj.appliancesTbl.value(6)*((ece.Reference.DryerDataTbl.constant(7)+avgNumBR*...
        ece.Reference.DryerDataTbl.avgNumBRmult(7))*ece.Reference.DryerDataTbl.factorF(7));
    %this is based on the number of common laundry gas clothes dryers
    gasComAreaDryerAnnlTherms=obj.appliancesTbl.value(10)*((ece.Reference.DryerDataTbl.constant(8)+avgNumBR*...
        ece.Reference.DryerDataTbl.avgNumBRmult(8))*ece.Reference.DryerDataTbl.factorF(8));
else
    gasInUnitDryerAnnlTherms=0;
    gasComAreaDryerAnnlTherms=0;
end

% Getting the net therms from stove and dryer
gasStoveDryerTotalAnnlTherms = gasStoveAnnlTherms + gasInUnitDryerAnnlTherms + ...
    gasComAreaDryerAnnlTherms;
%Getting the per month therms for stove and dryer
gasStoveDryerMonthTherms = gasStoveDryerTotalAnnlTherms / 12;
%add the gas stove/dryer usage, and the seasonally variable usage to the
%Usage Table
obj.UsageTable.StoveDryerTherms(1:obj.numMonthsGasData)=gasStoveDryerMonthTherms * ones(obj.numMonthsGasData,1);
obj.UsageTable.variableUsage=obj.UsageTable.adjTherms-obj.UsageTable.StoveDryerTherms; %adding column variableUsage

%separate the DHW from the heating component

%take the minimum for each year, averaging the two smallest months in each year
[minGasMoYr1, minGasMoYr2,minGasMoYr3,minGasMoAvg]= obj.minGasMoYr();
disp(minGasMoYr1)
disp(minGasMoYr2)
disp(minGasMoYr3)
disp(minGasMoAvg);
for n=1:obj.numMonthsGasData
    a =  obj.histDDtbl.date >= obj.UsageTable.startDate(n) & obj.histDDtbl.date <= obj.UsageTable.endDate(n);
    obj.UsageTable.HDD65(n) = sum(obj.histDDtbl.HDD65 .* a,'omitnan'); %adding column HDD65

end

%remove HDD's for months when the heating system is turned off. depends on
%location. heating season months are defined in basic inputs
heatOffMonths = [(obj.basicsTbl.value(26) + 1):(obj.basicsTbl.value(25) - 1)];
z = ones(height(obj.UsageTable), 1);
for n = 1:length(heatOffMonths)
    y = obj.UsageTable.month ~= heatOffMonths(n);
    z = y .* z;
end
obj.UsageTable.HDD65 = obj.UsageTable.HDD65 .* z;



%select the baseload amplitude to use and add columns to gas array for
%mostly weather independent (DHW) and weather dependent (space heating)
%default baseload amplitude is .8 or as input
%assumes same DHW profile for each year
%however if this account does not serve a DHW load, then the baseload
% amplitude is zero
if obj.DHW == 1
    DHWamp = obj.basicsTbl.value(23);
    %the DHW gas usage for each month, sinusoidal
    obj.UsageTable.DHWTherms= minGasMoAvg*(1+(DHWamp/2)+(DHWamp/2)*(cos((obj.UsageTable.month-1)*pi/6))); %adding columns DHWTherms
else
    obj.UsageTable.DHWTherms = zeros(obj.numMonthsGasData,1);
end

%knowing gas use for DHW, the remainder of the variable part is space heat
%space heating each month is variable therms less DHW, but not negative
obj.UsageTable.SpaceHeatTherms = max((obj.UsageTable.variableUsage - obj.UsageTable.DHWTherms),0);       %adding column SpaceHeatTherms

% adjust the totals such that DHW + heat equals actual usage
fracAdj2 = (sum(obj.UsageTable.DHWTherms, 'omitnan') + sum(obj.UsageTable.SpaceHeatTherms, ...
    'omitnan')) / sum(obj.UsageTable.variableUsage, 'omitnan');
obj.UsageTable.DHWTherms = obj.UsageTable.DHWTherms / fracAdj2;
obj.UsageTable.SpaceHeatTherms = obj.UsageTable.SpaceHeatTherms / fracAdj2;
end
