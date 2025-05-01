classdef Electricity < ece.Utility
    %ELECTRICITY Derived class containing information about an Electricity
    %utility object.
    %   The Electricity utility references the Utility Interface to inherit
    %   common utility methods and define its own implementation of other
    %   methods.
    % Note: All abstract methods declared in the Utility superclass must be
    % implemented within the Electricity class.

    properties (Access = public, AbortSet, SetObservable)
        % -- Declare Publically Accessible Properties
        % IsBaseLoad: Flag for signaling if this is Base electrical load.
        IsBaseLoad (1,1) logical

        % IsSpaceHeat: Flag if the electricy is also used for space heating.
        IsSpaceHeat (1,1) logical

        % IsCooling: Flag if the electricy is used for cooling.
        IsCooling (1,1) logical

        % IsDHW: Flag if the electricy is used for DHW.
        IsDHW (1,1) logical

        % ElecBaseAdj: Baseload adjustment electric heating & cooling.
        ElecBaseAdj (1,1) double

        % BaseElecAmplitude: Base electric amplitude value.
        BaseElecAmplitude (1,1) double

        % SeasonalAmpDHWUse: Seasonal amplitude of elec use for DHW meters.
        SeasonalAmpDHWUse (1,1) double

        % HeatFractionLimits: Table of the fractional heating proportions
        % for each month.
        HeatFractionLimitsTable (:,3) table = table.empty(0,3);

        % AccountNumber: Account Number/ID for each meter in load order.
        AccountNumber (1,1) double

    end %properties (Public)

    properties (GetAccess = public, SetAccess = private)


    end %properties (Public Get, Private Set)


    properties (Dependent)
        % NumMonthsOfData: Number of months of data imported.
        NumMonthsOfData (1,1) double

    end %properties (Dependent)

    methods
        % -- Internals-related Class Methods

        % Define Constructor Method
        function obj = Electricity()
            %ELECTRICITY Construct an instance of the Electricity class.
            %   The default Electricity constructor takes no arguments and
            %   returns a default instance of the Electricity object. A Electricity
            %   object with loaded values can be instanced with
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
            %   tracked in the imported UsageTable, which corresponds to
            %   the number of rows.

            % Return height of RawUsageTable.
            value = height(obj.RawUsageTable);

        end %function (Getter for NumMonthsOfData)

    end %methods (public, internal)

    methods (Access = public)
        % createUsagePlot: Function to plot the UsageTable data by year.
        createUsagePlot(obj);

        % minElecMoYr: Function to get the minimum adjusted electric year 
        % usage.
        [minElecMoYr1, minElecMoYr2,minElecMoYr3,minElecMoAvg] = ...
            minElecMoYr(obj);

        % elecAnalysis: Function to do most of the calculation and 
        % analysis from the data.
        elecAnalysis(obj);

        % elecResults: Function to organize the calculated results
        elecResults(obj);

        % plotResults: Method to plot the data imported from source files.
        plotResults(obj);


    end %methods (public)


    methods (Access = public)
        % updateAdjustedUsageTable: Method to update columns in the
        % AdjustedUsageTable to incorporate and relevant inputs from the
        % container structure (Site/Building) that has the utility in
        % question.
        updateAdjustedUsageTable(obj,ddTbl);      

    end %methods (public)


    methods (Access = public, Static)
        % fromUtilityExcelFile: Method to generate Electricity objects from
        % an input Excel file containing the Electricity utility
        % information.
        e = fromUtilityExcelFile(utilFilePath);

    end %methods (Static)

    methods (Access = protected)
        % setFlagPropertiesFromArray: Method to set the flagged properties
        % and basic properties from an array of values.
        setFlagPropertiesFromArray(obj, propArray);

        % importUsageTable: Method to import data into UsageTable property,
        % validating and curating it for use within the elec utility.
        importUsageTable(obj, useTbl);

        % correctBilling: Method to correct uneven billing periods within
        % the UsageTable that would skew the analysis.
        correctBilling(obj);

    end %methods (private)

end %classdef

