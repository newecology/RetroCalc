function MonthlyKWH  = computeMonthlyKWH(obj)
%COMPUTEMONTHLYKWH Method to compute a Fan's monthly KWH usage.
%   This method calculates the monthly Fan KWH draw based on its
%   properties. The results are stored in a 12-element array (one for each
%   month) propety of the Fan object.

%% Arguments Block
arguments
    % Obj - Self-referential Fan object.
    obj (1,1) ece.Airmovers
end %argblock

%% Calculate Yearly Array of Monthly Fan kWh Usage
% The calculations for each month are done by taking the number of days
% for that month and multiplying it up to # of hours for the kWh
% conversion. 
% Create array of days per month (assume no leap years for now.)
daysPerMonth = [31 28 31 30 31 30 31 31 30 31 30 31];

% Calculate Monthly kWh Usage
MonthlyKWH = daysPerMonth * (obj.OperationHoursPerDay(1) * ...
    obj.PowerDrawAllFans_kW(1) + obj.OperationHoursPerDay(2) * ...
    obj.PowerDrawAllFans_kW(2));

%% Zero-Out Months of No Operation
% There are some months that the fan is not being used. These months will
% have their KWH usage set to zero so the remaining values represent the
% true KWH utilization.
% -- Create Mask from OperationMonths
% Initialize Mask of False
monthUsageMask = false(1,12);

% Determine # of Months to Span
if obj.OperationMonths(1) > obj.OperationMonths(2)
    % First month greater than second implies wraparound across year-end.
    % Ex: [8,3] spans August to March.
    % Set mask values to true for selected month range.
    monthUsageMask(1:obj.OperationMonths(2)) = true;
    monthUsageMask(obj.OperationMonths(1):12) = true;

elseif obj.OperationMonths(1) <= obj.OperationMonths(2)
    % First month less than second implies staying within same year.
    % Ex: [3,8] spans March to August.
    % Note: We can also use this condition to check if the Fan operates
    % only over a single month.

    % Set mask values to true for selected month range.
    monthUsageMask(obj.OperationMonths(1):obj.OperationMonths(2)) = true;

end %endif (Month Range check)

% -- Apply Usage Mask to Set Unused Month Values to 0
% Apply mask directly to property.
MonthlyKWH(~monthUsageMask) = 0;

end %function

