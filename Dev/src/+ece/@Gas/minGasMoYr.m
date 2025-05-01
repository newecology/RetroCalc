%set minimum base adjustment factor for each year
%for buildings with both electric heat and cooling,
%there is some heating and cooling in shoulder months
%so for those buildings, the default minimum base adj factor = .9
%if only heating or only cooling, minimum base adj factor = 1.0
function [minGasMoYr1, minGasMoYr2,minGasMoYr3,minGasMoAvg]= minGasMoYr(obj)
 n = 2; 
    if obj.NumberOfYears == 3
        minGasMoYr1 = mean(mink(obj.UsageTable.adjTherms(1:12),n));
        minGasMoYr2 = mean(mink(obj.UsageTable.adjTherms(13:24),n));
        minGasMoYr3 = mean(mink(obj.UsageTable.adjTherms(25:36),n));
    elseif obj.NumberOfYears == 2
        minGasMoYr1 = mean(mink(obj.UsageTable.adjTherms(1:12),n));
        minGasMoYr2 = mean(mink(obj.UsageTable.adjTherms(13:24),n));
        minGasMoYr3 = nan;
    else 
        minGasMoYr1 = mean(mink(obj.UsageTable.adjTherms(1:12),n));
        minGasMoYr2 = nan ;
        minGasMoYr3 = nan;
    end
 minGasMoAvg = mean([minGasMoYr1 minGasMoYr2 minGasMoYr3],'omitnan');

end