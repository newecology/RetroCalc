classdef MeasureComponent < handle
    %MEASURECOMPONENT Class that contains information about each
    %individual measure within an ECM.
    %  A MeasureComponent object is the atomic change that is performed one
    %  at a time within an ECM. This can insert data, edit, or delete data.

    properties (Access = public, AbortSet, SetObservable)
        % -- Declare Publically Accessible Properties
        % ObjectofReference: The object (class) that will be changed
        ObjectOfReference (1,1) string

        % ObjectVarName: Name of Object's Variable.
        ObjectVarName (1,1) string

        % Operation: INSERT, DELETE or UPDATE
        Operation (1,1) string

        % PropertyToChange: Property of the class that will be changed
        PropertyToChange (1,1) string

        % ValueForChange: Updated value.
        ValueForChange

        % UpdateType: ADD/MULTIPLY/REPLACE
        UpdateType (1,1) string

        % IrrigationGal: Integer value indicating number of gallons used
        % for irrigation.
        FilterCriteria (1,1) string

        % InsertQuantity: Number of instances of the object to be inserted
        InsertQuantity (1,1) double {mustBeInteger}

        % InsertedProperty: Porperty values of the inserted object
        InsertedProperty (1,1) string

    end %properties (Public)

    methods
        % -- Internals-related Class Methods
        % Define Constructor Method
        function obj = MeasureComponent()
            %MEASURECOMPONENT Construct an instance of the MeasureComponent
            % class.
            %   The default MeasureComponent takes no input arguments.

        end %function (Constructor)

    end %methods (public, Internal)


    methods (Access = public)
        % -- Public Method Signatures
        % Apply Measure
        building = applyMeasure(obj,building);

    end %methods (public)

end %classdef