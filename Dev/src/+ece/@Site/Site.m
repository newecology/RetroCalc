classdef Site < handle
    % SITE Summary of this class goes here
    % Detailed explanation goes here
    
    properties (Access = public, AbortSet, SetObservable)
        % Buildings: Array collection of building objects that are
        % contained in site.
        Buildings (:,1) ece.Building = ece.Building.empty(0,1);

        % GasMeters: Array collection of Gas utility meter objects.
        GasMeters (:,1) ece.Gas = ece.Gas.empty(0,1);

        % ElectricMeters: Array collection of Electricity utility meter
        % objects.
        ElectricMeters (:,1) ece.Electricity = ece.Electricity.empty(0,1);

        % WaterMeters: Array collection of Water Utility meter objects.
        WaterMeters (:,1) ece.Water = ece.Water.empty(0,1);

        % Location: Physical location of site to tie weather data to.
        Location (1,1) string = "";

        % NumPastYearsToAverageIntoYear: Number of past years to use 
        % weather data from to average into a single year.
        NumPastYearsToAverageIntoYear (1,1) double = 5;

        % CarbonEqValueElectricity_kgPerkWh: Carbon equivalent of
        % Electricity, in units of kg per kilowatt-hour.
        CarbonEqValueElectricity_kgPerkWh (1,1) double = 0;

        % CarbonEqValueGas_kgPerTherm: Carbon equivalent of Gas, in units
        % of kg per therm.
        CarbonEqValueGas_kgPerTherm (1,1) double = 0;

        % HeatingShoulderMonths: Months where Heating use overlaps.
        HeatingShoulderMonths (:,1) double = double.empty(0,1);

        % CoolingShoulderMonths: Months where Cooling use overlaps.
        CoolingShoulderMonths (:,1) double = double.empty(0,1);

    end %properties

    properties (Constant)

        % Unit cost of utilities
        CostOfElectricity (1,1) double  = .25    % $/kWh
        CostOfGas (1,1) double = 1.5      % $/therm
        CostOfOil (1,1) double = 3.5      % $/gallon
        CostOfPropane (1,1) double = 3.2     % $/gallon
        CostOfWater (1,1) double = .03    % $/gallon

    end %properties

    properties (GetAccess = public, SetAccess = private)
        % HistoricalDDTable: Historical degree day table.
        HistoricalDDTable table

        % HEA: Historical Energy Analysis
        HEA (1,1) ece.HEA

    end %properties (Private set, public get)

    properties (Access = private)
        % UserDefinedUtilityRatios


    end %properties (private)

    properties (GetAccess = public, Dependent)
        % BuildingGasRatios: Array of ratios of gas meters to Building
        % objects.
        BuildingGasRatios (:,:) double
        
        % BuildingWaterRatios: Array of ratios of water meters to 
        % Building objects.
        BuildingWaterRatios (:,:) double
        
        % BuildingElecRatios: Array of ratios of elec meters to Building
        % objects.
        BuildingElecRatios (:,:) double

        % NumBuildings: Count of Buildings in Site.
        NumBuildings (1,1) double

        % NumMeters: Count of Meters in Site.
        NumMeters (1,1) double

        % HasBuildings: Flag to indicate if Site has buildings.
        HasBuildings (1,1) logical

        % HasMeters: Flag to indicate if Site has Utilities meters.
        HasMeters (1,1) logical

        % UtilityMeters: Array of all Meters that feed into the Site and
        % are proportionally split to buildings.
        UtilityMeters (:,1) ece.Utility

        % Area: Area of site (in sq ft) given by the sum of all the
        % included Building's area.
        Area (1,1) double


    end %properties (Dependent)

    properties (GetAccess = public, SetAccess = private)

    end %properties (Read-Only)
    
    methods % Internal Methods
        
        function obj = Site()
            %SITE Construct an instance of this class.
            %   Detailed explanation goes here.
        end %function (Constructor)

        function value = get.UtilityMeters(obj)
            % Getter for UtilityMeters.
            %   The UtilityMeters property is an array of all the meters
            %   within a site. This array is heterogenous and is the
            %   rolled-up collection of all Gas, Water, Elec, etc. utility
            %   meter concrete classes in Site.

            % Append all utility-meter-type objects together. For sake of
            % clarity, we will do this in alphabetical order.
            value = [...
                obj.ElectricMeters;...
                obj.GasMeters;...
                obj.WaterMeters];

        end %function (getter for UtilityMeters array)

        function value = get.NumBuildings(obj)
            % Getter for NumBuildings.
            %   Returns count of Buildings array in Site.
            value = numel(obj.Buildings);
        end %function (getter for NumBuildings)

        function value = get.NumMeters(obj)
            % Getter for NumMeters.
            %   Returns count of meters arrays in Site.
            % Sum up the number of elements in all utility meter arrays.
            value = numel(obj.WaterMeters) + ...
                numel(obj.ElectricMeters) + ...
                numel(obj.GasMeters);
        end %function (getter for NumMeters)

        function value = get.HasBuildings(obj)
            % Getter for HasBuildings.
            %   Returns flag to show existence of Buildings in Site.
            value = ~isempty(obj.Buildings);
        end %function (getter for HasBuildings)

        function value = get.HasMeters(obj)
            % Getter for HasMeters.
            %   Returns flag to show existence of Meters in Site.
            value = obj.NumMeters ~= 0;
        end %function (getter for NumMeters)

        function value = get.BuildingElecRatios(obj)
            % Getter for BuildingElecRatios
            %   Returns the ratios matrix for Elec meters supplying
            %   Buildings within Site. This is an output RxC matrix, where
            %   R = NumMeters, and C = NumBuildings.

            % Return empty matrix if no Buildings or Utilities exist.
            if ~obj.HasBuildings || ~obj.HasMeters
                % Return empty double object.
                value = double.empty(0,0);
                return;
            end %endif

            % Create default utility distribution by building area.
            bldgAreas = [obj.Buildings.Area_ft2];
            defaultDistribution = bldgAreas ./ sum(bldgAreas);

            % Replicate array for every utilty this applies to.
            value = repmat(defaultDistribution,...
                numel(obj.ElectricMeters),1);

        end %function

        function value = get.BuildingGasRatios(obj)
            % Getter for BuildingGasRatios
            %   Returns the ratios matrix for Gas meters supplying
            %   Buildings within Site. This is an output RxC matrix, where
            %   R = NumMeters, and C = NumBuildings.

            % Return empty matrix if no Buildings or Utilities exist.
            if ~obj.HasBuildings || ~obj.HasMeters
                % Return empty double object.
                value = double.empty(0,0);
                return;
            end %endif

            % Create default utility distribution by building area.
            bldgAreas = [obj.Buildings.Area_ft2];
            defaultDistribution = bldgAreas ./ sum(bldgAreas);

            % Replicate array for every utilty this applies to.
            value = repmat(defaultDistribution,...
                numel(obj.GasMeters),1);

        end %function

        function value = get.BuildingWaterRatios(obj)
            % Getter for BuildingWaterRatios
            %   Returns the ratios matrix for Water meters supplying
            %   Buildings within Site. This is an output RxC matrix, where
            %   R = NumMeters, and C = NumBuildings.

            % Return empty matrix if no Buildings or Utilities exist.
            if ~obj.HasBuildings || ~obj.HasMeters
                % Return empty double object.
                value = double.empty(0,0);
                return;
            end %endif

            % Create default utility distribution by building area.
            bldgAreas = [obj.Buildings.Area_ft2];
            defaultDistribution = bldgAreas ./ sum(bldgAreas);

            % Replicate array for every utilty this applies to.
            value = repmat(defaultDistribution,...
                numel(obj.WaterMeters),1);

        end %function


        function value = get.Area(obj)
            % Getter for Area property.
            %   Returns the sum of the areas of all contained buildings. If
            %   no buildings exists, returns zero.

            % Check for no buildings
            if (obj.NumBuildings == 0)
                % No Area
                value = 0;
                return;
            end %endif

            % Otherwise, simply sum up each Building's area.
            value = sum([obj.Buildings.Area_ft2]);

        end %function


    end %methods


    methods (Access = public)
        % importUtilities: Method to import Utilities from data source into
        % Site properties.
        importUtilities(obj, dataSource);

        % importBuildings: Method to import Buildings from data source into
        % site properties.
        importBuildings(obj, dataSource);

        % importHistoricalDegreeDays: Method to import Historical Degree 
        % Days table into site properties.
        importHistoricalDegreeDays(obj, dataSource);

        % computeBuildingUtilityUsages: Method to process and compute each
        % utility in Site and within corresponding Building by proportion.
        computeBuildingUtilityUsages(obj);


    end %methods


    methods (Static)
        % -- Static Method Signatures
        % fromInputFiles: Method to instantiate a Site from an input set of
        % Building and Meter objects.
        site = fromInputExcelFiles(fileOpts);

    end %methods

end %classdef

