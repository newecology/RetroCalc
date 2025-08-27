function plotResults(obj)
%year indices needed for graphing the data
[maxWaterYr, maxWaterYrIndx] = max(obj.UsageTable.year);
[minWaterMo, minWaterMoIndx] = min(obj.UsageTable.month);
monthsString=["Jan" "Feb" "Mar" "Apr" "May" "Jun" "Jul" "Aug" "Sep" "Oct" "Nov" "Dec"];
%plot total any non-residential usage, first month is or is not January
    if obj.UsageTable.month(1) == 1
        figure('Name', "Monthly water Usage")
        plot(obj.UsageTable.month(1:12), obj.UsageTable.adjGallons(1:12, 8, m), 'LineWidth',1.5)
        hold on
        plot(obj.UsageTable.month(13:24),obj.UsageTable.adjGallons(13:24),'LineWidth',1.5)
        plot(obj.UsageTable.month(25:36),obj.UsageTable.adjGallons(25:36),'LineWidth',1.5)
        if obj.IrrigationGal > 0
            plot(obj.UsageTable.month(1:12), obj.UsageTable.IrrigationGal(1:12), 'LineWidth',1.5)
        end
        if obj.CoolingTowerGal > 0
            plot(obj.UsageTable.month(1:12), obj.UsageTable.CoolingTowerGal(1:12), 'LineWidth',1.5)
        end
        if obj.OtherGal > 0
            plot(obj.UsageTable.month(1:12), obj.UsageTable.OtherGal(1:12), 'LineWidth',1.5)
        end
        if obj.NumberOfYears == 3
            yearLegend = legend(string(maxWaterYr-2), string(maxWaterYr-1), ...
                string(maxWaterYr));
        elseif obj.NumberOfYear == 2
            yearLegend = legend(string(maxWaterYr-1), string(maxWaterYr));
        else 
            yearLegend = legend(string(maxWaterYr));
        end
%if the utility data starts any month after January, plot includes an added calendar year          
    else
        figure('Name', "Monthly water usage: total & non-res")
        
        plot(obj.UsageTable.month(1:minWaterMoIndx-1), obj.UsageTable.adjGallons(1:minWaterMoIndx-1), ...
            'LineWidth',1.5)
        hold on
        plot(obj.UsageTable.month(minWaterMoIndx:(minWaterMoIndx+11)), ...
            obj.UsageTable.adjGallons(minWaterMoIndx:(minWaterMoIndx+11)),'LineWidth',1.5)
        plot(obj.UsageTable.month((minWaterMoIndx+12):(minWaterMoIndx+23)), ...
            obj.UsageTable.adjGallons((minWaterMoIndx+12):(minWaterMoIndx+23)),'LineWidth',1.5)
        plot(obj.UsageTable.month((minWaterMoIndx+24):end), ...
            obj.UsageTable.adjGallons((minWaterMoIndx+24):end),'LineWidth',1.5)
        if obj.IrrigationGal > 0
            plot(1:12, obj.UsageTable.IrrigationGal(minWaterMoIndx:(minWaterMoIndx + 11)), 'LineWidth',1.5)
        end
        if obj.CoolingTowerGal > 0
            plot(1:12, obj.UsageTable.CoolingTowerGal(minWaterMoIndx:(minWaterMoIndx + 11)), 'LineWidth',1.5)
        end
        if obj.OtherGal > 0
            plot(1:12, obj.UsageTable.OtherGa(minWaterMoIndx:(minWaterMoIndx + 11)), 'LineWidth',1.5)
        end
        if obj.NumberOfYears == 3
            yearLegend = legend(string(maxWaterYr-3), string(maxWaterYr-2), ...
                string(maxWaterYr-1), string(maxWaterYr));
        elseif obj.NumberOfYears == 2
            yearLegend = legend(string(maxWaterYr-2), string(maxWaterYr-1), ...
                    string(maxWaterYr));
        else 
            yearLegend = legend(string(maxWaterYr-1), string(maxWaterYr));
        end
    end
  
