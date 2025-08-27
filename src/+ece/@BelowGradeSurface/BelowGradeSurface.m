classdef BelowGradeSurface < handle & matlab.mixin.Copyable
    %   Below grade surface class definition file for below grade surface object.
    %   This is a collection of properties that describe a set of below grade surfaces
    %   such as a basement or crawl space.
    %   Rarely a building may have more than one set of below grade surfaces.

    properties (Access = public)
        % -- Define Public Properties of the below grade space
        % Name: String name for labeling an instance of the object.
        Name (1,1) string = "Default Below Grade Surface";

        %Area of below grade wall in square feet
        BGwallArea_ft2 (1,1) double = 0;

        % R value of below grade wall insulation if any in hr-ft2-F/Btu
        % The insulation if any starts at grade level and extends down to
        % WallInsulDepthBelowGrade
        BGwallInsulR (1,1) double = 0;

        % Wall insulation depth below grade in feet (if any wall insulation)
        WallInsulDepthBelowGrade_ft (1,1) double = 0;

        % Area of below grade floor in square feet
        BGfloorArea_ft2 (1,1) double = 0;

        % R value of below grade floor insulation if any in hr-ft2-F/Btu
        BGfloorInsulR (1,1) double = 0;

        % Basement or crawl space floor depth below grade in feet
        BasementDepthBelowGrade_ft (1,1) double = 0;

        % Basement or crawl space temperature in °F
        BasementTemp_F (1,1) double = 0;

        % Basement or crawl space perimeter in feet
        BasementPerimeter_ft (1,1) double = 0;

        % Basement or crawl space minimum dimension in feet
        % For a rectangular space, this is just the shortest side.
        BasementMinDimension_ft (1,1) double = 0;

        % R value of a standard uninsulated concrete foundation wall
        % with the interior air film only
        BaseSlabR (1,1) double = 1.47;

        % -- MW_TODO: Why do these need to move to site?
        % Should be inherited/derived from Site.

        % Soil thermal conductivity in Btu/hr-ft-°F
        SoilThermalConductivity (1,1) double = 0;
        % move to site class

        %Phase constant for time lag in days for the location
        PhaseConstantForTimeLag_days (1,1) double = 35;
        % move to site class

        % Location: Location reference object.
        Location (1,1) ece.Location

    end %properties (Public)

    properties (Dependent)
        % -- Define Dependent Properties
        % BGwallMonthHeatLoss_kBtur: Monthly heat loss from walls of below
        % grade surfaces.
        BGwallMonthHeatLoss_kBtu (12,1) double

        % BGfloorMonthHeatLoss_kBtur: Monthly heat loss from floors of
        % below grade surfaces.
        BGfloorMonthHeatLoss_kBtu (12,1) double

    end %properties (Read-Only)


    methods %Internal Methods
        % -- Internals-related Class Methods
        function obj = BelowGradeSurface()
            % Construct an instance of this class.
            %   Set any properties on startup here.

        end %function (constructor)

        % -- Property Get Methods
        function value = get.BGwallMonthHeatLoss_kBtu (obj)
            [value, ~] = obj.calculateBGsurfaceHeatLoss;
        end  % property getter function

        function value = get.BGfloorMonthHeatLoss_kBtu(obj)
            [~, value] = obj.calculateBGsurfaceHeatLoss;
        end  % property getter function


    end % methods internals

    methods (Access = public)

        % calculate heat loss
        [BGwallMonthHeatLoss_kBtu, BGfloorMonthHeatLoss_kBtu] = ...
            calculateBGsurfaceHeatLoss(obj);

    end  % methods, public



    methods   (Access = public, Static)
        % -- Declare Publically Accessible Static Methods Here
        % Public static methods declared here are defined in the class
        % folder @BelowGradeSurface under the .m method script of the same name.
        % Static methods are callable through the BelowGradeSurface class without
        % needing an instance of the object to be called.

        % FromSourceData - Method to generate a BelowGradeSurface object from a set
        % of input data that defines properties.
        %fileName = "C:\Users\HenryHarvey\Desktop\Projects\MATLAB\Nov2023\L2calcs\calcInputs8";
        %belowGradeSurfacesTbl = ReadBelowGradeSurfacesDataFromExcel(fileName);
        belowGradeSurfacesTbl = readSourceData(fileName);

    end %methods (public, Static)


end %classdef

