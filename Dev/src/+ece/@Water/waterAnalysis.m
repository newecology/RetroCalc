function waterAnalysis(obj)
%correct for uneven billing periods which would skew the analysis
%adjust usage to 12 periods of equal duration in each yFanear
%usage per day times 365/12 for each billing period
obj.correct_billing()
%year indices needed for graphing the data
[maxWaterYr, maxWaterYrIndx] = max(obj.UsageTable.year);
[minWaterMo, minWaterMoIndx] = min(obj.UsageTable.month);
% Calculating %monthly distribution for irrigation and cooling tower water - peaks in hot
%weather. flat monthly distribution for "other" water usage
IrrigationMonthly=double(obj.IrrigationGal) .* obj.SummerWaterDist;
CoolTowerMonthly=double(obj.CoolingTowerGal) .* obj.SummerWaterDist;
OtherMo=double(obj.OtherGal)/12*ones(12,1);
%arrange the monthly non-residential uses so that they align with the start
%month of the data and construct 36 row vectors
for n = 1:12
    IrrigationMonthlyAligned(n) = IrrigationMonthly(obj.UsageTable.month(n));
    CoolTowerMonthlyAligned(n) = CoolTowerMonthly(obj.UsageTable.month(n));
end
% Adding the Irrigation , Cooling tower and other gallons to the Usage Data table as columns
tempIrr=[IrrigationMonthlyAligned';IrrigationMonthlyAligned';IrrigationMonthlyAligned'];
tempCT=[CoolTowerMonthlyAligned';CoolTowerMonthlyAligned';CoolTowerMonthlyAligned'];
tempO=[OtherMo;OtherMo;OtherMo];
obj.UsageTable.IrrigationGal=tempIrr(1:obj.numMonthsWaterData );  %col 9 irrigation gallons
obj.UsageTable.CoolingTowerGal=tempCT(1:obj.numMonthsWaterData );% col 10 Cooling Tower gallons
obj.UsageTable.OtherGal=tempO(1:obj.numMonthsWaterData ); % col 11 other gallons

%water that is not used for irrigation, cooling tower, or other is used for
%normal residential purposes

obj.UsageTable.ResidentialGal=obj.UsageTable.adjGallons-obj.UsageTable.IrrigationGal...
    -obj.UsageTable.CoolingTowerGal-obj.UsageTable.OtherGal; %Column 12 Residential Gallons

end