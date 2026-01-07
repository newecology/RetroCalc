classdef Site < handle
    % SITE Summary of this class goes here
    % Detailed explanation goes here

    properties (Access = public, AbortSet, SetObservable)
        % Name: Name of the Site.
        Name (1,1) string = "New Site";

        % Location: Physical location of site to tie weather data to.
        Location (:,1) ece.Location = ece.Location.empty(0,1);

        % NumPastYearsToAverage: Number of past years to use 
        % weather data from to average data across.
        NumPastYearsToAverage (1,1) double = 5;

        % CarbonEqValueElectricity_kgPerkWh: Carbon equivalent of
        % Electricity, in units of kg per kilowatt-hour.
        CarbonEqValueElectricity_kgPerkWh (1,1) double = .3692; % for MA kgCO2e/kWh

        % CarbonEqValueGas_kgPerTherm: Carbon equivalent of Gas, in units
        % of kg per therm.
        CarbonEqValueGas_kgPerTherm (1,1) double = 5.31;

        % CarbonEqValueOil_kgPerGallon: Carbon equivalent of Oil, in units
        % of kg per gallon.
        CarbonEqValueOil_kgPerGallon (1,1) double = 10.24;

        % CarbonEqValuePropane_kgPerGallon: Carbon equivalent of Propane, in units
        % of kg per gallon.
        CarbonEqValuePropane_kgPerGallon(1,1) double = 5.72;

        % HeatingShoulderMonths: Months where Heating use overlaps.
        HeatingShoulderMonths (:,1) double = double.empty(0,1);

        % CoolingShoulderMonths: Months where Cooling use overlaps.
        CoolingShoulderMonths (:,1) double = double.empty(0,1);

    end %properties


    properties (GetAccess = public, SetAccess = private, AbortSet, SetObservable)
        % -- Object Collections in Site
        % The listeners/events for the individual component properties 
        % are all handled in the individual properties' setters. The array
        % collection is folded into SetObservable so we can trigger an
        % event when the array size changes (i.e., an object is added or
        % removed from this set).

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
        
        % OilMeters: Array collection of oil utilities meter objects
        OilMeters (:,1) ece.Oil = ece.Oil.empty(0,1);
                
        % PropaneMeters: Array collection of propnae utilities meter objects
        PropaneMeters (:,1) ece.Propane = ece.Propane.empty(0,1);

        % HEA: Historical Energy Analysis KeyResults object.
        HEA (1,1) ece.KeyResults

    end %properties


    properties (Access = private, SetObservable)
        % DefinedBuildingGasRatios: User-set array of ratios of gas meters
        % to Building objects.
        UserDefinedBuildingGasRatios (:,:) double = double.empty(0,1);

        % DefinedBuildingWaterRatios: User-set array of ratios of water
        % meters to Building objects.
        UserDefinedBuildingWaterRatios (:,:) double = double.empty(0,1);

        % DefinedBuildingElecRatios: User-set array of ratios of 
        % electricity meters to Building objects.
        UserDefinedBuildingElecRatios (:,:) double = double.empty(0,1);

        % DefinedBuildingOilRatios: User-set array of ratios of oil meters
        % to Building objects.
        UserDefinedBuildingOilRatios (:,:) double = double.empty(0,1);

        % DefinedBuildingPropaneRatios: User-set array of ratios of propane
        % meters to Building objects.
        UserDefinedBuildingPropaneRatios (:,:) double = double.empty(0,1);

    end %properties

    properties (GetAccess = public, Dependent, Transient)
        % BuildingGasRatios: Array of ratios of gas meters to Building
        % objects.
        BuildingGasRatios (:,:) double
        
        % BuildingWaterRatios: Array of ratios of water meters to 
        % Building objects.
        BuildingWaterRatios (:,:) double
        
        % BuildingElecRatios: Array of ratios of elec meters to Building
        % objects.
        BuildingElecRatios (:,:) double

        % BuildingElecRatios: Array of ratios of oilmeters to Building
        % objects.
        BuildingOilRatios (:,:) double

        % BuildingElecRatios: Array of ratios of Propane meters to Building
        % objects.
        BuildingPropaneRatios (:,:) double

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

        % -- Unit Costs of utilities
        % UnitCostOfElectricity: Dollar per kWh cost of electric.
        UnitCostOfElectricity (1,1) double
        
        % UnitCostOfGas: Dollar per therm cost of gas.
        UnitCostOfGas (1,1) double
        
        % Unit Cost of Water: Dollar per gallon cost of water.
        UnitCostOfWater (1,1) double

        % Unit Cost of Oil; Dollars per gallon of oil
        UnitCostOfOil (1,1) double

        %Unit cost of Propnae : Dollar per therm cost of propane
        UnitCostOfPropane (1,1) double

    end %properties (Dependent)


    events
        % PropertyChanged: Event that notifies when a SetObservable 
        % property has changed within the Site object.
        PropertyChanged 

    end %events


    properties (Access = public, Transient, NonCopyable)
        % BuildingPropsChangedListeners
        BuildingPropsChangedListeners (:,1) event.listener = ...
            event.proplistener.empty(0,1);

        % ElectricUtilityPropsChangedListeners
        ElectricUtilityPropsChangedListeners (:,1) event.listener = ...
            event.listener.empty(0,1);

        % PropertyChangeListeners
        PropertyChangeListeners (:,1) event.proplistener = ...
            event.proplistener.empty(0,1);

    end %properties (private, Transient, NonCopyable)
    

    methods % Internal Methods (Constructors + Getters)
        
        function obj = Site()
            %SITE Construct an instance of the Site class.
            %   Site is a single object that collects Buildings, Meters,
            %   and other important properties of a specific area of land.
            %   This Site is evaluated in RetroCalc for energy conservation
            %   measures.

            % -- Create Location Instance
            % Instantiate default Location object.
            obj.Location = ece.Location();

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
                obj.WaterMeters;...
                obj.OilMeters;...
                obj.PropaneMeters];

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
                numel(obj.GasMeters) + ...
                numel(obj.OilMeters) + ...
                numel(obj.PropaneMeters);
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

            % Return user-provided or computed Ratio for utility.
            value = utilityRatioCalculator(obj,...
                obj.UserDefinedBuildingElecRatios,...
                obj.ElectricMeters);

        end %function

        function value = get.BuildingGasRatios(obj)
            % Getter for BuildingGasRatios
            %   Returns the ratios matrix for Gas meters supplying
            %   Buildings within Site. This is an output RxC matrix, where
            %   R = NumMeters, and C = NumBuildings.

            % Return user-provided or computed Ratio for utility.
            value = utilityRatioCalculator(obj,...
                obj.UserDefinedBuildingGasRatios,...
                obj.GasMeters);

        end %function

        function value = get.BuildingWaterRatios(obj)
            % Getter for BuildingWaterRatios
            %   Returns the ratios matrix for Water meters supplying
            %   Buildings within Site. This is an output RxC matrix, where
            %   R = NumMeters, and C = NumBuildings.

            % Return user-provided or computed Ratio for utility.
            value = utilityRatioCalculator(obj,...
                obj.UserDefinedBuildingWaterRatios,...
                obj.WaterMeters);

        end %function

        function value = get.BuildingOilRatios(obj)
            % Getter for BuildingOilRatios
            %   Returns the ratios matrix for Oil meters supplying
            %   Buildings within Site. This is an output RxC matrix, where
            %   R = NumMeters, and C = NumBuildings.

            % Return user-provided or computed Ratio for utility.
            value = utilityRatioCalculator(obj,...
                obj.UserDefinedBuildingOilRatios,...
                obj.OilMeters);

        end %function


        function value = get.BuildingPropaneRatios(obj)
            % Getter for BuildingPropaneRatios
            %   Returns the ratios matrix for Propane meters supplying
            %   Buildings within Site. This is an output RxC matrix, where
            %   R = NumMeters, and C = NumBuildings.

            % Return user-provided or computed Ratio for utility.
            value = utilityRatioCalculator(obj,...
                obj.UserDefinedBuildingPropaneRatios,...
                obj.PropaneMeters);

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
            value = sum([obj.Buildings.GrossArea_ft2]);

        end %function


        function value = get.UnitCostOfElectricity(obj)
            % Getter for UnitCostOfElectricity property.
            %   Returns the value of the computed Cost of Electricity.

            % Extract Total Cost and Total Units
            totalCost = obj.HEA.CostElectricity;
            totalUnits = obj.HEA.Electricity_kWh;

            % Calculate Unit Cost
            value = totalCost/totalUnits;

        end %function


        function value = get.UnitCostOfGas(obj)
            % Getter for UnitCostOfGas property.
            %   Returns the value of the computed Cost of Gas.

            % Extract Total Cost and Total Units
            totalCost = obj.HEA.CostGas;
            totalUnits = obj.HEA.Gas_therms;

            % Calculate Unit Cost
            value = totalCost/totalUnits;

        end %function


        function value = get.UnitCostOfWater(obj)
            % Getter for UnitCostOfWater property.
            %   Returns the value of the computed Cost of Water.

            % Extract Total Cost and Total Units
            totalCost = obj.HEA.CostWater;
            totalUnits = obj.HEA.Water_gallons;

            % Calculate Unit Cost
            value = totalCost/totalUnits;

        end %function


        function value = get.UnitCostOfOil(obj)
            % Getter for UnitCostOfOil property.
            %   Returns the value of the computed Cost of Oil

            % Extract Total Cost and Total Units
            totalCost = obj.HEA.CostOil;
            totalUnits = obj.HEA.Oil_gallons;

            % Calculate Unit Cost
            value = totalCost/totalUnits;

        end %function


        function value = get.UnitCostOfPropane(obj)
            % Getter for UnitCostOfPropane property.
            %   Returns the value of the computed Cost of Propane

            % Extract Total Cost and Total Units
            totalCost = obj.HEA.CostPropane;
            totalUnits = obj.HEA.Propane_gallons;

            % Calculate Unit Cost
            value = totalCost/totalUnits;

        end %function

    end %methods (Constructor + Getters)





    methods % Internal Methods

        function updateObjectArrayListeners(obj,listenerArray,objectArray)
            % updateObjectArrayListeners: Method to update the listener array
            % for corresponding object changes.
            %    To generalize the listener attachment, we can provide the
            %    listener array and the object array to this method. This
            %    will delete all existing listeners in the array and then
            %    repopulated it with new listeners attached to the object.
            %  NOTE: This assumes the property listener event name is fixed
            %  as "PropertyChanged".

            % Delete all current listeners.
            delete(listenerArray);
            listenerArray = event.proplistener.empty(0,1);

            % Get size of object array
            numObjects = length(objectArray);

            % Iteratively create and assign listeners.
            for objIdx = 1:numObjects
                % Create and append event listener to array.
                listenerArray(objIdx) = addlistener(...
                    objectArray(objIdx),...
                    "PropertyChanged",...
                    @(~,~) obj.onInternalPropertiesChanged());

            end %forloop

        end %function


        function onInternalPropertiesChanged(obj)
            % onInternalProperteisChanged: Callback method that fires
            % whenever there is a flow-up of Site properties changing,
            % including any properties of internal objects.

            % Display note for debug.
            %disp("Site internals changed! SitePropsChanged event firing.");

            % Notify SitePropsChanged Event
            notify(obj,"PropertyChanged");

        end %function

    end %methods (Internal)


    methods % Internal Methods (Setters)

        function set.Location(obj,value)
            % Setter for Location property.
            %   Pipes the value set into the Location property of the Site
            %   to the same-named property in Building object stored in
            %   Site.

            % Set Site Value
            obj.Location = value;

            % Update Building Location Property
            for bldgIdx = 1:obj.NumBuildings
                % Update Location Property by Copied Location
                obj.Buildings(bldgIdx).Location = copy(obj.Location);

            end %forloop

        end %function


        function set.BuildingElecRatios(obj,value)
            % Setter for BuildingElecRatio property.
            %   Set method for ratio allows either an empty input OR a
            %   matrix of size UxB, where U is the number of utilities and
            %   B is the number of buildings.

            % Obtain size of set value to ensure it is valid.
            valueSize = size(value);
            numMeters = length(obj.ElectricMeters);

            % Check if size of value matches expected matrix size or input
            % value is empty.
            validValue = ...
                isequal(valueSize,[numMeters,obj.NumBuildings]) || ...
                isempty(value);

            % Assign set value to UserRatio property.
            if validValue
                % Value can be assigned to ratio for meter.
                obj.UserDefinedBuildingElecRatios = value;
            else
                % Report error on setter
                msg = "ece.Site::setBuildingElecRatios:badValue\n" + ...
                    "Unable to set ratio matrix value.\n" + ...
                    "Value must be a matrix of size %d by %d " + ...
                    "(NumMeters by NumBuildings) or must be empty.";

                % Display error.
                error(msg,numMeters,obj.NumBuildings);

            end %endif

        end %function


        function set.BuildingGasRatios(obj,value)
            % Setter for BuildingGasRatio property.
            %   Set method for ratio allows either an empty input OR a
            %   matrix of size UxB, where U is the number of utilities and
            %   B is the number of buildings.

            % Obtain size of set value to ensure it is valid.
            valueSize = size(value);
            numMeters = length(obj.GasMeters);

            % Check if size of value matches expected matrix size or input
            % value is empty.
            validValue = ...
                isequal(valueSize,[numMeters,obj.NumBuildings]) || ...
                isempty(value);

            % Assign set value to UserRatio property.
            if validValue
                % Value can be assigned to ratio for meter.
                obj.UserDefinedBuildingGasRatios = value;
            else
                % Report error on setter
                msg = "ece.Site::setBuildingGasRatios:badValue\n" + ...
                    "Unable to set ratio matrix value.\n" + ...
                    "Value must be a matrix of size %d by %d " + ...
                    "(NumMeters by NumBuildings) or must be empty.";

                % Display error.
                error(msg,numMeters,obj.NumBuildings);

            end %endif

        end %function


        function set.BuildingWaterRatios(obj,value)
            % Setter for BuildingWaterRatio property.
            %   Set method for ratio allows either an empty input OR a
            %   matrix of size UxB, where U is the number of utilities and
            %   B is the number of buildings.

            % Obtain size of set value to ensure it is valid.
            valueSize = size(value);
            numMeters = length(obj.WaterMeters);

            % Check if size of value matches expected matrix size or input
            % value is empty.
            validValue = ...
                isequal(valueSize,[numMeters,obj.NumBuildings]) || ...
                isempty(value);

            % Assign set value to UserRatio property.
            if validValue
                % Value can be assigned to ratio for meter.
                obj.UserDefinedBuildingWaterRatios = value;
            else
                % Report error on setter
                msg = "ece.Site::setBuildingWaterRatios:badValue\n" + ...
                    "Unable to set ratio matrix value.\n" + ...
                    "Value must be a matrix of size %d by %d " + ...
                    "(NumMeters by NumBuildings) or must be empty.";

                % Display error.
                error(msg,numMeters,obj.NumBuildings);

            end %endif

        end %function
        

        function set.BuildingOilRatios(obj,value)
            % Setter for BuildingOilRatio property.
            %   Set method for ratio allows either an empty input OR a
            %   matrix of size UxB, where U is the number of utilities and
            %   B is the number of buildings.

            % Obtain size of set value to ensure it is valid.
            valueSize = size(value);
            numMeters = length(obj.OilMeters);

            % Check if size of value matches expected matrix size or input
            % value is empty.
            validValue = ...
                isequal(valueSize,[numMeters,obj.NumBuildings]) || ...
                isempty(value);

            % Assign set value to UserRatio property.
            if validValue
                % Value can be assigned to ratio for meter.
                obj.UserDefinedBuildingOilRatios = value;
            else
                % Report error on setter
                msg = "ece.Site::setBuildingOilRatios:badValue\n" + ...
                    "Unable to set ratio matrix value.\n" + ...
                    "Value must be a matrix of size %d by %d " + ...
                    "(NumMeters by NumBuildings) or must be empty.";

                % Display error.
                error(msg,numMeters,obj.NumBuildings);

            end %endif

        end %function


        function set.BuildingPropaneRatios(obj,value)
            % Setter for BuildingPropaneRatio property.
            %   Set method for ratio allows either an empty input OR a
            %   matrix of size UxB, where U is the number of utilities and
            %   B is the number of buildings.

            % Obtain size of set value to ensure it is valid.
            valueSize = size(value);
            numMeters = length(obj.PropaneMeters);

            % Check if size of value matches expected matrix size or input
            % value is empty.
            validValue = ...
                isequal(valueSize,[numMeters,obj.NumBuildings]) || ...
                isempty(value);

            % Assign set value to UserRatio property.
            if validValue
                % Value can be assigned to ratio for meter.
                obj.UserDefinedBuildingPropaneRatios = value;
            else
                % Report error on setter
                msg = "ece.Site::setBuildingPropaneRatios:badValue\n" + ...
                    "Unable to set ratio matrix value.\n" + ...
                    "Value must be a matrix of size %d by %d " + ...
                    "(NumMeters by NumBuildings) or must be empty.";

                % Display error.
                error(msg,numMeters,obj.NumBuildings);

            end %endif

        end %function


        function set.CarbonEqValueElectricity_kgPerkWh(obj,value)
            % Setter for CarbonValueElectricity conversion factor.
            %   Sets the assigned value to Site, and pipes the value to the
            %   equivalent property within Buildings contained in Site.

            % Set Site Value
            obj.CarbonEqValueElectricity_kgPerkWh = value;

            % Update Building Location Property
            for bldgIdx = 1:obj.NumBuildings
                % Update Factor Property
                obj.Buildings(bldgIdx).CarbonEqValueElectricity_kgPerkWh = ...
                    obj.CarbonEqValueElectricity_kgPerkWh;
            end %forloop

        end %function


        function set.CarbonEqValueGas_kgPerTherm(obj,value)
            % Setter for CarbonValueGas conversion factor.
            %   Sets the assigned value to Site, and pipes the value to the
            %   equivalent property within Buildings contained in Site.

            % Set Site Value
            obj.CarbonEqValueGas_kgPerTherm = value;

            % Update Building Location Property
            for bldgIdx = 1:obj.NumBuildings
                % Update Factor Property
                obj.Buildings(bldgIdx).CarbonEqValueGas_kgPerTherm = ...
                    obj.CarbonEqValueGas_kgPerTherm;
            end %forloop
        end %function 

        function set.CarbonEqValueOil_kgPerGallon(obj,value)
            % Setter for CarbonValueOil conversion factor.
            %   Sets the assigned value to Site, and pipes the value to the
            %   equivalent property within Buildings contained in Site.

            % Set Site Value
            obj.CarbonEqValueOil_kgPerGallon = value;

            % Update Building Location Property
            for bldgIdx = 1:obj.NumBuildings
                % Update Factor Property
                obj.Buildings(bldgIdx).CarbonEqValueOil_kgPerGallon = ...
                    obj.CarbonEqValueOil_kgPerGallon;
            end %forloop            

        end %function


        function set.CarbonEqValuePropane_kgPerGallon(obj,value)
            % Setter for CarbonValuePropane conversion factor.
            %   Sets the assigned value to Site, and pipes the value to the
            %   equivalent property within Buildings contained in Site.

            % Set Site Value
            obj.CarbonEqValuePropane_kgPerGallon = value;

            % Update Building Location Property
            for bldgIdx = 1:obj.NumBuildings
                % Update Factor Property
                obj.Buildings(bldgIdx).CarbonEqValuePropane_kgPerGallon = ...
                    obj.CarbonEqValuePropane_kgPerGallon;
            end %forloop            

        end %function


    end %methods (Setters)


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

        %importSiteInputsData: Method to import basic site data
        importSiteInputsData(obj,dataSource);

        % computeBuildingUtilityUsages: Method to process and compute each
        % utility in Site and within corresponding Building by proportion.
        computeBuildingUtilityUsages(obj);

        % addBuildings: Method to add
        % Building(s) to Site collection of
        % buildings.
        addBuildings(obj,bldgs);

        % removeBuildingsByIndex: Method to remove Building(s) from Site 
        % collection of buildings.
        removeBuildings(obj,bldgIdxs);

        % addUtilities: Method to add Utilities(s) to Site collection of
        % utilities.
        addUtilities(obj,utilities);

        % removeUtilitiesByIndex: Method to remove Utilities(s) from Site 
        % collection of utilities.
        removeUtilities(obj,utilityMeterType,utilityIdxs);

        % computeHEA: Method to compute HEA for Site and constituent
        % Buildings.
        computeHEA(obj);

        % computeLevel2: Method to compute Level2 calculation for Site and
        % constituent Buildings.
        computeLevel2(obj);

    end %methods


    methods (Static)
        % -- Static Method Signatures
        % fromInputFiles: Method to instantiate a Site from an input set of
        % Building and Meter objects.
        site = fromInputExcelFiles(fileOpts);

    end %methods

