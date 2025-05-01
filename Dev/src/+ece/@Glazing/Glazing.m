classdef Glazing % < handle
    %GLAZING Class definition file for Glazing object.
    %   A Glazing object is a collection of properties that describe a
    %   glazing (such as a windows, curtainwalls, etc) on a given facade or
    %   skylight on a Building.
    %   A single Glazing object describes a certain type of glazing, and
    %   has a property to represent how many of that glazing exist on the
    %   building with the same properties.
    
    properties (Access = public)
        % -- Define Public Properties of Glazing
        
        % Name - Glazing name. String identifier such as "south windows."
        Name (1,1) string
        
        % Type - Enumeration for glazing type.
        % Can be window, skylight, or curtainwall.
        GlazingType (1,1) ece.enum.GlazingType

        % NumWindows - Number of windows tracked by this set of properties.
        Quantity (1,1) double

        % Width_in - Width of glazing unit in inches.
        Width_in (1,1) double

        % Height_in - Height of glazing unit in inches.
        Height_in (1,1) double

        % FrameWidth_in - Width of frame in inches.
        FrameWidth_in (1,1) double = 2.0;

        % UValue - Insulation factor for the window, in Btu/hr*ft^2*F
        Uvalue (1,1) double

        % SHGC - Solar heat gain coefficient
        SHGC (1,1) double

        % Azimuth_deg - Angular facing of glazing in degrees (North = 0)
        Azimuth_deg (1,1) double

        % Tilt_deg - Tilt angle for glazings. 90 = vertical, 0 = horizontal 
        Tilt_deg (1,1) double

        % ShadingMontly - 1x12 array (1 per month) of proportional
        % shading on the Glazing. 0 = full shade, 1 = full exposure.
        % Ex: [.9,.9,.9,.9,.8,.7,.7,.7,.7,.8,.9,.9]
        ShadingMonthly (1,12) double

        % Location - string name for the city, state or weather location of
        % the glazing.
        Location (1,1) string

    end %properties (Public)

    properties (Access = public, Dependent)
        % -- Define Dependent Properties
        % HeatLossCoeff - Heat loss coefficient for glazing, in units of
        % Btu/hr-F
        HeatLossCoeff (1,1) double

        %GlazedArea - this is used for heat loss coefficient and also
        %needed for solar gains
        GlazedArea (1,1) double

    end %properties
    
    methods
        % -- Internals-related Class Methods
        % Define Constructor Method
        function obj = Glazing()
            %GLAZING Construct an instance of this class
            %   The default Glazing constructor takes no arguments and
            %   returns a default instance of the Glazing object. A Glazing
            %   object with loaded values can be instanced with
            %   the fromSourceData static method.
            %   This object construction style is useful when testing
            %   objects that are intended to be populated from externa
            %   data, as it decouples the object's existence from the
            %   intended supplemental data.
            
        end %function (constructor)

        function value = get.GlazedArea(obj)
            %find the glazed area, subtracting the frame area, square feet
            value = (obj.Width_in - (2 * obj.FrameWidth_in)) * ...
                (obj.Height_in - (2 * obj.FrameWidth_in)) / ...
                144 * obj.Quantity;
        
        end  %function

        function value = get.HeatLossCoeff(obj)
            % Get HeatLossCoeff Value - Method to calculate the
            % HeatLossCoeff values from other properties of Glazing.
            % The Heat Loss Coefficient is the area multiplied by U value.
            
            % Calculate Output HLC
            value = obj.GlazedArea * obj.Uvalue;

        end %function (HeatLossCoeff)
        
    end %methods (public Internals)

    methods   (Access = public, Static)
        % -- Declare Publically Accessible Static Methods Here
        % Public static methods declared here are defined in the class
        % folder  .m method script of the same name.
        % Static methods are callable through the class without
        % needing an instance of the object to be called.

        % FromSourceData - Method to generate a glazing object from a set
        % of input data that defines properties.

        glazingArray = ReadSourceData(fileName);

    end %methods (public, Static)

end %classdef (Glazing)

