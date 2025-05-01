function createUsagePlot(obj)
%CREATEUSAGEPLOT Method to create usage plot for utility in question.
%   A usage plot will take the UsageTable of a utility and plot each year's
%   usage as a separate line on a plot. Each year's line will be colored
%   uniquely and labeled in a legend.

f = figure();
a = axes("Parent",f,...
    "NextPlot","add");

%% Determine Number of Unique Years within Usage Table
% For each unique year, we're going to be plotting a line.
uniqueYears = unique(year(obj.UsageTable.startDate));

% Get count of unique years
uniqueYearCount = numel(uniqueYears);


%% Iterate Through Years
% For each year, we'll plot the corresponding month's kWH by monthly index.
months=["Jan" "Feb" "Mar" "Apr" "May" "Jun" "Jul" "Aug" "Sep" "Oct" "Nov" "Dec"];
for yearIdx = 1:uniqueYearCount
    % Extract Current Year for Loop
    thisYear = uniqueYears(yearIdx);

    % Create mask for rows in UsageTable for that year.
    calendarMask = year(obj.UsageTable.startDate) == thisYear;

    % -- Extract Relevant Rows
    % Get X Values (Months)
    monthX = month(obj.UsageTable.startDate(calendarMask));
    therms = obj.UsageTable.therms(calendarMask);

    % Create Plot
    plot(a,monthX,therms,".-",...
        "MarkerSize",16,...
        "LineWidth",1);

end %forloop

% Legend
legend(string(uniqueYears));
xticks(1:12);
xticklabels(months)
xlabel('Months')
ylabel('Gas Usage in Therms')
title('Gas Consumption for Each Year')




end %function