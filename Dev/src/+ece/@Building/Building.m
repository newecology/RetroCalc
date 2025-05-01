classdef Building < handle
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
        % -- Define Public Properties

        % Name: Building name. Can be the actual building name or just a
        % string identifier for the building.
        Name (1,1) string

        % Location city used to access weather and solar data
        % Location: Array containing  [latitude. longitude]. Default is for
        % Boston Logan.
        LocationCity(1,1) string

        % Location State for verifying City
        LocationState(1,1) string

        % Location array containing  [latitude longitude].
        LocationLatLong (1,2) double %= [42.3656, -71.0096]

        %building areas (gross area, gross conditioned area, interior
        %conditioned area)
        BldgArea_ft2 (1,3) double

        % Area_ft2: Building area in square feet.
        Area_ft2 (1,1) double

        % percent of conditioned area that is cooled, 0 to 100
        BldgPercentCondAreaCooled (1,1) double

        % number of units
        BldgNumberOfUnits (1,1) double

        % Number of units / bedrooms (number of 1 bedroom units,
        % 2 bedrm units, 3 bedrm units, 4 bedrm units)
        BldgNumberOfBedrooms (1,4) double = [0, 0, 0, 0]

        % BldgNumberOfOccupants: Number of building occupants.
        BldgNumberOfOccupants (1,1) double

        % BldgPopulationType: Type of population residing in building.
        BldgPopulationType (1,1) ece.enum.PopulationType = "Mixed"

        % BldgNumberOfStories: Number of stories (floors) of building.
        BldgNumberOfStories (1,1) double {mustBeInteger}

        % YearOfConstruction: Year building was constructed.
        BldgYearOfConstruction (1,1) double {mustBeInteger}

        % ThermalMass: Thermal mass type of building.
        ThermalMass  (1,1) ece.enum.ThermalMassType = "Light"

        % IntVolume_ft3: Interior building volume in cubic feet.
        IntVolume_ft3 (1,1) double

        % AirLeakageRate_cfm50perFt2: Air leakage rate for building.
        AirLeakageRate_cfm50perFt2 (1,1) double

        % SheildingClass: Class of sheilding of Building. Must be a value
        % between one and 5.
        ShieldingClass (1,1) double  % add mustBeMember 1 to 5

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

        % For cases where electricity provides both heating and cooling
        %BaseloadAdjustmentForElectricHeatingCooling (1,1) double

        %BaseloadElectricityAmplitude (1,1) double

    end %properties (public)

    properties (SetAccess = private, GetAccess = public)
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

        % HEA: Historical Energy Analysis object.
        HEA (1,1) ece.HEA

    end %properties

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



    properties (Access = public)
        % Special case for this output table
        % This needs to be public because it is built in 2 stages.

        % Table containing component and total monthly electric usage
        ElectricUsageTable (:,:) table

    end


    properties (SetAccess = private, GetAccess = public)
        % -- Define Read-Only Properties

        %array for use in space heating / cooling calcs
        %24 columns for time 1 and time 2 in each month
        % 3 rows for HDD, CDD, enthalpy days as well as 3 more rows for avg temp,
        % avg enthalpy, and average wind speed
        weatherMonthly (6,24) double

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

        % heating ventilation flow 24 columns for day/night for each month
        % two rows for balanced, unbalanced
        HtngVentilationFlow (2,24) double

        %cooling ventilation flow 24 columns for day/night for each month
        %two rows for balanced, unbalanced
        ClngVentilationFlow (2,24) double

        % table to show energy use results for all appliances combined to the user
        ApplianceResultsTable (:,:) table

        % appliance results array for all appliances combined for use in calculations
        ApplianceEnergyTable12 (:, :) table

        % Electric usage and internal gains table
        InternalGainsTable (:,:) table
        %ElectricUsageTable (:,:) table

        % Array of size 3x24. 1st row: Heating sensible gains 2nd row:
        % Total cooling sensible and latent 3rd row: Latent heat gains
        InternalGainsArray_kBtu double

        % Energy usage for space heating in kBtu and in units for each
        % energy source (electricity, gas, oil, propane).
        SpaceHeatingTable_kBtu table
        HeatFuelTable table

        % Same for space cooling.
        SpaceCoolingTable_kBtu table
        SpaceCoolingTable_kWh table

        % Table with the total energy used in the building (electricity,
        % gas, oil, propane). More energy types could be added.
        BuildingEnergyUsageTable (:, :) table

    end %properties (Read-Only)


    properties (Hidden)
        % These properties don't need to be displayed at all times, but
        % are accessible if the user needs to view them.

        %weather table containing the tmy3 weather data
        WeatherDataTable table

        % For future use, measured data from the site
        SiteMeasurements (:,:) table

        % total building envelope area (sum of glazing, opaque, below grade
        % and slab on grade areas)
        BuildingEnvelopeArea (1,1) double

        % Total solar gain that enters the building for each month, kBtu.
        totalSolarGains

    end % hidden properties

    properties (Access = private)
        % -- Define Private Properties

    end % properties (Private)

    properties (Access = private, Constant)
        % - Define Internal Constant Properties
        % Constant properties are intended to unchanged over the lifetime
        % of the object. Internal ones are set to provide contextual
        % information needed for the object.

    end % properties (Constant, internal)

    methods (Access = public)
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

            % Initialize Annual Tables / MonthlyProfiles
            %   New buildings need to have their tables automatically
            %   instantiated with default values and correct column
            %   names to ensure they can be safely incorporated
            %obj.setupDefaultTables();

        end %function (constructor)

    end %methods (public Internals)


    methods (Access = public)
        % -- Declare Publically Accessible Methods
        % Method definitions will be fully realized in the correspondingly
        % named function script .m files in the Building class folder
        % @Building.

        %calculateWaterDHW(obj);

        %match Solar Data with city info
        matchCityLocation(obj);

        %Method to calculate the degree days
        calcDegreeDays(obj);

        % calculate monthly ventilation flows
        calcMonthlyVentilation(obj)

        % Calculations for space heating loads and input
        calcSpaceHeatingEnergy(obj)

        % Calculating Space cooling
        calcSpaceCoolingEnergy(obj)

        % Claculate Energy Usage
        calcEnergyUsage(obj)

        % Load Building
        bldg = loadData(obj,fileName)

        runCalc(obj)
        reportAppliances(obj)
        reportWater(obj)
        reportEnergy(obj)

        %method to calculate the infiltration in the building
        [ACHnatHtg, ACHnatClg] = calcInfiltration(obj);

        % Calculate and sum internal gains and electricity use
        calcInternalGainsAndElec(obj);

        % Calculate solar gains through all glazed surfaces.
        % Calls PV Watts API to get solar radiation data for each
        % surface based on azimuth and tilt. For the location.
        calcSolarGains(obj);

        % Heating internal gains and solar gains utilization factors
        [intGainsUtilHtg, solarGainsUtilHtg] = calcHtgUtilFactors(obj, heatLoss12, ...
            intGainsHtgSeason12, solarGainsHtgSeason12);

        % Cooling utilization factors for heat losses.
        [lossesUtilClg] = calcClngUtilFactors(obj, heatLoss12, totalHLC12, ...
            intGainsClgSeason12, solarGainsClgSeason12);

    end %methods (public)


    methods (Access = public)
        % -- Declare Publically Accessible Methods Here
        % Method definitions will be fully realized and defined in the
        % correspondingly named function script .m files in the class
        % folder @Building. Private methods are only callable within
        % objects of this same class.

        % calculateEnvelopeArea: Method to calculate the envelope area for
        % the building (six-sided shell).
        calculateEnvelopeArea(obj);

        % computeHEA: Method to compute HEA from Building properties.
        computeHEA(obj);

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
        createAnnualAndMonthlyGasUsageTable(obj,ddTable,...
            gasMeters,gasProportions,...
            numYearsToAvg);

        % createAnnualElectricityUsageTable: Method to create the annual
        % Elec usage table from Elec utilities and proportions.
        createAnnualElectricityUsageTable(obj,elecMeters,elecRatios);

        % createElectricityMonthlyProfile: Method to create the average
        % electricity monthly profile.
        createElectricityMonthlyProfile(obj,ddTable,elecMeters,elecRatios,...
            numYearsToAvg);

        %functions to report summaries
        reportSummary(obj)

        % createAnnualWaterUsageTable: Method to create the annual
        % Water usage table from Water utilities and proportions.
        createAnnualWaterUsageTable(obj,waterMeters,waterRatios);

        % createWaterMonthlyProfile: Method to create the average water
        % monthly profile.
        createWaterMonthlyProfile(obj,waterMeters,waterRatios);

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

        bldgTbl = ReadSourceData(fileName);

        % Getting the enthalpy values
        en2Setpt = calcEnthalpyAirH20(clg2Setpt, targetRHsummer);

        %Modules to run ,load and report all modules and results
        bldg = runModules(fileName,config);

    end %methods (public, Static)

end %classdef (Building)