%ventilation function
%this function takes the inputs for building ventilation and provides the
%monthly average ventilation air flow in cfm (balanced and unbalanced) for 
% each month for day and night periods
%unbalanced flow is not specified as supply or exhaust
%ventilation flows considered the same for heating and cooling seasons
function calcMonthlyVentilation(obj)

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

len = length(obj.Airmovers);

avgCFM1 = zeros(len,1); 
avgCFM2 = zeros(len,1); 
effAvgCFM1Htg = zeros(len,1);
effAvgCFM2Htg = zeros(len,1);
effAvgCFM1Clg = zeros(len,1);
effAvgCFM2Clg = zeros(len,1);

for i = 1:len
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
monthUsageMask = false(len,12);

% Determine # of Months to Span for each air mover
for n = 1:len
if obj.Airmovers(n).OperationMonths(1) > obj.Airmovers(n).OperationMonths(2)
    % First month greater than second implies wraparound across year-end.
    % eg heating season. Ex: [10,5] spans October to May. Set mask values to true.
    monthUsageMask(n, 1:obj.Airmovers(n).OperationMonths(2)) = true;
    monthUsageMask(n, obj.Airmovers(n).OperationMonths(1):12) = true;

elseif obj.Airmovers(n).OperationMonths(1) <= obj.Airmovers(n).OperationMonths(2)
    % First month less than second implies within same year, eg cooling season.
    % Ex: [6,9] spans June to September.
    monthUsageMask(n, obj.Airmovers(n).OperationMonths(1):obj.Airmovers(n).OperationMonths(2)) = true;

end %endif (Month Range check)

end  % for loop

% Extend the average air flows to 12 months and apply the mask. 
    effAvgCFM1Htg = effAvgCFM1Htg .* ones(1,12) .* monthUsageMask;
    effAvgCFM2Htg = effAvgCFM2Htg .* ones(1,12).* monthUsageMask;
    effAvgCFM1Clg = effAvgCFM1Clg .* ones(1,12).* monthUsageMask;
    effAvgCFM2Clg = effAvgCFM2Clg .* ones(1,12).* monthUsageMask;

%add up total supply and exhaust air flows to determine balanced and
%unbalanced flows. ERV's and AHU's are considered to have balanced supply
%and exhaust. exhaust fan is exhaust only. supply fan is supply only.
% calculation is carried out for each month, for heating and cooling flows,
% and for time periods 1 and 2

    type = [obj.Airmovers.Type]';
    sup = type == "ERV" | type == "SupplyFan" | type == "AirHandlingUnit";
    ex = type == "ERV" | type == "ExhaustFan" | type == "AirHandlingUnit";

% Total effective supply flows
totalEffSupFlows1Htg = sum(sup .* effAvgCFM1Htg);
totalEffSupFlows2Htg = sum(sup .* effAvgCFM2Htg);
totalEffSupFlows1Clg = sum(sup .* effAvgCFM1Clg);
totalEffSupFlows2Clg = sum(sup .* effAvgCFM2Clg);

% Total effective exhaust flows
totalEffExFlows1Htg = sum(ex .* effAvgCFM1Htg);
totalEffExFlows2Htg = sum(ex .* effAvgCFM2Htg);
totalEffExFlows1Clg = sum(ex .* effAvgCFM1Clg);
totalEffExFlows2Clg = sum(ex .* effAvgCFM2Clg);

% Sum the balanced and unbalanced ventilation flows for the whole building.
totalBalFlows1Htg = min([totalEffSupFlows1Htg; totalEffExFlows1Htg]);
totalBalFlows2Htg = min([totalEffSupFlows2Htg; totalEffExFlows2Htg]);
totalBalFlows1Clg = min([totalEffSupFlows1Clg; totalEffExFlows1Clg]);
totalBalFlows2Clg = min([totalEffSupFlows2Htg; totalEffExFlows2Clg]);
totalUnbalFlows1Htg = abs(totalEffSupFlows1Htg - totalEffExFlows1Htg);
totalUnbalFlows2Htg = abs(totalEffSupFlows2Htg - totalEffExFlows2Htg);
totalUnbalFlows1Clg = abs(totalEffSupFlows1Clg - totalEffExFlows1Clg);
totalUnbalFlows2Clg = abs(totalEffSupFlows2Clg - totalEffExFlows2Clg);

% Rearrange the data into two 24 column arrays for day/night flows for each month in cfm
% column 1 is Jan day, column 2 is Jan night, column 3 is Feb day etc.
% row 1 is balanced flows, row 2 is unbalanced flows. 1 array for heating
% 1 array for cooling
obj.HtngVentilationFlow = zeros(2,24);
obj.ClngVentilationFlow = zeros(2,24);
obj.HtngVentilationFlow(1,1:2:23) = totalBalFlows1Htg;
obj.HtngVentilationFlow(1,2:2:24) = totalBalFlows2Htg;
obj.HtngVentilationFlow(2,1:2:23) = totalUnbalFlows1Htg;
obj.HtngVentilationFlow(2,2:2:24) = totalUnbalFlows2Htg;
obj.ClngVentilationFlow(1,1:2:23) = totalBalFlows1Clg;
obj.ClngVentilationFlow(1,2:2:24) = totalBalFlows2Clg;
obj.ClngVentilationFlow(2,1:2:23) = totalUnbalFlows1Clg;
obj.ClngVentilationFlow(2,2:2:24) = totalUnbalFlows2Clg;


end %function calcMonthlyVentilation