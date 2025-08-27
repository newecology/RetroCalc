function calculateMonthlyVentilation(obj)
%ventilation function
%this function takes the inputs for building ventilation and provides the
%monthly average ventilation air flow in cfm (balanced and unbalanced) for
% each month for day and night periods
%unbalanced flow is not specified as supply or exhaust
%ventilation flows considered the same for heating and cooling seasons

%% Arguments Block
arguments
    % Obj - Self-referential building object.
    obj (1,1) ece.Building
end %argblock

%%

% determine the total hours in time1 and time2 periods
time1Hrs = (obj.HVACStartEndTimePeriod1(2) - obj.HVACStartEndTimePeriod1(1));
time2Hrs = 24 - time1Hrs;

%average the air flow over time 1 and time 2 periods for energy calc
% if it is an ERV, consider only the "energetically effective" flow
% i.e. total flow x heating or cooling efficiency
% since heating and cooling ERV efficiencies are different, flows must be
% separated into heating/cooling

numAirMovers = length(obj.Airmovers);

avgCFM1 = zeros(1,numAirMovers);
avgCFM2 = zeros(1,numAirMovers);
effAvgCFM1Htg = zeros(1,numAirMovers);
effAvgCFM2Htg = zeros(1,numAirMovers);
effAvgCFM1Clg = zeros(1,numAirMovers);
effAvgCFM2Clg = zeros(1,numAirMovers);

for i = 1:numAirMovers
    avgCFM1(i) = obj.Airmovers(i).Quantity * obj.Airmovers(i).DesignCFMperUnit * ...
        obj.Airmovers(i).AverageSpeed(1) * obj.Airmovers(i).OperationHoursPerDay(1) ...
        / time1Hrs;
    avgCFM2(i) = obj.Airmovers(i).Quantity * obj.Airmovers(i).DesignCFMperUnit * ...
        obj.Airmovers(i).AverageSpeed(2) * obj.Airmovers(i).OperationHoursPerDay(2) ...
        / time2Hrs;

    if obj.Airmovers(i).Type == "ERV"
        effAvgCFM1Htg(i) = avgCFM1(i) * (1-obj.Airmovers(i).HeatingSensibleEfficiency);
        effAvgCFM2Htg(i) = avgCFM2(i) * (1-obj.Airmovers(i).HeatingSensibleEfficiency);
        effAvgCFM1Clg(i) = avgCFM1(i) * (1-obj.Airmovers(i).CoolingTotalEfficiency);
        effAvgCFM2Clg(i) = avgCFM2(i) * (1-obj.Airmovers(i).CoolingTotalEfficiency);

    elseif obj.Airmovers(i).Type == "AirHandlingUnit"
        effAvgCFM1Htg(i) = avgCFM1(i) * obj.Airmovers(i).FractionVentilation;
        effAvgCFM2Htg(i) = avgCFM2(i) * obj.Airmovers(i).FractionVentilation;
        effAvgCFM1Clg(i) = avgCFM1(i) * obj.Airmovers(i).FractionVentilation;
        effAvgCFM2Clg(i) = avgCFM2(i) * obj.Airmovers(i).FractionVentilation;

    else
        effAvgCFM1Htg(i) = avgCFM1(i);
        effAvgCFM2Htg(i) = avgCFM2(i);
        effAvgCFM1Clg(i) = avgCFM1(i);
        effAvgCFM2Clg(i) = avgCFM2(i);
    end %if statement

end %for loop

% This is the average energetically effective air flow in time1 and time2
% periods. equal air flow for all months when in operation.
% Use a logical mask to "turn off" fans for months they do not operate
% Create Mask from OperationMonths. Initialize Mask of False
monthUsageMask = false(12,numAirMovers);

% Determine # of Months to Span for each air mover
for n = 1:numAirMovers
    if obj.Airmovers(n).OperationMonths(1) > obj.Airmovers(n).OperationMonths(2)
        % First month greater than second implies wraparound across year-end.
        % eg heating season. Ex: [10,5] spans October to May. Set mask values to true.
        monthUsageMask(1:obj.Airmovers(n).OperationMonths(2),n) = true;
        monthUsageMask(obj.Airmovers(n).OperationMonths(1):12,n) = true;

    elseif obj.Airmovers(n).OperationMonths(1) <= obj.Airmovers(n).OperationMonths(2)
        % First month less than second implies within same year, eg cooling season.
        % Ex: [6,9] spans June to September.
        % MonthRangeMask
        monthRangeIndices = obj.Airmovers(n).OperationMonths(1) : ...
            obj.Airmovers(n).OperationMonths(2);

        monthUsageMask(monthRangeIndices,n) = true;

    end %endif (Month Range check)

