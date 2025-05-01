%test different values of base amplitude. this is FYI for user. not used in
%calculations. corrcoef is the correlations coefficient R. square it to get
%R^2. returns a 2x2 matrix but element (1,2) is the one we want.
%polyfit(x,y,n) returns the coefficients of a polynomial of degree n 
%that is best least squares fit of y to x. degree 1 means x to power 1 
%plus a constant. the first element of polyfit is the x coefficient.
function [DHWBaseData]=TestBaseDHW(obj)
   [minGasMoYr1, minGasMoYr2,minGasMoYr3,minGasMoAvg]= obj.minGasMoYr();
   clear R2
   for n = 1:8
      DHWampTrial = n/5;
      DHWtrial = minGasMoAvg*(1+(DHWampTrial/2)+(DHWampTrial/2)*(cos((obj.UsageTable.month(1:obj.numMonthsGasData)-1)*pi/6)));
      heatTrial = max(obj.UsageTable.variableUsage(1:obj.numMonthsGasData) - DHWtrial,0);
      R =corrcoef(obj.UsageTable.HDD65(1:numMonthsGasData),heatTrial);
      R2(n)=R(1,2)^2;
      ampltd(n) = DHWampTrial;
      linFit = polyfit(obj.UsageTable.HDD65(1:numMonthsGasData), heatTrial,1);
      heatSlope(n) = linFit(1);
      heatSum(n) = sum(heatTrial);
      DHWsum(n) = sum(DHWtrial);
      fracDHW(n) = sum(DHWtrial)/sum(gasData(1:numMonthsGasData,10,m));
   end
%put the numbers on an annual basis by dividing by the number of years
%convert row vectors to column vectors. make a table.
      ampltd=ampltd';                         %amplitude of the sin wave DHW use
      R2 =R2';                                 %fit of space heat therms to HDD65
      heatSlope = heatSlope';                 %therms per HDD65
      heatSum = heatSum/numYrsGasData;        %annual space heat therms
      heatSum = heatSum';
      DHWsum = DHWsum/numYrsGasData;          %annual DHW therms
      DHWsum = DHWsum' ;
      fracDHW = fracDHW';                     %fraction of total that is DHW
%testBaseTbl = table(ampltd,heatSlope,R2,fracDHW,DHWsum,heatSum);    
      DHWBaseData = table(ampltd,heatSlope,R2, fracDHW, DHWsum, heatSum, 'VariableNames','Amplitude','Heat_Slope','Rsquared','DHW_fraction','DHW_annual_therms','SpaceHEat_annual_therms');
end