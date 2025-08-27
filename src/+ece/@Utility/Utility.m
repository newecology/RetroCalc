classdef  Utility < handle & matlab.mixin.Heterogeneous
    %UTILITY Top-level base class for defining utility objects.
    %   This Utility object class is an abstracy interface class that serves
    %   as a blueprint for all derived utilities of a specific type such as
    %   Electricity, Gas, Water, etc. and contains the properties and
    %   methods that must be defined within the subclasses.
    % Note: The utility class cannot be instantiated. A derived subclass
    %       must inherit from it for usage.
    
    properties (Access = public, AbortSet, SetObservable)
        % -- Define Protected Properties
        % Protected properties can only be get/set from the defining class
        % or its subclasses.

        % Utility Name: String name of the utility in question.
        Name (1,1) string = "Default Utility";

        % Number of Years: Number of years of data captured by UsageTable.
        NumberOfYears (1,1) double

        % UtilityPayerType: Property that exposes the party responsible for
        % paying the utility cost by using UtilityPayerType enum.
        UtilityPayerType (1,1) ece.enum.UtilityPayerType

        % UtilityService: Determines what part of a building this meter
        % serves to.
        UtilityServiceType (1,1) ece.enum.UtilityServiceType

        % IsResidential: Type of real estate the utility corresponds to,
        % given by the RealEstateType enum.
        RealEstateType (1,1) ece.enum.RealEstateType   

        % RawUsageTable: Raw data making up UsageTable as imported from
        % input data source.
        RawUsageTable table = cell2table(...
            {datetime("01/01/1900","Format","MM/dd/uuuu"),...
            datetime("2/01/1900","Format","MM/dd/uuuu"),...
            0,0},...
            "VariableNames",...
            ["StartDate","EndDate","Usage","Cost"]);

    end %properties 

    properties (Access = protected, Transient, NonCopyable)
        % PropertyChangeListeners: Array of property change listeners.
        PropertyChangeListeners (:,1) event.proplistener = ...
            event.proplistener.empty(0,1);

    end % properties (Listeners)

    events
        % PropertyChanged: Event that notifies when properties have
        % changed.
        PropertyChanged

    end %events

    properties (GetAccess = public, SetAccess = protected, AbortSet, SetObservable)
        % AdjustedUsageTable: Table of monthly utility usages and
        % corresponding costs over time period.
        AdjustedUsageTable table
        
        % DataSource: String name of data source that utility data comes
        % from.
        DataSource (1,1) string = "";

    end %properties (Private)


    properties (GetAccess = public, SetAccess = protected)
        % -- Public Get, Private Set Properties
        % AnnualUsageTable: The final annual usage table of an utility.
        AnnualUsageTable table
        
        % MonthlyProfile: The final monthly profile of an utility.
        MonthlyProfile table
        
        % Cost: The rolled-up cost of an utility.
        Cost (1,1) double

    end %properties (Public Set, Private Get)
    

    methods (Sealed)
        % -- Sealed Methods
        % For heterogenous arrays, we need to defined sealed methods to
        % enable them to be called on the elements of the array.
        function doBilling(arrayIn)
            for n = 1:numel(arrayIn)
                arrayIn(n).correctBilling();
            end %endif
        end %function


    end %methods (Sealed)


    methods (Access = protected, Abstract)
        % -- Declare Abstract Methods
        % Abstract methods must be defined in the derivative subclass
        % objects.

        % correctBilling: Method to correct uneven billing periods within
        % the UsageTable that would skew the analysis.
        correctBilling(obj);

    end %methods (Abstract private)


    methods (Access = public, Abstract)
        % -- Abstract Public Methods
        % createUsagePlot: Function to plot the UsageTable data by year.
        createUsagePlot(obj);

    end %methods (Abstract public)


    methods (Access = public)

        function addRowToRawUsageTable(obj,newRowData)
            % addRowToUsageTable: Method to add row data to the bottom of
            % the RawData usage table.
            %   This method is a public accessor to the protected 
            %   RawUsageData property. Appends the input rowData to the
            %   bottom of the existing RawUsageData.

            % Assume the rowData is already perfectly set up.
            obj.RawUsageTable = [obj.RawUsageTable;newRowData];


        end %function

        function removeRowsFromRawUsageTable(obj,rowIndices)
            % removeRowsFromUsageTable: Method to remove row data from the
            % the RawData usage table.
            %   This method is a public accessor to the protected 
            %   RawUsageData property. Removes data from the indices of the
            %   input rows from the RawUsageTable data.

            % Assume the rowData is already perfectly set up.
            obj.RawUsageTable(rowIndices,:) = [];

        end %function       

    end %methods (public)


    methods (Access = protected)
        
        function attachPropChangedListeners(obj)
            % ATTACHPROPCHANGEDLISTENERS Method to go through all
            % observable properties of the utility and attach event
            % notifier to them.
            %   Collects listeners into an array and flags event
            %   notification.

            % Obtain all observable properties.
            metaProps = metaclass(obj).PropertyList;
            observableProps = metaProps([metaProps.SetObservable]);

            % Iteratively create listener for each observable property and
            % store inside the array of listeners.
            for propIdx = 1:numel(observableProps)
                % Create and append listener to array.
                obj.PropertyChangeListeners(propIdx) = addlistener(...
                    obj,...
                    observableProps(propIdx).Name,...
                    "PostSet",@(~,~)obj.onInternalPropertiesChanged());

            end %forloop

        end %function

        function onInternalPropertiesChanged(obj)
            % onInternalPropertiesChanged: Callback method that fires
            % whenever the Utility properties have changed.

            % Display note for debug.
            %disp("Utility observable properties changed! Firing " + ...
            %    "Utility PropertyChanged Event");

            % Notify PropertyChanged Event
            %notify(obj,"PropertyChanged");

        end %function


    end %methods (Protected)


end %classdef