end  % for loop

% Extend the average air flows to 12 months and apply the mask.
effAvgCFM1Htg = effAvgCFM1Htg .* ones(12,1) .* monthUsageMask;
effAvgCFM2Htg = effAvgCFM2Htg .* ones(12,1) .* monthUsageMask;
effAvgCFM1Clg = effAvgCFM1Clg .* ones(12,1) .* monthUsageMask;
effAvgCFM2Clg = effAvgCFM2Clg .* ones(12,1) .* monthUsageMask;

%add up total supply and exhaust air flows to determine balanced and
%unbalanced flows. ERV's and AHU's are considered to have balanced supply
%and exhaust. exhaust fan is exhaust only. supply fan is supply only.
% calculation is carried out for each month, for heating and cooling flows,
% and for time periods 1 and 2

type = [obj.Airmovers.Type];
sup = type == "ERV" | type == "SupplyFan" | type == "AirHandlingUnit";
ex = type == "ERV" | type == "ExhaustFan" | type == "AirHandlingUnit";

% Total effective supply flows
totalEffSupFlows1Htg = sum(sup .* effAvgCFM1Htg,2);
totalEffSupFlows2Htg = sum(sup .* effAvgCFM2Htg,2);
totalEffSupFlows1Clg = sum(sup .* effAvgCFM1Clg,2);
totalEffSupFlows2Clg = sum(sup .* effAvgCFM2Clg,2);

% Total effective exhaust flows
totalEffExFlows1Htg = sum(ex .* effAvgCFM1Htg,2);
totalEffExFlows2Htg = sum(ex .* effAvgCFM2Htg,2);
totalEffExFlows1Clg = sum(ex .* effAvgCFM1Clg,2);
totalEffExFlows2Clg = sum(ex .* effAvgCFM2Clg,2);

% Take the minimum value across each row.
totalBalFlows1Htg = min([totalEffSupFlows1Htg, totalEffExFlows1Htg],[],2);
totalBalFlows2Htg = min([totalEffSupFlows2Htg, totalEffExFlows2Htg],[],2);
totalBalFlows1Clg = min([totalEffSupFlows1Clg, totalEffExFlows1Clg],[],2);
totalBalFlows2Clg = min([totalEffSupFlows2Htg, totalEffExFlows2Clg],[],2);

% Take the absolue difference.
totalUnbalFlows1Htg = abs(totalEffSupFlows1Htg - totalEffExFlows1Htg);
totalUnbalFlows2Htg = abs(totalEffSupFlows2Htg - totalEffExFlows2Htg);
totalUnbalFlows1Clg = abs(totalEffSupFlows1Clg - totalEffExFlows1Clg);
totalUnbalFlows2Clg = abs(totalEffSupFlows2Clg - totalEffExFlows2Clg);

% Rearrange the data into two 24 column arrays for day/night flows for each month in cfm
% column 1 is Jan day, column 2 is Jan night, column 3 is Feb day etc.
% row 1 is balanced flows, row 2 is unbalanced flows. 1 array for heating
% 1 array for cooling
obj.HtngVentilationFlow = zeros(24,2);
obj.ClngVentilationFlow = zeros(24,2);
obj.HtngVentilationFlow(1:2:23,1) = totalBalFlows1Htg;
obj.HtngVentilationFlow(2:2:24,1) = totalBalFlows2Htg;
obj.HtngVentilationFlow(1:2:23,2) = totalUnbalFlows1Htg;
obj.HtngVentilationFlow(2:2:24,2) = totalUnbalFlows2Htg;
obj.ClngVentilationFlow(1:2:23,1) = totalBalFlows1Clg;
obj.ClngVentilationFlow(2:2:24,1) = totalBalFlows2Clg;
obj.ClngVentilationFlow(1:2:23,2) = totalUnbalFlows1Clg;
obj.ClngVentilationFlow(2:2:24,2) = totalUnbalFlows2Clg;


end %function calcMonthlyVentilation