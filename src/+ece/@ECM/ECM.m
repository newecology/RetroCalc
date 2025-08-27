classdef ECM < handle & matlab.mixin.Copyable
    %ECM Class for simple Energy Conservation Measure (ECM) object.
    %   Class definition for properties and methods of ECM object.

    properties (Access = public, AbortSet, SetObservable)
        % Name: String name for ECM.
        Name (1,1) string = "Basic ECM";

        % Description: String description for ECM.
        Description (1,1) string = "ECM description...";

        % MeasureComponents: Array of MeasureComponent objects associated
        % to a single ECM
        MeasureComponents (:,1) ...
            ece.MeasureComponent = ece.MeasureComponent.empty(0,1);

        % ImpactOnBuilding: Struct containing the Impacts of the ECM to the
        % associated building.
        ImpactOnBuilding (1,1) struct

    end %properties

    properties (Access = public, Dependent)
        % NumComponents: Number of MeasureComponents.
        NumComponents (1,1) double

    end %properties (Dependent)


    methods % Internal Methods

        function obj = ECM()
            %ECM Construct an instance of this class.
            %   Detailed explanation goes here.

        end %function (Constructor)

        function value = get.NumComponents(obj)
            % Getter for NumComponents.
            %   Returns the total number of MeasureComponents in ECM.
            value = numel(obj.MeasureComponents);

        end %function (Getter)

    end %methods (public Internals)


    methods (Access = public)
        % -- Declare Publically Accessible Methods
        % Method definitions will be fully realized in the correspondingly
        % named function script .m files

        % Apply ECM on Building
        updatedBldg = applyECM(obj,baseBldg)

    end %methods (public)


    methods   (Access = public, Static)
        % Define Static Method Signatures
        % -- ECM Creation Methods
        ecm = readSourceFromFile(filename,sheetname);
        ecm = readSourceFromTable(tbl,name);

    end %methods (public, Static)

end %classdef