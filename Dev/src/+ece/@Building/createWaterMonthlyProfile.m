function createWaterMonthlyProfile(bldg,waterMeters,waterRatios)
%CREATEWATERMONTHLYPROFILE Create the MonthlyProfile table for
%Water Utilities.
%   This MonthlyProfileTable is used to decribe the monthly use for a
%   utility over a year, and is created from the average monthly results
%   from a Utility's usage table.

%% Arguments Block
% Confirm input arguments
arguments
    % bldg: Self-referential Building object.
    bldg (1,1) ece.Building

   % waterMeters: Array of water meters serving building.
    waterMeters (:,1) ece.Water

    % waterRatios: Ratio of meter usage in building.
    waterRatios (:,1) double

end %argblock


%% Set Up Parameters for MonthlyTable Creation
% Pull required information from the inputs to ease downstream processing.
numMeters = length(waterMeters);


% -- Create Monthly Profile
% Based off normalized annual Heat/Cool. Adds on to base usage to have a
% normalized 12-month profile for use in Level 2 calculation. Monthly
% profile starts in January and is normalized to average year weather.
%  The monthly profile is a 12 row (per month) and 5-column table.
%   Table columns are: Month, IrrigationGals,
%   CoolingTowerGals, OtherGals, ResidentalGals, and Total.

% Preallocate Monthly matrix of values, the first row being 1:12.
monthlyProfile = zeros(12,6);
monthlyProfile(:,1) = (1:12)';

%% Iterate Through Each Meter
% Each meter will be used to generate a monthly usage table, which will be
% summed together for the building's single final MonthlyProfile table.

for meterIdx = 1:numMeters
    %% Extract Loop Properties from Inputs
    % Extract meter and proportion.
    wm = waterMeters(meterIdx);
    wmProp = waterRatios(meterIdx);

    % Extract AdjustedUsageTable Section and Proportionalize It
    % Note: The indices pulled are columns from AdjkWh and beyond, and also
    % including the initial kWh.
    propAdjustedUsageTable = wm.AdjustedUsageTable(:,...
        ["AdjGallons","IrrigationGals",...
        "CoolingTowerGals","OtherGals","ResidentialGals"]);
    propAdjustedUsageTable{:,:} = propAdjustedUsageTable{:,:} .* wmProp;

    % Iteratively extract months from AdjustedUsageTable in month order and ill
    % into the profile.
    for monthIdx = 1:12
        % Get Month Mask from standard Meter table (for rowmask)
        monthMask = wm.AdjustedUsageTable.Month == monthIdx;
        numMonthsFound = sum(monthMask);

        % Extract Gallon Values from Proportioned Table
        gallonVals = sum(propAdjustedUsageTable{monthMask,...
            ["IrrigationGals","CoolingTowerGals",...
            "OtherGals","ResidentialGals","AdjGallons"]}) / ...
            numMonthsFound;

        % Assign via addition to MonthlyProfile
        monthlyProfile(monthIdx,2:6) = monthlyProfile(monthIdx,2:6) + ...
            gallonVals;

    end %forloop

end %forloop

%% Assign to Output
bldg.MonthlyWaterProfile = array2table(monthlyProfile,...
    "VariableNames",["Month","IrrigationGals",...
    "CoolingTowerGals","OtherUseGals","ResidentialGals","TotalGallons"]);

end %function