end %classdef




%% -- Helper Functions
% Functions defined to help out with recurring pieces of code within the
% Site Class.
function value = utilityRatioCalculator(obj,userRatio,meters)
%   Returns the ratios matrix for meters supplying Buildings within Site. 
%   This is an output RxC matrix, where R = NumMeters and C = NumBuildings.

% Return empty matrix if no Buildings or Utilities exist.
if ~obj.HasBuildings || ~obj.HasMeters
    % Return empty double object.
    value = double.empty(0,0);
    return;
end %endif

% Check if UserDefinedBuildingElecRatios are set and valid.
%   Valid ratios are non-empty and the correct size matrix
%   based on number of buildings and utility (UxC).
validUserRatio = ...
    ~isempty(userRatio) && ...
    isequal(size(userRatio),...
    [length(meters),length(obj.Buildings)]);

% Assign value to property based on valid User ratio set.
if validUserRatio
    % Set get value to UserDefinedRatios
    value = userRatio;

else
    % Compute get value based on Building areas if no user
    % defined ratio is supplied or valid.

    % Create default utility distribution by building area.
    bldgAreas = [obj.Buildings.GrossArea_ft2];
    defaultDistribution = bldgAreas ./ sum(bldgAreas);

    % Replicate array for every utilty this applies to.
    value = repmat(defaultDistribution,...
        numel(meters),1);

end %endif

end %function