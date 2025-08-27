classdef Package < handle & matlab.mixin.Copyable
    %PACKAGE Class for simple Package.
    %   Class for defining the Package object propreties and methods.

    properties (Access = public, AbortSet, SetObservable)
        % Name: Name of Package.
        Name (1,1) string = "Basic Package";

        % Description: Description of Package
        Description (1,1) string = "Enter description...";

        % ECMs: Array collection of ECM objects included in the Package.
        ECMs (:,1) ece.ECM = ece.ECM.empty(0,1);

        % ImpactOnBuilding: Impacts wrapped up in a struct.
        ImpactOnBuilding (1,1) struct

    end %properties (Private set, public get)

    properties (Access = public, Transient)
        % ECMBuildings: Reference to Buildings that ECMS in Package create.
        ECMBuildings (:,1) ece.Building = ece.Building.empty(0,1);

    end %properties (Public, Transient)

    properties (Access = public, Dependent)
        % NumECMs: Number of ECMs within Package.
        NumECMs (1,1) double

        % ResultBuilding: Resulting Building after Package is applied.
        ResultBuilding (:,1) ece.Building

    end %properties (Dependent)


    methods % Internal Methods

        function obj = Package()
            %Package Construct an instance of this class.
            %   Detailed explanation goes here.

        end %function (Constructor)

        function value = get.NumECMs(obj)
            % Getter for NumECMs.
            %   Returns the total number of ECMs in Package.
            value = numel(obj.ECMs);

        end %function (Getter)

        function value = get.ResultBuilding(obj)
            % Getter for ResultBuilding.
            %   Returns the ECM Building that has all ECMs in package
            %   applied to it as the ResultBuilding.
            value = obj.ECMBuildings(end);

        end %function (Getter)

    end %methods

    methods (Access= protected)

    function cpObj = copyElement(obj)
        % copyElement: Override method from matlab.mixin.Copyable to
        % create a deep copy of the Package.
        %   By default, the copy method makes a shallow copy of the
        %   Package. This creates a new Package object reference, but
        %   points to the same handle property references (aka, all of
        %   the object references.)
        %   This is not the desired behavior - we want a deep copy,
        %   which will make an entirely new reference to all handle
        %   objects in the Package (nested).

        % -- Create New Copy Package Reference
        % Call default copy method to create initial copied Package
        % object with shallow copies.
        cpObj = copyElement@matlab.mixin.Copyable(obj);

        % -- Deep Copy Handle Object Arrays
        % Package ECM Collection
        cpObj.ECMs = copy(obj.ECMs);

    end %function

    end %methods (protected)

    methods (Access = public)
        % -- Declare Publically Accessible Methods
        % Method definitions will be fully realized in the correspondingly
        % named function script .m files

        % -- ECM Add/Remove Methods
        addECMs(obj,ecms);
        removeECMS(obj,ecmIdxs);

        % -- Package Application Methods
        applyPackage(obj,baseBldg);

    end %methods (public)


    methods (Access = public, Static)
        % Define Static Method Signatures
        % -- Package Creation Methods
        package = readSourceFromData(ecmArray,nameArray,pckgName);
        package = readSourceFromFile(fnmArray, shnArray, pckgName);

    end %methods (public, Static)

end %classdef

