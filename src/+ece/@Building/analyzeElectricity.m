function analyzeElectricity(bldgs, elecMeters, elecRatios, ddTable, ...
    numYearsToAvg)
% analyzeElectricity method to calculate the annual electric usage table for each building
% and the Monthly profile tables.
% For each meter the adjusted usage table and the monthly profile and the
% annual usage table are developed.
% For each building the annual electric usage table and the monthly electric 
% usage profile are developed, using the gas meter ratios.

%% Arguments Block
% Confirm inputs.
arguments
    % bldg: Self-referential Building object.
    bldgs (:,1) ece.Building
    
    % Meters: Array of elec meters serving building.
    elecMeters (:,1) ece.Electricity

    % elecRatios: Ratio of each meter's usage in building.
    elecRatios (:,:) double

    % ddTable: Degree days table for corresponding container of utility.
    ddTable table
    
    % numYearsToAvg: Number of years to average together.
    numYearsToAvg (1,1) double;

end %argblock


%% Compute Values for calculation
% Pull required information from the inputs to ease downstream processing.
numMeters = length(elecMeters);
numBuildings = length(bldgs);

% Identify the meters serving each building
% Logical matrix with rows for each meter and columns for each building
% Based on if the meter ratio for that building is > 0
bldgMeters = zeros(numMeters, numBuildings);
bldgMeters = elecRatios > 0;
 
%% Analyze usage for each meter

