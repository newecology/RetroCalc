function plotResults(obj)
% %graph data versus degree days, and also show monthly usage with baseload
% %plot heating usage if any vs HDD65, find linear regression,show slope and R squared
[maxElecYr, maxElecYrIndx] = max(obj.UsageTable.year);
[minElecMo, minElecMoIndx] = min(obj.UsageTable.month);
months=["Jan" "Feb" "Mar" "Apr" "May" "Jun" "Jul" "Aug" "Sep" "Oct" "Nov" "Dec"];
if obj.SpaceHeat == 1
    figure()
    heatFit = polyfit(obj.UsageTable.HDD65(1:obj.numMonthsElecData), obj.UsageTable.heat(1:obj.numMonthsElecData), 1);
    Rheat = corrcoef(obj.UsageTable.HDD65(1:obj.numMonthsElecData), obj.UsageTable.heat(1:obj.numMonthsElecData, 14));
    Rheat2 = Rheat(1,2)^2;
    figure('Name', "Monthly space heating vs HDD65")
    plot(obj.UsageTable.HDD65(1:obj.numMonthsElecData), obj.UsageTable.heat(1:obj.numMonthsElecData), '+')
    hold on
    %slope of the linear fit is heatFitFinal(1) and the intercept is heatFitFinal(2);
    xElec1 = [0:10:max(obj.UsageTable.HDD65(:))];
    yElec1 = heatFit(1) * xElec1 + heatFit(2);
    plot(xElec1, yElec1, "LineStyle", "-")
    graphTitle = strcat(projectName, "  Account: ",int2str(obj.AccountNumber), ":  Heating Electricity vs HDD65 & linear fit");
    title(graphTitle,'FontSize',18)
    xlabel("HDD65 in each heating month",'FontSize',14)
    ylabel("kWh/month",'FontSize',14)
    slopeStr = string("slope  " + heatFit(1) + " kWh/HDD65");
    interceptStr = string("intercept  " +heatFit(2));
    R2Str = string("R2  " + Rheat2);
    annotation('textbox', [.2 .6 .2 .2], 'string', ...
        {slopeStr,interceptStr,R2Str}, 'FitBoxToText','on')
    hold off
    figName = strcat('elec Account',string(obj.AccountNumber), '_kWhVsHDD65.fig');
    savefig(figName)
end    
% 
% %plot cooling usage vs CDD70, find linear regression,show slope and R squared
if obj.Cooling == 1
    coolFit = polyfit(obj.UsageTable.CDD70(1:obj.numMonthsElecData), obj.UsageTable.cool(1:obj.numMonthsElecData), 1);
    Rcool = corrcoef(obj.UsageTable.CDD70(1:obj.numMonthsElecData), obj.UsageTable.cool(1:obj.numMonthsElecData));
    Rcool2 = Rcool(1,2)^2;
    figure('Name', "Cooling vs CDD70")
    plot(obj.UsageTable.CDD70(1:obj.numMonthsElecData), obj.UsageTable.cool(1:obj.numMonthsElecData),'+')
    hold on
    xElec2 = [0:10:max(obj.UsageTable.CDD70(:))];
    yElec2 = coolFit(1) * xElec2 + coolFit(2);
    plot(xElec2, yElec2, "LineStyle", "-")
    graphTitle = strcat(obj.Name, "  Account: ", int2str(obj.AccountNumber), " : Cooling Electricity vs HDD65 & linear fit");
    title(graphTitle, 'FontSize',18)
    xlabel("CDD70 in each cooling month", 'FontSize', 14)
    ylabel("kWh/month", 'FontSize', 14)
    slopeStr = string("slope  " + coolFit(1) + " kWh/CDD70");
    interceptStr = string("intercept  " + coolFit(2));
    R2Str = string("R2  " + Rcool2);
    annotation('textbox',[.2 .6 .2 .2], 'string', ...
        {slopeStr, interceptStr, R2Str}, 'FitBoxToText', 'on')
    hold off
    figName = strcat('elec Account',string(obj.AccountNumber), '_kWhVsCDD70.fig');
    savefig(figName)
end

%plot the electric usage and baseload so the user can get the overall picture
% %plot usage for two cases: first month is or is not January
 if obj.UsageTable.month(1) == 1
        figure('Name', "Monthly Electric Usage")
        plot(obj.UsageTable.month(1:12), obj.UsageTable.adjkWh(1:12), 'LineWidth', 1.5)
        hold on
        plot(obj.UsageTable.month(13:24), obj.UsageTable.adjkWh(13:24), 'LineWidth', 1.5)
        plot(obj.UsageTable.month(25:36), obj.UsageTable.adjkWh(25:36), 'LineWidth', 1.5)
        plot(obj.UsageTable.month(1:12),obj.UsageTable.base(1:12),'LineWidth',1.5)
        if obj.NumberOfYears == 3
            legend(string(maxElecYr-2), string(maxElecYr-1), string(maxElecYr), ...
                'baseload')
        elseif obj.NumberOfYears == 2
            legend(string(maxElecYr-1), string(maxElecYr), 'baseload')
        else 
            legend(string(maxElecYr), 'baseload')
        end
%if the utility data starts any month after January, plot includes an added year          
else
        figure('Name', "Monthly Electric Usage")
        plot(obj.UsageTable.month(1:(minElecMoIndx-1)), obj.UsageTable.adjkWh(1:(minElecMoIndx-1)), ...
            'LineWidth',1.5)
        hold on
        plot(obj.UsageTable.month(minElecMoIndx:(minElecMoIndx+11)), ...
            obj.UsageTable.adjkWh(minElecMoIndx:(minElecMoIndx+11)),'LineWidth',1.5)
        plot(obj.UsageTable.month((minElecMoIndx+12):(minElecMoIndx+23)), ...
            obj.UsageTable.adjkWh((minElecMoIndx+12):(minElecMoIndx+23)),'LineWidth',1.5)
        plot(obj.UsageTable.month((minElecMoIndx+24):end), obj.UsageTable.adjkWh((minElecMoIndx+24):end),'LineWidth',1.5)
        plot(obj.UsageTable.month(minElecMoIndx:minElecMoIndx+11), ...
            obj.UsageTable.base(minElecMoIndx:minElecMoIndx+11),'LineWidth',1.5)
        if obj.NumberOfYears  == 3
                legend(string(maxElecYr-3), string(maxElecYr-2), string(maxElecYr-1), ...
                string(maxElecYr), 'baseload')
        elseif obj.NumberOfYears == 2
                legend(string(maxElecYr-2), string(maxElecYr-1), string(maxElecYr), ...
                    'baseload')
        else 
                legend(string(maxElecYr-1), string(maxElecYr), 'baseload')
        end
end
% 
%format and label the plot, same for all cases
xlim([1 12])
xticks(1:12)
xticklabels(months)
ylim([0 max(obj.UsageTable.kWh) * 1.05])
ax=gca;
ax.FontSize=14;
graphTitle = strcat(obj.Name, "  ", string(obj.AccountNumber), ":  Monthly Electric Usage Total & Base");
title(graphTitle,'FontSize',18)
ylabel("kWh",'FontSize',14)
legend('location','best')
hold off
figName = strcat('elec Account',string(obj.AccountNumber), '_MonthlyElectricUsage.fig');
savefig(figName)  

end
%function end statement