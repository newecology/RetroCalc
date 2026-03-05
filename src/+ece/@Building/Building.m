classdef Building < handle & matlab.mixin.Copyable
    %BUILDING Class definition file for Building object.
    %   A Building object is a collection of properties and methods that
    %   define a Building within the New Ecology ASHRAE calculation
    %   workflow.
    %
    %   Properties of the Building class include information relating to
    %   the building itself (such as location and number of occupants) as
    %   well as information about what the building contains (such as
    %   Ventilations, HVAC, and other systems.) These systems are organized
    %   into their own class objects.
    %
    %   Methods of the Building class include aggregating the relevant
    %   information from its component properties.

    properties (Access = public, AbortSet, SetObservable)
        % -- Observable Public Detail Properties
        % This block will define properties that, when changed, should
        % trigger the "BuildingPropsChanged" event.

        % Name: Building name. Can be the actual building name or just a
        % string identifier for the building.
        Name (1,1) string = "Default Building";

        % Location: String name of Location.
        Location (:,1) ece.Location = ece.Location.empty(0,1);

        %building areas (gross area, gross conditioned area, interior
        %conditioned area)
        GrossArea_ft2 (1,1) double

        % GrossConditionedArea_ft2: Building conditioned area in 
        % square feet.
        GrossConditionedArea_ft2 (1,1) double

        % InteriorConditionedArea_ft2: Interior building conditioned area
        % in square feet.
        IntConditionedArea_ft2 (1,1) double

        % PercentConditionedArea: Percent of conditioned area that 
        % is cooled, 0 to 100
        PercentCondAreaCooled (1,1) double

        % NumberOfUnits: Number of units in building.
        % MW_MISU: Will this need to be pulled out and become a dependent
        % property on the NumberOfBedroomUnits?
        NumberOfUnits (1,1) double

        % NumberOfBedroomUnits: Number of units with X bedrooms.
        % Example: [number of 1 bedroom units, 2 bedroomm units, 
        % 3 bedroom units, 4 bedroom units]
        NumberOfBedroomUnits (1,4) double = [0, 0, 0, 0]

        % NumberOfOccupants: Number of building occupants.
        NumberOfOccupants (1,1) double

        % PopulationType: Type of population residing in building.
        PopulationType (1,1) ece.enum.PopulationType = ...
            ece.enum.PopulationType.Mixed;

        % NumberOfStories: Number of stories (floors) of building.
        NumberOfStories (1,1) double {mustBeInteger}

        % YearOfConstruction: Year building was constructed.
        YearOfConstruction (1,1) double {mustBeInteger}

        % ThermalMass: Thermal mass type of building.
        ThermalMass (1,1) ece.enum.ThermalMassType = ...
            ece.enum.ThermalMassType.Light;

        % IntVolume_ft3: Interior building volume in cubic feet.
        IntVolume_ft3 (1,1) double = 0;

        % AirLeakageRate_cfm50perFt2: Air leakage rate for building.
        AirLeakageRate_cfm50perFt2 (1,1) double = 0;

        % SheildingClass: Class of sheilding of Building. Must be a value
        % between one and 5.
        ShieldingClass (1,1) double = 3  % add mustBeMember 1 to 5

        % EffectiveLeakFactor: Defines. an effective leakage factor with
        % default value of .055.
        EffectiveLeakFactor (1,1) double {mustBePositive} = .055

        % HeatCoolSeasonStartEndData: Array of heat/cool start and end
        % heating season start date, heating season end date, cooling
        % season start date, cooling season end date
        HeatCoolSeasonStartEndDates (1,4) datetime = ...
            datetime(["01-Oct-2024", "15-May-2024", ...
            "15-May-2024", "15-Oct-2024"])

        % HVACStartEndTimePeriod1: Start and end times for HVAC time period
        % 1, represented in military integers.
        % Integer 8 = 8am. Integer 18 = 6pm.
        % Note: Time period 2 is all other times.
        HVACStartEndTimePeriod1 (1,2) double {mustBeInteger} = [6, 18]

        % HeatCoolSetpoints: Set points for heating and cooling.
        % Heating time period 1, heating time period 2, and
        % cooling time period 1, cooling time period 2, and
        % cooling RH, heating RH.
        HeatCoolSetpoints (1,6) double {mustBeInteger} = ...
            [72, 72, 74, 74, 60, 40]

        % EnergySourceForDHW
        EnergySourceForDHW (1,1) ece.enum.EnergySourceType = ...
            ece.enum.EnergySourceType.Gas;

        % CarbonEqValueElectricity_kgPerkWh: Carbon equivalent of
        % Electricity, in units of kg per kilowatt-hour.
        CarbonEqValueElectricity_kgPerkWh (1,1) double = 0;

        % CarbonEqValueGas_kgPerTherm: Carbon equivalent of Gas, in units
        % of kg per therm.
        CarbonEqValueGas_kgPerTherm (1,1) double = 0;

        % CarbonEqValueOil_kgPerTherm: Carbon equivalent of Oil, in units
        % of kg per therm.
        CarbonEqValueOil_kgPerGallon  (1,1) double = 0;      

        % CarbonEqValuePropane_kgPerTherm: Carbon equivalent of Propane, in units
        % of kg per therm.
        CarbonEqValuePropane_kgPerGallon (1,1) double = 0;

        % BuildingEnvelope: Total building envelope area,including the
        % sum of glazing, opaque, below grade and slab on grade areas.
        BuildingEnvelopeArea (1,1) double  = 0;

        % TotalSolarGains: Array of solar gain that enters the building 
        % for each month, kBtu.
        TotalSolarGains (12,1) double = zeros(12,1);

        % WeatherMonthly: 6x24 matrix of monthly Weather Data.
        % 24 columns for time 1 and time 2 in each month
        % 3 rows for HDD, CDD, enthalpy days as well as 3 more rows 
        % for avg temp, avg enthalpy, and average wind speed
        WeatherMonthly (6,24) double = zeros(6,24);

        % BuildingWeatherTable: Table of WeatherDat unique to Building,
        % derived from Location's WeatherDataTable.
        BuildingWeatherTable table

        % Packages: Collection of Packages to apply to this Building.
        Packages (:,1) ece.Package = ece.Package.empty(0,1);

    end %properties (public)


    properties (SetAccess = private, GetAccess = public, SetObservable)
        % -- Annual Utility Table Properties
        % AnnualElectricUsageTable: Table of annual Electric usage for the
        % building based on provided Meters.
        AnnualElectricUsageTable table

        % MonthlyElectricProfile: Tabular profile of monthly electric use
        % over a period of 12 months.
        MonthlyElectricProfile table

        % AnnualGasUsageTable: Table of annual Gas usage for the
        % building based on provided Meters.
        AnnualGasUsageTable table

        % MonthlyGasProfile: Tabular profile of monthly gas use over a
        % period of 12 months.
        MonthlyGasProfile table

        % AnnualWaterUsageTable: Table of annual Water usage for the
        % building based on provided meters.
        AnnualWaterUsageTable table

        % MonthlyWaterProfile: Tabular profile of monthly Water usage for
        % the building over a period of 12 months.
        MonthlyWaterProfile table

        % AnnualOilUsageTable: Table of annual oil usage for the
        % building based on provided Meters.
        AnnualOilUsageTable table

        % MonthlyOilProfile: Tabular profile of monthly oil use over a
        % period of 12 months.
        MonthlyOilProfile table

        % AnnualPropaneUsageTable: Table of annual Propane usage for the
        % building based on provided Meters.
        AnnualPropaneUsageTable table

        % MonthlyPropaneProfile: Tabular profile of monthly Propane use over a
        % period of 12 months.
        MonthlyPropaneProfile table      

        % HEA: Historical Energy Analysis KeyResults object.
        HEA (1,1) ece.KeyResults

        % Level2: Level2 Analysis KeyResults object.
        Level2 (1,1) ece.KeyResults

        % PackageSummaryTable: Single table of all Applied Package results.
        PackageSummaryTable (:,:) table

        % ECMSummaryTables: Cell collection of ECM Summary Tables. There
        % will be one table per Package, and each table describes the
        % effects of the Package's ECMs on the Building it is applied to.
        ECMSummaryTables (:,1) cell = cell.empty(0,1);

    end %properties (public get, private set, observable)

    % Properties that need to be created in AnalyzeGas
    properties (Access = public, SetObservable)
        % % AnnualGasUsageTable: Table of annual Gas usage for the
        % % building based on provided Meters.
        % AnnualGasUsageTable table
        % 
        % % MonthlyGasProfile: Tabular profile of monthly gas use over a
        % % period of 12 months.
        % MonthlyGasProfile table

    end


    properties (Access = public)
        % -- Object Properties of Building Class.

        % Airmovers: Array collection of Airmover objects.
        Airmovers (:,1) ece.Airmovers = ece.Airmovers.empty(0,1);

        % Pumps: Array collection of Pump objects.
        Pumps (:,1) ece.Pump = ece.Pump.empty(0,1);

        % OpaqueSurfaces: Array of opaque surface objects.
        OpaqueSurfaces (:,1) ece.OpaqueSurface = ...
            ece.OpaqueSurface.empty(0,1);

        % GlazedSurfaces: Array of glazing surface objects.
        GlazedSurfaces (:,1) ece.Glazing = ece.Glazing.empty(0,1);

        % BelowGradeSurfaces: Array of below grade surface objects.
        % One instance of BelowGradeSurfaces covers one below grade space
        % such as a basement or crawl space.
        % Normally there is only one if any instance of below grade
        % surfaces for one building, but this allows for more than one set
        % of below grade surfaces to be entered.
        BelowGradeSurfaces (:,1) ece.BelowGradeSurface = ...
            ece.BelowGradeSurface.empty(0,1);

        % SlabOnGrade: Array of slab on grade objects.
        % Normally there is only one (if any) slab on grade for one
        % building.
        SlabOnGrade (:,1) ece.SlabOnGrade = ece.SlabOnGrade.empty(0,1);

        % Spaces: Array of Space objects.
        Spaces (:,1) ece.Space = ece.Space.empty(0,1);

        % Appliances: Array of appliance objects.
        Appliances (:,1) ece.Appliance = ece.Appliance.empty(0,1)

        % PlumbingFixtures: Array of plumbing fixture objects.
        PlumbingFixtures (:,1) ece.PlumbingFixture = ...
            ece.PlumbingFixture.empty(0, 1);

        % DHWsystem: Domestic hot water system object array.
        DHWsystems (:,1) ece.DHWsystem = ece.DHWsystem.empty(0,1);

        % DHW tanks: Array of DHW tanks objects.
        DHWtanks (:,1) ece.DHWtanks = ece.DHWtanks.empty(0, 1);

        % DHWpipesMechRoom: Array of DHW pipes.
        DHWpipesMechRoom (:, 1) ece.DHWpipesMechRoom = ...
            ece.DHWpipesMechRoom.empty(0, 1);

        % HeatCool: Heating and cooling object.
        HeatCool (:,1) ece.HeatCool = ece.HeatCool.empty(0,1);

    end  %properties (object properties)


    properties (SetAccess = private, GetAccess = public)
        % -- Define Read-Only Properties
        % Degree days and average temperatures, enthalpy, and wind speed
        DegreeDaysTable (:,:) table

        % water usage by fixture and month and totals
        WaterUsageTable (:,:) table

        % water heater usage energy, losses, input energy, internal gains
        DHWenergyUsageTable (:,:) table

        % energy for controls on DHW heaters and tanks
        DHWcontrolsTable (:,:) table
        
        % DHW fuel usage table. Energy use of DHW systems by energy source:
        % electricity, gas, oil, or propane.
        DHWfuelTable (:,:) table

        % heating ventilation flow 24 rows for day/night for each month
        % two columns for balanced, unbalanced
        HtngVentilationFlow (24,2) double

        %cooling ventilation flow 24 rows for day/night for each month
        % two columns for balanced, unbalanced
        ClngVentilationFlow (24,2) double

        % table to show energy use results for all appliances combined to the user
        ApplianceResultsTable (:,:) table

        % appliance results array for all appliances combined for use in calculations
        ApplianceEnergyTable12 (:,:) table

        % Electric usage and internal gains table, one row per month with
        % an additional row for annual roll-up.
        InternalGainsTable (13,:) table
        ElectricUsageTable (13,:) table

        % Array of size 24x3. 
        % 1st col: Heating sensible gains 
        % 2nd row: Total cooling sensible and latent 
        % 3rd row: Latent heat gains
        InternalGainsArray_kBtu (24,3) double = zeros(24,3);

        % Energy usage for space heating in kBtu and in units for each
        % energy source (electricity, gas, oil, propane).
        SpaceHeatingTable_kBtu (:,16) table
        HeatFuelTable (13,:) table

        % Same for space cooling.
        SpaceCoolingTable_kBtu (:,16) table
        SpaceCoolingTable_kWh (:,16) table

        % Table with the total energy used in the building (electricity,
        % gas, oil, propane). More energy types could be added.
        BuildingEnergyUsageTable (13, :) table

        % HeatLossComponentsTable: Table of HeatLoss Component collections.
        HeatLossComponentsTable table

        % RunStatsTable: The Level2 Output table.
        RunStatsTable table

        % HasLevel2Results: Flag to indicate the Building has Level 2
        % results.
        HasLevel2Results (1,1) logical = false;

        % HasHEAResults: Flag to indicate the Building has HEA results.
        HasHEAResults (1,1) logical = false;

        % HasAppliedPackages: Flag to indicate the Building has Packages
        % applied to it.
        HasAppliedPackages (1,1) logical = false;

    end %properties (Read-Only)


    properties (Access = public, Dependent)
        % CanUndergoHEA: Flag that checks the internal tables of the
        % Building object to determine if it is ready for HEA processing.
        CanUndergoHEA (1,1) logical

        % UsageComparisonTable: Table that shows the relationship between
        % the HEA and Level2 Results.
        UsageComparisonTable (:,5) table

        % NumPackages: Number of Packages in Building.
        NumPackages (1,1) double

        % DisplayPackageSummaryTable: Display string version of the
        % PackageSummaryTable that has decimal truncation.
        DisplayPackageSummaryTable table

        % DisplayECMSummaryTables: Display string version of the
        % ECMSummaryTable that has decimal truncation.
        DisplayECMSummaryTables table

    end %properties (Dependent)

    methods 
        % -- Internals-related Class Methods
        % Define Constructor Method
        function obj = Building()
            %BUILDING Construct an instance of the Building class.
            %   The default Building constructor takes no arguments and
            %   returns a default instance of the Building object. A
            %   Building object with loaded values can be instanced with
            %   the fromSourceData static method.
            %   This object construction style is useful when testing
            %   objects that are intended to be populated from externa
            %   data, as it decouples the object's existence from the
            %   intended supplemental data.

        end %function (constructor)   


        function value = get.NumPackages(obj)
            % Getter for NumPackages.
            %   Returns the number of Packages in Building.
            value = numel(obj.Packages);

        end %function


        function value = get.CanUndergoHEA(obj)
            % Getter method for CanUndergoHEA property.
            %   Flag for determining if a Building can undergo the HEA
            %   analysis. This is based solely on the empty/filled state of
            %   the Utility usage tables within the Building. They must ALL
            %   be filled in order for the HEA calculation to be done.
            %  Note: This logical is allowed because even if a utility is
            %  not included in the building, the corresponding utility
            %  table is still filled out, just with NaN values.

            % Compute logical or-ing.
            value = ~isempty(obj.AnnualElectricUsageTable) && ...
                ~isempty(obj.AnnualGasUsageTable) && ...
                ~isempty(obj.AnnualWaterUsageTable);

        end %function

        
        function value = get.UsageComparisonTable(obj)
            % Getter method for UsageComparisonTable.
            %   Returns the 5-column table that compares the HEA and Level2
            %   KeyResults. These properties are always defined, so this
            %   table will always yield a result; i.e., no need to caution
            %   against a bad access.

            % -- Compute Numeric Values
            % Extract HEA Results and Level 2 Results
            heaResults = obj.HEA.ResultsTable.Value;
            level2Results = obj.Level2.ResultsTable.Value;

            % Compute Absolute and Proportional Difference
            absoluteDelta = level2Results - heaResults;
            percentDelta = (absoluteDelta ./ heaResults) * 100;

            % -- Cast to Single-Decimal String
            % Use string formatter for single decimal place.
            formatSpec = '%0.2f';
            str_heaResults = num2str(heaResults,formatSpec);
            str_level2Results = num2str(level2Results,formatSpec);
            str_absoluteDelta = num2str(absoluteDelta,formatSpec);
            str_percentDelta = num2str(percentDelta,formatSpec);

            % Create Output Table
            value = table(obj.HEA.ResultsTable.Property,...
                str_heaResults,...
                str_level2Results,...
                str_absoluteDelta,...
                str_percentDelta,...
                'VariableNames',["Property",...
                "HEA","Level 2",...
                "Delta","% Delta"]);

        end %function


        function value = get.DisplayPackageSummaryTable(obj)
            % Getter for DisplayPackageSummaryTable.
            %   Returns the string-formatted version of the
            %   PackageSummaryTable to be used in UITables.

            % -- Check if PackageSummaryTableExists
            % If it isn't empty, assume it exists.
            summaryTableExists = ~isempty(obj.PackageSummaryTable);
            
            % Exit early if no table.
            if ~summaryTableExists
                % Return an empty table.
                value = table;
                return;
            end %endif

            % -- Create String Version of Package Summary Table
            % Convert numeric portion of table to string and reassign.
            numMatrix = obj.PackageSummaryTable{:,2:end};
            stringMatrix = compose("%0.2f",numMatrix);

            % Assign Strings back to Table
            strTable = obj.PackageSummaryTable;
            strTable = convertvars(strTable,@isnumeric,"string");
            strTable{:,2:end} = stringMatrix;

            % Return Output
            value = strTable;

        end %function (Getter)


        function value = get.DisplayECMSummaryTables(obj)
            % Getter for DisplayECMSummaryTables.
            %   Returns the string-formatted version of the
            %   ECMSummaryTables to be used in UITables.

            % -- Check if ECMSummaryTables Exist
            % If it isn't empty, assume it exists.
            summaryTableExists = ~isempty(obj.ECMSummaryTables);
            
            % Exit early if no table.
            if ~summaryTableExists
                % Return an empty cell.
                value = cell.empty(0,1);
                return;
            end %endif

            % -- Create String Version of ECM Summary Table
            % Preallocate Cell Array
            value = cell(obj.NumPackages,1);

            % Iteratively create string version of each ECM Table.
            for tableIdx = 1:obj.NumPackages
                % Extract ECM Table
                ecmTable = obj.ECMSummaryTables{tableIdx};

                % Convert numeric portion of table to string and reassign.
                numMatrix = ecmTable{:,4:end};
                stringMatrix = compose("%0.2f",numMatrix);

                % Assign Strings back to Table
                strTable = ecmTable;
                strTable = convertvars(strTable,@isnumeric,"string");
                strTable{:,4:end} = stringMatrix;

                % Store ECM
                value{tableIdx,1} = strTable;

            end %forloop

        end %function (Getter)

        function set.Location(obj,value)
            % Setter for Location property.
            %   Pipes the value set into the Location property of the Bldg
            %   to the same-named property in lower Level2 object stored in
            %   Building.

            % Set Building Value
            obj.Location = value;

            % Update Building's Level 2 Obj Location Property
            for bgIdx = 1:numel(obj.BelowGradeSurfaces)
                % Update Location Property by Reference
                obj.BelowGradeSurfaces(bgIdx).Location = ...
                    obj.Location;
                
            end %forloop

        end %function


    end %methods (public Internals)


    methods (Access = protected)

        function cpObj = copyElement(obj)
            % copyElement: Override method from matlab.mixin.Copyable to
            % create a deep copy of the Building.
            %   By default, the copy method makes a shallow copy of the
            %   Building. This creates a new Building object reference, but
            %   points to the same handle property references (aka, all of
            %   the object references.) 
            %   This is not the desired behavior - we want a deep copy,
            %   which will make an entirely new reference to all handle
            %   objects in the building (nested).

            % -- Create New Copy Building Reference
            % Call default copy method to create initial copied Building
            % object with shallow copies.
            cpObj = copyElement@matlab.mixin.Copyable(obj);

            % -- Deep Copy Handle Object Arrays
            % Location
            cpObj.Location = copy(obj.Location);

            % Building Level 2 Object Collection
            cpObj.Airmovers = copy(obj.Airmovers);
            cpObj.Pumps = copy(obj.Pumps);
            cpObj.OpaqueSurfaces = copy(obj.OpaqueSurfaces);
            cpObj.GlazedSurfaces = copy(obj.GlazedSurfaces);
            cpObj.BelowGradeSurfaces = copy(obj.BelowGradeSurfaces);
            cpObj.SlabOnGrade = copy(obj.SlabOnGrade);
            cpObj.Spaces = copy(obj.Spaces);
            cpObj.Appliances = copy(obj.Appliances);
            cpObj.PlumbingFixtures = copy(obj.PlumbingFixtures);
            cpObj.DHWsystems = copy(obj.DHWsystems);
            cpObj.DHWpipesMechRoom = copy(obj.DHWpipesMechRoom);
            cpObj.DHWtanks = copy(obj.DHWtanks);
            cpObj.HeatCool = copy(obj.HeatCool);

        end %function

    end %method (protected)

    methods (Access = public)
        % -- Declare Publically Accessible Methods
        % Method definitions will be fully realized in the correspondingly
        % named function script .m files in the Building class folder
        % @Building.

        % Calculate Water DHW
        calculateWaterDHW(obj);

        %match Solar Data with city info
        matchCityLocation(obj);

        %Method to calculate the degree days
        calculateDegreeDays(obj);

        % calculate monthly ventilation flows
        calculateMonthlyVentilation(obj)

        % Calculations for space heating loads and input
        calculateSpaceHeatingEnergy(obj)

        % Calculating Space cooling
        calculateSpaceCoolingEnergy(obj)

        % Claculate Energy Usage
        calculateEnergyUsage(obj)

        % Load Building
        bldg = loadData(obj,fileName)

        % MW_MISU: This needs to be fixed to have proper match to function.
        %runCalcs(obj)
        reportAppliances(obj)
        reportWater(obj)
        reportEnergy(obj)

        % calculateInfiltration
        [ACHnatHtg, ACHnatClg] = calculateInfiltration(obj);

        % Calculate and sum internal gains and electricity use
        calculateInternalGainsAndElec(obj);

        % Calculate solar gains through all glazed surfaces.
        % Calls PV Watts API to get solar radiation data for each
        % surface based on azimuth and tilt. For the location.
        calculateSolarGains(obj);

        % Heating internal gains and solar gains utilization factors
        [intGainsUtilHtg, solarGainsUtilHtg] = ...
            calculateHeatingUtilizationFactors(obj, heatLoss12, ...
            intGainsHtgSeason12, solarGainsHtgSeason12);

        % Cooling utilization factors for heat losses.
        [lossesUtilClg] = calculateCoolingUtilizationFactors(obj,...
            heatLoss12, totalHLC12, ...
            intGainsClgSeason12, solarGainsClgSeason12);

    end %methods (public)


    methods (Access = public)
        % -- Declare Publically Accessible Methods Here
        % Method definitions will be fully realized and defined in the
        % correspondingly named function script .m files in the class
        % folder @Building. Private methods are only callable within
        % objects of this same class.

        % importLevel2ObjectData: Method to import Level2 object data into
        % a Building.
        importLevel2ObjectData(bldg, level2DataFile)

        % calculateEnvelopeArea: Method to calculate the envelope area for
        % the building (six-sided shell).
        calculateEnvelopeArea(obj);

        % computeHEA: Method to compute HEA from Building properties.
        computeHEA(obj);

        % computeLevel2: Method to compute Level2 calculation from Building
        % properties.
        computeLevel2(obj);

    end %methods (private)

    methods (Access = private)
        % -- Declare Privately Accessible Methods Here
        % Method definitions will be fully realized and defined in the
        % correspondingly named function script .m files in the class
        % folder @Building. Private methods are only callable within
        % objects of this same class.

        % setNumericPropertiesFromArray: Method to populate numeric
        % building properties from an ordered array of numeric values.
        setNumericPropertiesFromArray(b,propArray);

        % setEfficiencyValuesFromArray: Method to populate efficiency and
        % utility-based building properties from an ordered array of
        % numeric values.
        setEfficiencyValuesFromArray(b,propArray);

        % setStringPropertiesFromArray: Method to populate string and enum
        % based building properties from an ordered array of strings.
        setStringPropertiesFromArray(b,propArray);

        % setDatetimeValuesFromArray: Method to populate datetime building
        % properties from an ordered array of datetime values.
        setDatetimePropertiesFromArray(b,propArray);

    end %methods (private)

    methods (Access = public)
        % -- Define Utility-Based Methods Here
        % createAnnualAndMonthlyGasUsageTable: Method to create the annual
        % gas usage table and MonthlyProfile from Gas utilities and
        % proportions.
        createAnnualAndMonthlyGasUsageTable(obj,...
            gasMeters,gasProportions,...
            numYearsToAvg);

        % createAnnualAndMonthlyElectricityUsageTable
        createAnnualAndMonthlyElectricityUsageTable(obj,...
            elecMeters,elecProportions,...
            numYearsToAvg);

        % createAnnualAndMonthlyOilyUsageTable
        createAnnualAndMonthlyOilUsageTable(obj,...
            oilMeters,oilProportions,...
            numYearsToAvg);

        % createAnnualAndMonthlyPropaneUsageTable
        createAnnualAndMonthlyPropaneUsageTable(obj,...
            propaneMeters,propaneProportions,...
            numYearsToAvg);

        %functions to report summaries
        reportSummary(obj)

        % createAnnualWaterUsageTable: Method to create the annual
        % Water usage table from Water utilities and proportions.
        createAnnualWaterUsageTable(obj,waterMeters,waterRatios);

        % createWaterMonthlyProfile: Method to create the average water
        % monthly profile.
        createWaterMonthlyProfile(obj,waterMeters,waterRatios);

        % Analyze gas usage
        analyzeGas(obj, gasMeters, gasRatios, ddTable, numYearsToAvg);

        % Analyze propane usage
        analyzePropane(obj, propaneMeters, propaneRatios, ddTable, numYearsToAvg);

        % Analyze oil usage
        analyzeOil(obj, oilMeters, oilRatios, ddTable, numYearsToAvg);

        % -- Level 2 Object Manipulation
        addLevel2Objects(obj,level2Objs);
        removeLevel2Objects(obj,level2ObjType,removeIdx);
        clearBuildingLevel2Objects(obj);
        

        % -- Package Management
        addPackages(obj,packages);
        removePackages(obj,packageIdxs);
        applyPackages(obj,applyMethod);

    end %methods (public

    methods (Access = public, Static)
        % -- Declare Publically Accessible Static Methods Here
        % Public static methods declared here are defined in the class
        % folder @Building under the .m method script of the same name.
        % Static methods are callable through the Building class without
        % needing an instance of the object to be called.

        % fromBuildingExcelFile: Method to generate a Building object from
        % a set of input data that defines properties of the Building.
        bldg = fromBuildingExcelFile(fileName);

        % readSourceData: Method 2 to generate a building object from a set
        % of input files.
        bldgs = readSourceData(fileName);

        % Getting the enthalpy values
        en2Setpt = calculateEnthalpyAirH20(clg2Setpt, targetRHsummer);

        %Modules to run ,load and report all modules and results
        bldg = runModules(fileName,config);

    end %methods (public, Static)

    methods (Access = public)
        % --- Plot Method Signatures
        % -- HEA Plots
        plotTotalGasUsage(obj,ax,showAccumulation);
        plotTotalElectricUsage(obj,ax,showAccumulation);
        plotTotalWaterUsage(obj,ax,showAccumulation);
        plotTotalOilUsage(obj,ax,showAccumulation);
        plotTotalPropaneUsage(obj,ax,showAccumulation);          
        plotTotalBaseloadUsage(obj,ax,showAccumulation);
        plotHeatingVHDD65(obj,ax);
        plotCoolingVCDD70(obj,ax);
        plotWaterNonResidential(obj,ax);
        plotGasComponentBreakdown(obj,ax);
        plotElectricComponentBreakdown(obj,ax);
        plotWaterComponentBreakdown(obj,ax);
        plotOilComponentBreakdown(obj,ax);
        plotPropaneComponentBreakdown(obj,ax);


        % -- Level 2 Plots
        % Comparison Plots
        plotActualVModeledMonthlyGasUsage(obj, ax);  
        plotActualVModeledMonthlyElectricUsage(obj, ax);  
        plotActualVModeledMonthlyWaterUsage(obj, ax);  
        plotActualVModeledMonthlyOilUsage(obj, ax);  
        plotActualVModeledMonthlyPropaneUsage(obj, ax);

        % Contribution Graphs
        plotModeledElectricComponentContributions(obj, ax);
        plotModeledGasComponentContributions(obj, ax);
        plotModeledBuildingHeatLoss(obj, ax);
        plotModeledInternalGainComponentContributions(obj, ax);


    end %methods (public Plot)

end %classdef (Building)