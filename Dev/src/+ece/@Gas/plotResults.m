function plotResults(obj)
[maxGasYr, maxGasYrIndx] = max(obj.UsageTable.year);
[minGasMo, minGasMoIndx] = min(obj.UsageTable.month);
monthsString=["Jan" "Feb" "Mar" "Apr" "May" "Jun" "Jul" "Aug" "Sep" "Oct" "Nov" "Dec"];
 %% plot heating usage vs HDD65, find linear regression,show slope and R squared
heatFitFinal = polyfit(obj.UsageTable.HDD65(1:obj.numMonthsGasData), obj.UsageTable.SpaceHeatTherms(1:obj.numMonthsGasData), 1);
R = corrcoef(obj.UsageTable.HDD65(1:obj.numMonthsGasData), obj.UsageTable.SpaceHeatTherms(1:obj.numMonthsGasData));
R2 = R(1,2)^2;
figure('Name', "SHThermsvsHDD");
plot(obj.UsageTable.HDD65(1:obj.numMonthsGasData), obj.UsageTable.SpaceHeatTherms(1:obj.numMonthsGasData),'+')
hold on
xGas = 0:10:max(obj.UsageTable.HDD65(:));
yGas = heatFitFinal(1)*xGas + heatFitFinal(2);
plot(xGas,yGas,"LineStyle","-")
graphTitle = strcat(obj.Name, " Account: ", int2str(obj.AccountNumber), ":  Space Heat Gas vs. HDD65 & linear fit");
title(graphTitle,'FontSize',18)
xlabel("HDD65",'FontSize',14)
ylabel("therms/month",'FontSize',14)
%legend("slope  " +string(heatFitFinal(1)),"intercept  " +string(heatFitFinal(2)),"R2  "+string(R2))
slopeStr = string("slope  " + heatFitFinal(1));
interceptStr = string("intercept  " +heatFitFinal(2));
R2Str = string("R2  " + R2);
annotation('textbox',[.15 .7 .2 .2],'String',[slopeStr;interceptStr;R2Str],'FitBoxToText','on')
hold off
%save figure with the gas account number in file name
figName = strcat("gasAccount", string(obj.AccountNumber), '_thermsVsHDD.fig');
savefig(figName)



%% plot total and DHW gas usage
% Determine Number of Unique Years within Usage Table
% For each unique year, we're going to be plotting a line.
f = figure();
a = axes("Parent",f,...
    "NextPlot","add");
uniqueYears = unique(year(obj.UsageTable.startDate));

% Get count of unique years
uniqueYearCount = numel(uniqueYears);

i=1;
% Iterate Through Years
% For each year, we'll plot the corresponding month's kWH by monthly index.
for yearIdx = 1:uniqueYearCount
    % Extract Current Year for Loop
    thisYear = uniqueYears(yearIdx);

    % Create mask for rows in UsageTable for that year.
    calendarMask = year(obj.UsageTable.startDate) == thisYear;

    % -- Extract Relevant Rows
    % Get X Values (Months)
    monthX = month(obj.UsageTable.startDate(calendarMask));
    therms = obj.UsageTable.adjTherms(calendarMask);
    
    %Create Plot
    tplot(i)=plot(a,monthX,therms,".-",...
        "MarkerSize",16,...
        "LineWidth",1);
     hold on
    DHWTherms= obj.UsageTable.DHWTherms(calendarMask);
    % Create Plot
    dplot(i)=plot(a,monthX,DHWTherms,"--",...
        "MarkerSize",16,...
        "LineWidth",.8);
    hold on
    i=i+1;
end %forloop

% Legend
legend([tplot dplot], [strcat('Total:',string(uniqueYears)) strcat('DHW:',string(uniqueYears))],'Location','northeast');


xticks(1:12);
xticklabels(monthsString)
ax=gca;
ax.FontSize=14;
graphTitle = strcat(obj.Name, "  ", string(obj.AccountNumber), ":  Monthly Gas Usage Total and DHW");
title(graphTitle,'FontSize',18)
xlabel('Months')
ylabel('Gas Usage in Therms','FontSize',14)
hold off

%save figure with the gas account number in file name
figName = strcat('gasAccount',string(obj.AccountNumber), '_totalMonthlyAndDHW.fig');
savefig(figName)
end