%format and label the plot, same for all cases
xlim([1 12])
xticks([1:12])
xticklabels(monthsString)
ax=gca;
ax.FontSize=14;
graphTitle = strcat(obj.Name, "Account: ", string(obj.AccountNumber),  ":  Monthly water usage total & non-res");
title(graphTitle,'FontSize',18)
ylabel("Gallons per month",'FontSize',14)
legend('location','best')
if obj.IrrigationGal > 0
    legend([yearLegend.String, "Irrigation"])
end
if obj.CoolingTowerGal > 0
   legend([yearLegend.String, "Cooling tower water usage"])
end
if obj.OtherGal > 0
   legend([yearLegend.String, "Other non-residential water usage"])
end
hold off

%% plot usage for water
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
    gal = obj.UsageTable.adjGallons(calendarMask);
    
    %Create Plot
    tplot(i)=plot(a,monthX,gal,"-",...
        "MarkerSize",16,...
        "LineWidth",1);
     hold on
     %Irrigation,Cooling Tower and Other uses
    if obj.IrrigationGal > 0
           IrrGal=obj.UsageTable.IrrigationGal(calendarMask);
           iplot(i)= plot(a, monthX,IrrGal,"--", 'LineWidth',.9);
    end
    if obj.CoolingTowerGal > 0
            CT=obj.UsageTable.CoolingTowerGal(calendarMask);
            ctplot(i)=plot(a, monthX,CT,":", 'LineWidth',.8)
    end
    if obj.OtherGal > 0
            ot=obj.UsageTable.OtherGal(calendarMask);
            otplot(i)=plot(a,monthX,ot,"-.", 'LineWidth',.7)
    end
    i=i+1;
end %forloop

% Legend
if obj.IrrigationGal > 0 && obj.CoolingTowerGal > 0 && obj.OtherGal > 0
  legend([tplot iplot ctplot otplot], [strcat('Total:',string(uniqueYears)) strcat('Irrigation:',string(uniqueYears)) strcat('CoolingTower',string(uniqueYears)) strcat('Other:',string(uniqueYears))],'Location','northeast');
elseif obj.IrrigationGal > 0 && obj.CoolingTowerGal > 0
  legend([tplot iplot ctplot], [strcat('Total:',string(uniqueYears)) strcat('Irrigation:',string(uniqueYears)) strcat('CoolingTower',string(uniqueYears))],'Location','northeast' );     
elseif obj.CoolingTowerGal > 0 && obj.OtherGal > 0
   legend([tplot ctplot otplot], [strcat('Total:',string(uniqueYears))  strcat('CoolingTower',string(uniqueYears)) strcat('Other:',string(uniqueYears))],'Location','northeast'); 
elseif obj.IrrigationGal > 0 && obj.OtherGal > 0
   legend([tplot iplot otplot], [strcat('Total:',string(uniqueYears))  strcat('Other:',string(uniqueYears))],'Location','northeast');  
elseif obj.IrrigationGal > 0
   legend([tplot iplot ], [strcat('Total:',string(uniqueYears)) strcat('Irrigation:',string(uniqueYears))],'Location','northeast');
elseif obj.CoolingTowerGal > 0
   legend([tplot ctplot ], [strcat('Total:',string(uniqueYears)) strcat('CoolingTower:',string(uniqueYears))],'Location','northeast');
else
   legend([tplot otplot ], [strcat('Total:',string(uniqueYears)) strcat('Other:',string(uniqueYears))],'Location','northeast');
end
xticks(1:12);
xticklabels(monthsString)
ax=gca;
ax.FontSize=14;
graphTitle = strcat(obj.Name, "  ", string(obj.AccountNumber), ":  Monthly Gas Usage Total and DHW");
title(graphTitle,'FontSize',18)
xlabel('Months')
ylabel('Gas Usage in Therms','FontSize',14)
hold off


figName = strcat('WaterAccount',string(obj.AccountNumber), '_totalMonthlyAndNonRes.fig');
savefig(figName)
end