classdef Gas < ece.Utility
    %GAS Derived class containing information about an Gas
    %utility object.
    %   The Gas utility references the Utility Interface to inherit
    %   common utility methods and define its own implementation of other
    %   methods.
    % Note: All abstract methods declared in the Utility superclass must be
    % implemented within the Gas class.

    properties (Access = public, AbortSet, SetObservable)
        % -- Declare Publically Accessible Properties
        % IsSpaceHeat: Flag to indicate if gas is used for space heating.
        IsSpaceHeat (1,1) logical

        % IsDHW: Flag to indicate if gas is used for domestic hot water (DHW).
        IsDHW (1,1) logical

        % IsCooking: Flag if Gas is used for cooking in units.
        IsCooking (1,1) logical

        % IsClothesDryer: Flag to indicate if gas used for clothes drying.
        IsClothesDryer (1,1) logical

        % SeasonalAmpDHWUse: Seasonal amplitude of elec use for DHW meters.
        SeasonalAmpDHWUse (1,1) double       
        
        % AccountNumber: Account Number/ID for each meter in load order.
        AccountNumber (1,1) double

    end %properties

    properties (Dependent)
        % NumMonthsOfData: Number of months of data imported.
        NumMonthsOfData (1,1) double

    end %properties (Dependent)

    methods
        % -- Internals-related Class Methods

        % Define Constructor Method
        function obj = Gas()
            %GAS Construct an instance of the Gas class.
            %   The default Gas constructor takes no arguments and
            %   returns a default instance of the Gas object. A Gas
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
            %   tracked in the imported RawUsageTable, which corresponds to
            %   the number of rows.

            % Return height of RawUsageTable.
            value = height(obj.RawUsageTable);

        end %function (Getter for NumMonthsOfData)

    end %methods (pubic, internal)

    % -- Declare Public Methods
    methods(Access=public)

        % createUsagePlot: Function to plot the UsageTable data by year.
        createUsagePlot(obj);

        % minGasMoYr: Function to get the minimum adjusted gas year usage.
        [minGasMoYr1, minGasMoYr2,minGasMoYr3,minGasMoAvg] = ...
            minGasMoYr(obj);

        % gasAnalysis: Function to do most of the calculation and analysis
        % from the data.
        gasStoveDryerTotalAnnlTherms = gasAnalysis(obj);
        
        % gasResults: Function to organize the calculated results.
        [UsageAnnualTable,gasMoProfile,ThermCost]=gasResults(obj);

        % plotResults: Method to plot the data imported from the source
        % files.
        plotResults(obj)

    end %methods (public)


    methods (Access = public)
        % updateAdjustedUsageTable: Method to update columns in the
        % AdjustedUsageTable to incorporate and relevant inputs from the
        % containter structure (Site/Building) that has the utility in
        % question.
        updateAdjustedUsageTable(obj,ddTbl);      

    end %methods (public)


    methods(Access=public,Static)
        % fromUtilityExcelFile: Method to generate Gas objects from
        % an input Excel file containing the Gas utility
        % information.
        g = fromUtilityExcelFile(utilFilePath);

    end %methods (Static)

    methods (Access = protected)
        % setFlagPropertiesFromArray: Method to set the flagged properties
        % and basic properties from an array of values.
        setFlagPropertiesFromArray(obj, propArray);

        % importUsageTable: Method to import data into UsageTable property,
        % validating and curating it for use within the gas utility.
        importUsageTable(obj, useTbl);

        % correctBilling: Method to correct uneven billing periods within
        % the UsageTable that would skew the analysis.
        correctBilling(obj);

    end %methods (private)

end %classdef