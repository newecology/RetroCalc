classdef Water < ece.Utility
    %WATER Derived class containing information about a Water utility
    %object.
    %   The Water utility references the Utility Interface to inherit
    %   common utility methods and define its own implementation of other
    %   methods.
    % Note: All abstract methods declared in the Utility superclass must be
    % implemented within the Water class.

    properties (Access = public, AbortSet, SetObservable)
        % -- Declare Publically Accessible Properties
        % IsResidential: Flag if the water is used for residential
        % purposes.
        IsResidential (1,1) logical

        % IsBaseLoad: Flag for signaling if this is Base water amt.
        IsBaseLoad (1,1) logical

        % IsIrrigation: Flag if the water is also used for space heating.
        IsIrrigation (1,1) logical

        % IsCoolingTower: Flag if the water is used for cooling.
        IsCoolingTower (1,1) logical

        % IsOther: Flag if the water is used for other purposes.
        IsOther (1,1) logical

        % IrrigationGal: Integer value indicating number of gallons used 
        % for irrigation.
        IrrigationGal (1,1) double {mustBeInteger}

        % CoolingTowerGal: Integer value indicating number of gallons used 
        % for cooling tower.
        CoolingTowerGal (1,1) double {mustBeInteger}

        % OtherGal: Amount of other gallons used.
        OtherGal (1,1) double

        % SummerWaterDist: Monthly % distribution for irrigation and 
        % cooling tower water.
        SummerWaterDist (1,12) double = ...
            [0 0 0 0 .03 .14 .3 .3 .2 .03 0 0];

        % AccountNumber: Account Number/ID for each meter in load order.
        AccountNumber (1,1) double

    end %properties (Public)

    properties (Dependent)
        % NumMonthsOfData: Number of months of utility data imported.
        NumMonthsOfData (1,1) double

    end %properties (Dependent)

    methods
        % -- Internals-related Class Methods
        % Define Constructor Method
        function obj = Water()
            %WATER Construct an instance of the Water class.
            %   The default Water constructor takes no arguments and
            %   returns a default instance of the Water object. A
            %   Water object with loaded values can be instanced with
            %   the fromSourceData static method.
            %   This object construction style is useful when testing
            %   objects that are intended to be populated from externa
            %   data, as it decouples the object's existence from the
            %   intended supplemental data.
        end %function (Constructor)


        %Calculates the number of months in the utility data
        function value = get.NumMonthsOfData(obj)
            % Getter for NumMonthsOfData.
            %   Value for this property reflects the number of months
            %   tracked in the imported RawUsageTable, which corresponds to
            %   the number of rows.

            % Return height of RawUsageTable.
            value = height(obj.RawUsageTable);

        end %function (Getter for NumMonthsOfData)

    end %methods (public, Internal)


    methods(Access=public)

        % createUsagePlot: Function to plot the water bill data by year.
        createUsagePlot(obj);
        
        % minWaterMoYr: Function to get the minimum adjusted water year 
        % usage.
        [minElecMoYr1, minElecMoYr2,minElecMoYr3,minElecMoAvg] = ...
            minGasMoYr(obj);
        
        % waterAnalysis: Function to do most of the calculation and 
        % analysis from the data.
        gasStoveDryerTotalAnnlTherms = waterAnalysis(obj);
        
        % waterResults: Function to organize the calculated results.
        [a,b] = waterResults(obj);

        % plotResults: Method to plot the data imported from source files.
        plotResults(obj);

    end %methods (public)

    methods (Access = public)
        % updateAdjustedUsageTable: Method to update columns in the
        % AdjustedUsageTable to incorporate and relevant inputs from the
        % container structure (Site/Building) that has the utility in
        % question.
        updateAdjustedUsageTable(obj);      

    end %methods (public)

    methods (Access = public, Static)
        % fromUtilityExcelFile: Method to generate Water objects from
        % an input Excel file containing the Water utility
        % information.
        e = fromUtilityExcelFile(utilFilePath);

    end %methods (Static)

    methods (Access = protected)
        % setFlagPropertiesFromArray: Method to set the flagged properties
        % and basic properties from an array of values.
        setFlagPropertiesFromArray(obj, propArray);

        % importUsageTable: Method to import data into UsageTable property,
        % validating and curating it for use within the water utility.
        importUsageTable(obj, useTbl);

        % correctBilling: Method to correct uneven billing periods within
        % the UsageTable that would skew the analysis.
        correctBilling(obj);

        % expandUsageTable: Method to analyze utility and expand the
        % imported UsageTable with more columns of data.
        expandUsageTable(obj);

    end %methods (private)


end %classdef