for meterIdx = 1:numMeters
    em = elecMeters(meterIdx);

    % Set the end use breakout columns of the adjusted usage table to zeros.
    em.AdjustedUsageTable.Base = zeros(em.NumMonthsOfData, 1);
    em.AdjustedUsageTable.DHW = zeros(em.NumMonthsOfData, 1);
    em.AdjustedUsageTable.Heat = zeros(em.NumMonthsOfData, 1);
    em.AdjustedUsageTable.Cool = zeros(em.NumMonthsOfData, 1);
    em.AdjustedUsageTable.BasePlusDHW = zeros(em.NumMonthsOfData, 1);

    %% Meter serves a single end use
    % If this meter serves a single end use, there is no analysis, the whole
    % usage is assigned to that end use. This may arise if data from a
    % sub meter is entered or if a utility meter is dedicated to a single purpoose.

    
    % Baseload only
    if (em.IsBaseLoad & ~em.IsSpaceHeat & ~em.IsCooling & ~em.IsDHW)
        em.AdjustedUsageTable.Base = em.AdjustedUsageTable.AdjkWh;

    % Space heat only
    elseif (~em.IsBaseLoad & em.IsSpaceHeat & ~em.IsCooling & ~em.IsDHW)
        em.AdjustedUsageTable.Heat = em.AdjustedUsageTable.AdjkWh;

    % Space cooling only
    elseif (~em.IsBaseLoad & ~em.IsSpaceHeat & em.IsCooling & ~em.IsDHW)
        em.AdjustedUsageTable.Cool = em.AdjustedUsageTable.AdjkWh;

    % DHW only
    elseif (~em.IsBaseLoad & ~em.IsSpaceHeat & ~em.IsCooling & em.IsDHW)
        em.AdjustedUsageTable.DHW = em.AdjustedUsageTable.AdjkWh;

    end   % ifs

    % Meter serves more than one end  use.

    %% Meter serves baseload and cooling only.
    % Assign the slight baseload variation due to lighting using the maximum
    % usage in winter months when there is less daylight.
    % Remaining usage is cooling.
    if em.IsBaseLoad & ~em.IsSpaceHeat & em.IsCooling & ~em.IsDHW

        % Find the maximum usage in the NON cooling season. Take months of
        % November, December, and January. Average the two highest values.
        winterMonthkWh = [em.AdjustedUsageTable.AdjkWh(em.AdjustedUsageTable.Month == 1)', ...
            em.AdjustedUsageTable.AdjkWh(em.AdjustedUsageTable.Month == 11)', ...
            em.AdjustedUsageTable.AdjkWh(em.AdjustedUsageTable.Month == 12)'];

        maxNonCoolingMonthkWh = mean(maxk(winterMonthkWh, 2));

        % Set BaseUsage Values in Table
        % Compute the Base column for the AdjustedUsage table from the calculated
        % values above and the set BaseLoad Amplitude.

        % Initialize BaseAmp from properties of utility. This value is
        % typically 0.1, which means that base usage will be 10% greater in
        % December than in June due to increased usage for lighting (which is
        % a large fraction of the baseload). This is accomplished by making
        % the computed baseload have a small sine function variation.

        % Initialize BaseAmp from properties of utility.
        baseAmp = em.BaseElecAmplitude;

        % Given the maximum baseload usage, find the minimum baseload usage.
        minBasekWh = maxNonCoolingMonthkWh / (1 + baseAmp);

        % Calculate Base vector for inclusion in table. December max, June min.
        baseUsagePerMonth = minBasekWh .* ...
            ((1 + (baseAmp/2)) + ...
            (baseAmp / 2) * ...
            (cos((em.AdjustedUsageTable.Month) * (pi/6))));

        % Ensure that the base usage value is at most as much as the corresponding
        % adjkWh amount. Essentially pick the smaller of the two options.
        em.AdjustedUsageTable.Base = min(...
            baseUsagePerMonth, em.AdjustedUsageTable.AdjkWh);

        % The remaining usage is cooling.
        em.AdjustedUsageTable.Cool = em.AdjustedUsageTable.AdjkWh ...
            - em.AdjustedUsageTable.Base;

        % The adjusted usage table columns for DHW, heating, and DHW plus
        % baseload are zero as initialized.

    end % if for base and cooling only

    %% Meter serves baseload and space heating only
    % Assign the slight baseload variation due to lighting using the minimum
    % usage in summer months when there is most daylight.
    % Remaining usage is heating.
    if em.IsBaseLoad & em.IsSpaceHeat & ~em.IsCooling & ~em.IsDHW

        % Find the minimum usage in the NON heating season. Take months of
        % July and August. Average the two lowest values.
        summerMonthkWh = [em.AdjustedUsageTable.AdjkWh(em.AdjustedUsageTable.Month == 7)', ...
            em.AdjustedUsageTable.AdjkWh(em.AdjustedUsageTable.Month == 8)'];

        minBasekWh = mean(mink(summerMonthkWh, 2));

        % Set BaseUsage Values in Table
        % Compute the Base column for the AdjustedUsage table from the calculated
        % values above and the set BaseLoad Amplitude.

        % Initialize BaseAmp from properties of utility.
        baseAmp = em.BaseElecAmplitude;

        % Calculate Base vector for inclusion in table. December max, June min.
        baseUsagePerMonth = minBasekWh .* ...
            ((1 + (baseAmp/2)) + ...
            (baseAmp / 2) * ...
            (cos((em.AdjustedUsageTable.Month) * (pi/6))));

        % Ensure that the base usage value is at most as much as the corresponding
        % adjkWh amount. Essentially pick the smaller of the two options.
        em.AdjustedUsageTable.Base = min(...
            baseUsagePerMonth, em.AdjustedUsageTable.AdjkWh);

        % The remaining usage is heating.
        em.AdjustedUsageTable.Heat = em.AdjustedUsageTable.AdjkWh ...
            - em.AdjustedUsageTable.Base;

        % The adjusted usage table columns for DHW, cooling, and DHW plus
        % baseload are zero as initialized.

    end % if for base and heating only

    %% Meter serves baseload, DHW, and cooling
    % Same analysis method as for baseload and cooling but baseload and
    % DHW have to be lumped together.
    if em.IsBaseLoad & ~em.IsSpaceHeat & em.IsCooling & em.IsDHW
        % Find the maximum usage near the expected peak in January. Take months of
        % December, January, and February. Average the highest values.

        winterMonthkWh = [em.AdjustedUsageTable.AdjkWh(em.AdjustedUsageTable.Month == 12)', ...
            em.AdjustedUsageTable.AdjkWh(em.AdjustedUsageTable.Month == 1)', ...
            em.AdjustedUsageTable.AdjkWh(em.AdjustedUsageTable.Month == 2)'];

        maxNonCoolingMonthkWh = mean(maxk(winterMonthkWh, 2));

        % Set Base plus DHW Values in Table
        % Compute the Base plus DHW column for the AdjustedUsage table from the
        % calculated values above and the set the amplitude for the sin function.
        % Add baseload and DHW amplitude from properties of utility.
        amp = em.BaseElecAmplitude + em.SeasonalAmpDHWUse;

        % Set the minimum baseload plus DHW usage which occurs in July.
        minBasePlusDHW = maxNonCoolingMonthkWh / (1 + amp);

        % Calculate Base vector for inclusion in table. January max, July min.
        basePlusDHWUsagePerMonth = minBasePlusDHW .* ...
            ((1 + (amp/2)) + ...
            (amp / 2) * ...
            (cos((em.AdjustedUsageTable.Month) * (pi/6) - (pi/6))));

        % Ensure that the base usage value is at most as much as the corresponding
        % adjkWh amount. Essentially pick the smaller of the two options.
        em.AdjustedUsageTable.BasePlusDHW = min(...
            basePlusDHWUsagePerMonth, em.AdjustedUsageTable.AdjkWh);

        % The remaining usage is cooling.
        em.AdjustedUsageTable.Cool = em.AdjustedUsageTable.AdjkWh ...
            - em.AdjustedUsageTable.BasePlusDHW;

        % The adjusted usage table columns for DHW, heating, and DHW plus
        % baseload are zero as initialized.

    end % if for baseload, DHW, and cooling

    %% Meter serves baseload, space cooling, and space heating (not DHW)

    if em.IsBaseLoad & em.IsSpaceHeat & em.IsCooling & ~em.IsDHW

        % Initialize BaseAmp from properties of utility.
        baseAmp = em.BaseElecAmplitude;
    
        % Variables for calculation
        meterUsage = em.AdjustedUsageTable.Usage;
        HDD65 = em.AdjustedUsageTable.HDD65;
        CDD70 = em.AdjustedUsageTable.CDD70;

        % Make a ones vector for the base constant column of the input matrix.
        baseConst = ones(em.NumMonthsOfData, 1);

        % Make an input matrix with ones for the base constant, HDD and CDD.
        inputVariables = [baseConst, HDD65, CDD70];

        % This is a system of simultaneous linear equations with three variables.
        % Consider as:
        % modeled usage = B + H*HDD + C*CDD
        % B is baseload. H is use in kWh/HDD65. C is use in kWh/CDD70.
        % Write as a matrix equation. Solve with multi variable
        % regression using linear algebra matrix operation.
        % |inputVariables| * |coefficients| = |Usage|
        % Backslash is matrix left division.
        % |coefficients| = |InputMatrix| \ |Usage|
        coeffs = inputVariables \ meterUsage;
        baseLoad = coeffs(1);
        heatSlope = coeffs(2);
        coolSlope = coeffs(3);

        % Use this result to determine the average baseload, and the
        % heating/cooling slopes. Apply the modest sin wave
        % variation to the baseload (peak in December with less daylight
        % due to ligting being a large fraction of the baseload, minimum
        % in June).
        % The remaining usage in each monthly period after baseload is
        % subtracted from total is either heating or cooling, and it is
        % apportioned according to the fractions of heating/cooling in each
        % month predicted by the results of the regression.
        % Check for future work. Zero out cooling in mid winter months and 
        % heating in mid summer months?

        % Construct a vector based on ones for the baseload but with the slight
        % variation due to increased lighting in winter.
        baseUsageVector = (1 - baseAmp/2) .* ...
                ((1 + (baseAmp/2)) + ...
                (baseAmp / 2) * ...
                (cos((em.AdjustedUsageTable.Month) * (pi/6))));

        % Apply to the average baseload from the regression.
        em.AdjustedUsageTable.Base = baseLoad * baseUsageVector;
        
        % Subtract baseload from total.
        HVACusage = em.AdjustedUsageTable.AdjkWh - em.AdjustedUsageTable.Base;

        % Apportion heating cooling amounts for each month according to the 
        % ratio predicted by the regression.
        heatFrac = (heatSlope * HDD65) ./ (heatSlope * HDD65 + coolSlope * CDD70);
        coolFrac = 1 - heatFrac;
        em.AdjustedUsageTable.Heat = heatFrac .* HVACusage;
        em.AdjustedUsageTable.Cool = coolFrac .* HVACusage;

        % The adjusted usage table columns for DHW and DHW plus baseload are
        % zero as initialized.

    end % if statement for usage flags are base, heat, cool

    %% Meter serves baseload, space cooling, and space heating (not DHW)
    % We are not presently able to analyze this case.
    if em.IsBaseLoad & em.IsSpaceHeat & em.IsCooling & em.IsDHW
     
    end  % if statement for meter serving base, heat, cool, and DHW

end  % for loop for meters adjusted usage tables


%% Create annual usage table for each meter
% Compute annual values for the annual usage table.
% For each column of table (except the last two) the first N rows, where N is number
% of years, corresponds to the sum of the monthly value for that year. To
% compute these, we will iterate through each year and extract the
% required values to store in the AnnualUsageTables' first N rows.

% Iterate through each meter.
for meterIdx = 1:numMeters

    em = elecMeters(meterIdx);

    % Define Building Meter Usage Table variables.
    meterUsageVariables = ["Property", ...
        "kWh", "AdjkWh", "HDD65", "CDD70",...
        "Base", "DHW", "Heat", "Cool", "BasePlusDHW", "Cost", ...
        "HeatSlope", "CoolSlope"];
    numMeterUsageVariables = length(meterUsageVariables);

    em.AnnualUsageTable = table('Size', [em.NumberOfYears+2, numMeterUsageVariables],...
        'VariableTypes', ["string", repmat("double", 1, numMeterUsageVariables-1)],...
        'VariableNames', meterUsageVariables);

    em.AnnualUsageTable.Property(1:2) = ["Average"; "Fraction Total"];

    % Compute annual values. Sum the 12 monthly values for each year of data
    for yearIdx = 1:em.NumberOfYears
        % Compute monthly index
        monthIndices = (1:12) + ((yearIdx-1) * 12);

        % -- Assign Year (as Property)
        % Identify the 12 month period by the predominant year.
        % If each of the two years has 6 months, take the first year.
        firstTwelveMonthsYears = em.AdjustedUsageTable.Year(monthIndices);
        [C, ia, ic] =unique(em.AdjustedUsageTable.Year(monthIndices));
        if sum((ic == 1)) > 5
            em.AnnualUsageTable.Property(yearIdx+2) = firstTwelveMonthsYears(1);
        else em.AnnualUsageTable.Property(yearIdx+2) = firstTwelveMonthsYears(12);
        end % if statement

         % -- Assign Column Values Per Year
        % Extract and compute sums.
        % Total kWh
        em.AnnualUsageTable.kWh(yearIdx+2) = sum(...
            em.AdjustedUsageTable.Usage(monthIndices));

        % Adjusted kWh
        em.AnnualUsageTable.AdjkWh(yearIdx+2) = sum(...
            em.AdjustedUsageTable.AdjkWh(monthIndices));

        % HDD65
        em.AnnualUsageTable.HDD65(yearIdx+2) = sum(...
            em.AdjustedUsageTable.HDD65(monthIndices));

        % CDD70
        em.AnnualUsageTable.CDD70(yearIdx+2) = sum(...
            em.AdjustedUsageTable.CDD70(monthIndices));

        % Baseload kWh
        em.AnnualUsageTable.Base(yearIdx+2) = sum(...
            em.AdjustedUsageTable.Base(monthIndices));

        % DHW
        em.AnnualUsageTable.DHW(yearIdx+2) = sum(...
            em.AdjustedUsageTable.DHW(monthIndices));

        % Space Heat
        em.AnnualUsageTable.Heat(yearIdx+2) = sum(...
            em.AdjustedUsageTable.Heat(monthIndices));

        % Space Cooling
        em.AnnualUsageTable.Cool(yearIdx+2) = sum(...
            em.AdjustedUsageTable.Cool(monthIndices));

        % Baseload plus DHW (for cases where these get lumped together)
        em.AnnualUsageTable.BasePlusDHW(yearIdx+2) = sum(...
            em.AdjustedUsageTable.BasePlusDHW(monthIndices));

        % Cost
        em.AnnualUsageTable.Cost(yearIdx+2) = sum(...
            em.AdjustedUsageTable.Cost(monthIndices));

    end % for loop years

    % Calculate averages for columns and put in row 1 of meter annual usage table.
    % Add fraction of total in row 2.
    avgColNames = ["kWh","AdjkWh", "HDD65", "CDD70", "Base", ...
        "DHW", "Heat", "Cool", "BasePlusDHW", "Cost"];
    avgColVals = mean(em.AnnualUsageTable{3:em.NumberOfYears+2, avgColNames}, 1);
    em.AnnualUsageTable{1, avgColNames} = avgColVals;

    % Add heating and cooling slopes, kWh/HDD65 and kWh/CDD70.
    em.AnnualUsageTable.HeatSlope([1, 3:end]) = ...
        em.AnnualUsageTable.Heat([1, 3:end]) ./ ...
        em.AnnualUsageTable.HDD65([1, 3:end]);

    em.AnnualUsageTable.CoolSlope([1, 3:end]) = ...
        em.AnnualUsageTable.Cool([1, 3:end]) ./ ...
        em.AnnualUsageTable.CDD70([1, 3:end]);

    % Add the fraction of usage for the components.
    fracTotalColNames = ["kWh","AdjkWh", "Base", "DHW", "Heat", ...
        "Cool", "BasePlusDHW"];
    fracTotalVals = em.AnnualUsageTable{1, fracTotalColNames} / ...
        em.AnnualUsageTable{1,"kWh"};
    em.AnnualUsageTable{2, fracTotalColNames} = fracTotalVals;

  end % for loop for meters annual tables


%% Make monthly profile for each meter

% Develop monthly profile of electricity usage for each component
% (base, DHW, heating, cooling) based on the usage that would occur
% in a year of average weather. Average weather is defined as the average
% number of heating degree days to base 65F over the past X years -
% usually the past 5 years. And the average number of cooling degree days
% to base 70F over the past X years.

% Use the historical daily degree day table to find average HDD/year
% and average CDD/year.

% Convert years to average to number of days (no leap years)
numDaysToAvg = numYearsToAvg * 365;
lastXYearsIndices = (height(ddTable) + 1 - numDaysToAvg) : height(ddTable);

% Pull out Last X years of HDD/CDD per year.
% The below line pulls the last 5 years of the corresponding
% column by index, resulting in the last 5 years of results
avgHDD = sum(ddTable.HDD65(lastXYearsIndices)) / numYearsToAvg;
avgCDD = sum(ddTable.CDD70(lastXYearsIndices)) / numYearsToAvg;

% Monthly profile starts in January.
% The monthly profile is a 12 row (per month) and 7-column table.
% The columns are: 1 month number, 2 base usage, 3 DHW, 4 heating, 
% 5 cooling, 6 Base plus DHW (for certain cases where these are lumped),
% 7 total electric usage in kWh.

for meterIdx = 1:numMeters
    em = elecMeters(meterIdx);

    % Preallocate Monthly matrix of values, the first row being 1:12.
    monthlyProfile = zeros(12,7);
    monthlyProfile(:,1) = (1:12)';

    % Iteratively extract months from AdjustedUsageTable in month order and fill
    % into the profile. Take the mean of all the Januarys, then all the
    % Februarys, etc.
    for monthIdx = 1:12
        % Month mask for each month in turn.
        monthMask = em.AdjustedUsageTable.Month == monthIdx;
        numMonthsFound = sum(monthMask);

        monthlyProfileSumCols = ["Base", "DHW", "Heat", "Cool", "BasePlusDHW"];
        % Extract kWh Values from adjusted usage table
        % Since there might be only one year of data, make sure to add the
        % "1" to the sum function, summing the columns.
        kWhVals = sum(em.AdjustedUsageTable{monthMask, ...
            monthlyProfileSumCols}, 1) / numMonthsFound;

        % Assign via addition to MonthlyProfile
        monthlyProfile(monthIdx, 2:6) = monthlyProfile(monthIdx,2:6) + ...
            kWhVals;

    end %forloop months

    % Clean any NaN
    monthlyProfile(isnan(monthlyProfile)) = 0;

    % Normalize any space heating / cooling usage using the average HDD/CDD
    % and the heat/cool slopes for this meter. kWh
    normAnnualHeating = avgHDD * em.AnnualUsageTable.HeatSlope(1);
    normAnnualCooling = avgCDD * em.AnnualUsageTable.CoolSlope(1);

    % Normalize Monthly Table Results
    % Note, if there are any NaN's in the monthly table for space heat, the
    % sum of that column will be NaN, elecHeatAdj will be NaN, and calc will
    % fail.
    elecHeatAdj = normAnnualHeating / sum(monthlyProfile(:, 4));
    monthlyProfile(:, 4) = elecHeatAdj * monthlyProfile(:, 4);
    elecCoolAdj = normAnnualCooling / sum(monthlyProfile(:, 5));
    monthlyProfile(:, 5) = elecCoolAdj * monthlyProfile(:, 5);

    % Clean any NaN
    monthlyProfile(isnan(monthlyProfile)) = 0;

    % Fill in the totals column
    monthlyProfile(:, 7) = sum(monthlyProfile(:, 2:6), 2);

    % Convert to table for storage
    em.MonthlyProfile = array2table(monthlyProfile, ...
        "VariableNames",["Month", "Base_kWh", "DHW_kWh", "Heat_kWh", ...
        "Cool_kWh", "BasePlusDHW_kWh", "Total_kWh"]);

end % for loop meters monthly profiles

%% Combine meters to get annual and monthly profile tables for each building
% For each building, sum the meter annual usage tables and monthly
% profiles serving that building. Add the fraction of each meter that
% applies to the building.

for bldgIdx = 1:numBuildings

    % Define Building Meter Usage Table variables.
    bldgUsageVariables = ["Property", "MeterCount", "HDD65", "CDD70", ...
        "TotalkWh", "Base", "DHW", "Heat", "Cool", ...
        "BasePlusDHW", "Cost"];
    numBldgUsageVariables = length(bldgUsageVariables);

    % Create Default Table for Accumulating Meter Results
    buildingUsageTbl = table('Size',[0, numBldgUsageVariables],...
        'VariableTypes',["string", repmat("double", 1, numBldgUsageVariables-1)], ...
        'VariableNames', bldgUsageVariables);

    % Create Default Table for Accumulating Statistics
    buildingStatsTbl = table('Size',[3, numBldgUsageVariables],...
        'VariableTypes',["string", repmat("double", 1, numBldgUsageVariables-1)], ...
        'VariableNames', bldgUsageVariables);

    % Set Property Strings
    buildingStatsTbl.Property = ["Average";...
        "Fraction of Total";...
        "kBtu/ft2"];

    % Set default values to NaN
    buildingStatsTbl{:,2:end} = nan(3,numBldgUsageVariables-1);

    % Create table for accumulating monthly profiles
    sumMonthlyProfiles = zeros(12, 7);
    sumMonthlyProfiles(:,1) = (1:12)';

    % What meters serve this building? This is all the rows and one column
    % of the logical array for meters serving buildings ("bldgMeters").
    meters = [1:numMeters]';
    thisBldgMeters = meters(bldgMeters(:, bldgIdx));

    % Take each of the meters serving this building in turn.
    for meterIdx = 1:numel(thisBldgMeters)
        em = elecMeters(thisBldgMeters(meterIdx));

        % First part, take fractions of meter annual usage tables for DHW 
        % and space heat and sum. Gas meter ratio applied to this building.
        emRatioBldg = elecRatios(thisBldgMeters(meterIdx), bldgIdx);

        % Create a table with the fraction of meter's usage.
        fracAnnualUsageTable = em.AnnualUsageTable;
        % Remove heating and cooling slope from table.
        fracAnnualUsageTable = removevars(fracAnnualUsageTable, ["HeatSlope", ...
            "CoolSlope"]);

        % Add MeterCount variable to the meter's fractional usageTable and 
        % make it the second column.
        fracAnnualUsageTable.MeterCount = ones(em.NumberOfYears+2, 1);
        fracAnnualUsageTable = movevars(fracAnnualUsageTable, ...
            "MeterCount", 'After', "Property");

        % Remove the kWh and adjkWh columns from the table and
        % replace with TotalkWh which will be calculated later by adding the
        % components.
        fracAnnualUsageTable = removevars(fracAnnualUsageTable, ...
            ["kWh", "AdjkWh"]);
        fracAnnualUsageTable.TotalkWh = nan(em.NumberOfYears+2, 1);
        fracAnnualUsageTable = movevars(fracAnnualUsageTable, ...
            "TotalkWh", 'After', "CDD70");

        % Assign fractions of usage for each component to building based 
        % on the building electric ratios. Default ratios are based on 
        % the conditioned square footage of the buildings.
        % The cost for each year will be determined later.
        propColNames = ["Base", "DHW", "Heat", "Cool", "BasePlusDHW"];
        fracAnnualUsageArray = em.AnnualUsageTable{[1, 3:end], propColNames} .* emRatioBldg;
        fracAnnualUsageTable{[1, 3:end], propColNames} = fracAnnualUsageArray;
        
        % Append new table underneath existing table.
        tempTable = [buildingUsageTbl; fracAnnualUsageTable];

        % Use varfun to assign new table.
        %   InputVariables: Vars to sum together.
        %   GroupingVariables: Vars to group by (ID column)
        %   Most vars are summed, but HDD's and CDD's must be averaged.
        buildingUsageSumTbl = varfun(@sum, tempTable,...
            "GroupingVariables", "Property",...
            "InputVariables", ["MeterCount", "TotalkWh", "Base", ...
            "DHW", "Heat", "Cool", "BasePlusDHW", "Cost"]);

        buildingUsageAvgTbl = varfun(@mean, tempTable, ...
            "GroupingVariables", "Property",...
            "InputVariables", ["HDD65", "CDD70"]);

        % Clear Groupcount Column
        %   This column is added to show how rows are grouped. We can erase
        %   this because it isn't actually a cumulative addup of meters -that's
        %   what the MeterCount column is for.
        buildingUsageSumTbl.GroupCount = [];
        buildingUsageAvgTbl.GroupCount = [];

        % Combine Varfunned Tables back into Full Table with original
        % variable names.
        % Sum Table
        buildingUsageSumTbl.Properties.VariableNames = ["Property", ...
            "MeterCount", "TotalkWh", "Base", "DHW", "Heat", ...
            "Cool", "BasePlusDHW", "Cost"];
        % Mean Table
        buildingUsageAvgTbl.Properties.VariableNames = ["Property", "HDD65", "CDD70"];

        % Join Separated Tables together for BuildingUsageTbl
        buildingUsageTbl = join(buildingUsageSumTbl, buildingUsageAvgTbl);

        % Restore the original order of variables in the table.
        buildingUsageTbl = movevars(buildingUsageTbl, ["HDD65", "CDD70"], 'After', ...
            "MeterCount");

        % Second part, take fractions of monthly profiles and sum.
        % Create an array with a fraction of the monthly profile for the
        % columns of DHW and space heating only. Other columns filled in
        % for the building as a whole.
        fracMonthlyProfileArray = em.MonthlyProfile{:, 2:7} * emRatioBldg;
        sumMonthlyProfiles(:, 2:7) = sumMonthlyProfiles(:, 2:7) + fracMonthlyProfileArray;

    end % for loop for meters

 % Total usage for building is sum of the component usages.
    buildingUsageTbl{1:end-1, "TotalkWh"} = ...
        sum(buildingUsageTbl{1:end-1, ["Base", "DHW", "Heat", ...
            "Cool", "BasePlusDHW"]}, 2);
    
    % Cost. Determine the average unit cost for gas from the average 
    % row of each meter's annual usage table. Weighted by the amount of use
    % on the meter.
    for meterIdx = 1:numel(thisBldgMeters)
        meter = thisBldgMeters(meterIdx);
        unitCostElec(meterIdx) = elecMeters(meter).AnnualUsageTable.Cost(1) ...
            / elecMeters(meter).AnnualUsageTable.AdjkWh(1);
        totalUseMeters(meterIdx) = elecMeters(meter).AnnualUsageTable.AdjkWh(1);
    end % for loop unit cost
    avgUnitCostElec = sum((unitCostElec .* totalUseMeters)) / sum(totalUseMeters);

    % Determine the cost of gas for each year and for the average year.
    buildingUsageTbl{1:end-1, "Cost"} = ...
        buildingUsageTbl{1:end-1, "TotalkWh"} * avgUnitCostElec;
  
    % Add heating and cooling slopes. kWh/DD.
    buildingUsageTbl.HeatSlope = nan(numel(buildingUsageTbl.Property), 1);
    buildingUsageTbl.HeatSlope(1:end-1) = ...
        buildingUsageTbl.Heat(1:end-1) ./ ...
        buildingUsageTbl.HDD65(1:end-1);

    buildingUsageTbl.CoolSlope = nan(numel(buildingUsageTbl.Property), 1);
    buildingUsageTbl.CoolSlope(1:end-1) = ...
        buildingUsageTbl.Cool(1:end-1) ./ ...
        buildingUsageTbl.CDD70(1:end-1);
    
    % Set up the 2 additional statistics rows of the annual usage table.
    % 1 average usage - already have, 2 fraction of total, 3 kBtu/ft2 .

    % The fraction of total usage for each component, in the average row. 
    % Set up names of proportional columns.
    propColNames = ["TotalkWh", "Base", "DHW", "Heat", "Cool", "BasePlusDHW"];
    buildingUsageTbl{end, propColNames} = buildingUsageTbl{end-1, propColNames} / ...
        buildingUsageTbl.TotalkWh(end-1);

    % The third stats row is kBtu/ft2 area (gross conditioned area in square feet).
    % Set up name of area columns.
    areaColNames = ["TotalkWh", "Base", "DHW", "Heat", "Cool", "BasePlusDHW"];

    % Make a temporary table for added row.
     variableNames = ["Property", "MeterCount", "HDD65", "CDD70", ...
        "TotalkWh", "Base", "DHW", "Heat", "Cool", ...
        "BasePlusDHW", "Cost", "HeatSlope", "CoolSlope"];
    numCols = length(variableNames);

    kBtuFt2Row = table('Size',[1, numCols], ...
        'VariableTypes',["string", repmat("double", 1, numCols-1)],...
        'VariableNames', variableNames);
    kBtuFt2Row.Property(1) = ["kBtu/ft2"];
    kBtuFt2Row{1, areaColNames} = buildingUsageTbl{end-1, areaColNames} * ...
        3413 / 1000 / bldgs(bldgIdx).GrossConditionedArea_ft2;

    % Construct the final version of the building usage table with the rows
    % arranged in a logical manner.
    buildingUsageTbl = [buildingUsageTbl(end-1:end, :); ...
        kBtuFt2Row; buildingUsageTbl(1:end-2, :)];
   
    % Clear any nan's from slope variables.
    buildingUsageTbl.HeatSlope(isnan(buildingUsageTbl.HeatSlope)) = 0;
    buildingUsageTbl.CoolSlope(isnan(buildingUsageTbl.CoolSlope)) = 0;
     
    % Write the annual usage table and monthly profile for the building into
    % its allocated properties
    bldgs(bldgIdx).AnnualElectricUsageTable = buildingUsageTbl;

    % Complete the monthly profile summing the components to get the total usage.
    % And make it into a table.
    bldgMonthlyProfile = array2table(sumMonthlyProfiles, "VariableNames", ...
        ["Month", "Base_kWh", "DHW_kWh", "Heat_kWh", "Cool_kWh", ...
        "BasePlusDHW_kWh", "Total_kWh"]);
    bldgs(bldgIdx).MonthlyElectricProfile = bldgMonthlyProfile;

end  % for loop buildings analysis    

end %function

