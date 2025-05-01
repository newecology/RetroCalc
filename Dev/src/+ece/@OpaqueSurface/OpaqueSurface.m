classdef OpaqueSurface % < handle
    %   Opaque surface class definition file for opaque surface object.
    %   An opaque surface object is a collection of properties that describe an
    %   opaque surface (wall, roof, attic floor, door, overhanging floor, adiabatic)
    %   on a given facade of a Building.
    %   A single opaque surface object describes a certain instance of surface
    %   (area, R value, azimuth, tilt). Surface emittance and monthly
    %   shading are included for future use.
    
    properties (Access = public)
        % -- Define Public Properties of OpaqueSurface
        
        % Name - surface name. String identifier. "south wall" for example.
        Name (1,1) string

        % Type - Enumeration for opaque surface type.
        % Can be wall, roof, attic floor, door, overhanging floor, or
        % adiabatic.
        OpaqueSurfaceType (1,1) ece.enum.OpaqueSurfaceType

        % Area_ft2 - area of the opaque surface in square feet.
        Area_ft2 (1,1) double

        % RValue - Insulation factor for the opaque surface, in
        % hr*ft^2*F/Btu
        RValue (1,1) double

        % SurfaceEmittance - emittance of the surface. For future use.
        SurfaceEmittance (1,1) double

        % Azimuth_deg - Angular facing of surface in degrees (North = 0)
        % Not relevant for horizontal surfaces. 
        Azimuth_deg (1,1) double

        % Tilt_deg - Tilt angle for glazings. 90 = vertical, 0 = horizontal.
        % Walls and doors are 90 deg; flat roofs, attic floors, and overhangs
        % are 0 deg; enter tilt of sloped roofs.
        Tilt_deg (1,1) double

        % ShadingMontly - 1x12 array (1 per month) of proportional
        % shading on the surface. 0 = full shade, 1 = full exposure.
        % Ex: [.9,.9,.9,.9,.8,.7,.7,.7,.7,.8,.9,.9]
        ShadingMonthly (1,12) double

        % Location - string name for the city, state or weather location of
        % the glazing.
        Location (1,1) string

    end %properties (Public)

    properties (Access = public, Dependent)
        % -- Define Dependent Properties
        % HeatLossCoeff - Heat loss coefficient for surface, in units of
        % Btu/hr-F
        HeatLossCoeff (1,1) double

% add property for total area of all opaque surfaces


    end %properties
    
    methods
        % -- Internals-related Class Methods
        % Define Constructor Method
        function obj = OpaqueSurface()
            %OpaqueSurface Construct an instance of this class
            %   The default constructor takes no arguments and
            %   returns a default instance of the object. An
            %   object with loaded values can be instanced with
            %   the fromSourceData static method.
            %   This object construction style is useful when testing
            %   objects that are intended to be populated from external
            %   data, as it decouples the object's existence from the
            %   intended supplemental data.
            
        end %function (constructor)

        function value = get.HeatLossCoeff(obj)
            % Get HeatLossCoeff Value - Method to calculate the
            % HeatLossCoeff values from other properties of the opaque surface.
            % The Heat Loss Coefficient is the area divided by R value.
            % Calculate Output HLC
            value = obj.Area_ft2 / obj.RValue;

        end %function (HeatLossCoeff)
        
    end %methods (public Internals)

    methods   (Access = public, Static)
        % -- Declare Publically Accessible Static Methods Here
        % Public static methods declared here are defined in the class
        % folder  .m method script of the same name.
        % Static methods are callable through the class without
        % needing an instance of the object to be called.

        % FromSourceData - Method to generate an object from a set
        % of input data that defines properties.

        opaqueSurfaceTbl = ReadSourceData(fileName);

    end %methods (public, Static)



end %classdef (OpaqueSurface)

