classdef PlumbingFixture % < handle
    %   class definition file 
   
    properties (Access = public)
        % -- Define Public Properties
        
        % Type - Enumeration for plumbing fixture type or water end use.
        % Toilet, urinal, bathroom sink, shower, irrigation, cooling tower,
        % etc.
        PlumbingFixtureType (1,1) ece.enum.PlumbingFixtureType

        % Gallons - fixture usage in gallons, but units vary
        Gallons (1,1) double

        % Gallons units
        GallonUnits (1,1) string

        % Uses per ___. units vary
        Uses (1,1) double
        
        UsesUnits (1,1) string

        % temperature at point of use. °F
        UseTemp_F (1,1) double

        % Fraction of total fixtures of that type. If half the showers are
        % 1 gpm, and half are 2 gpm, each of 2 shower objects will have .5 for
        % FractionTotal
        FractionTotal (1,1) double

    end %properties (Public)
  
    methods
        % -- Internals-related Class Methods
        % Define Constructor Method
        function obj = PlumbingFixture()
            %   Construct an instance of this class        
        end %function (constructor)
     
    end %methods (public Internals)

    methods   (Access = public, Static)
        % -- Declare Publically Accessible Static Methods Here
        % Public static methods declared here are defined in the class
        % folder  .m method script of the same name.
        % Static methods are callable through the class without
        % needing an instance of the object to be called.
        % FromSourceData - Method to generate an object from a set
        % of input data that defines properties.

        PlumbingFixtureTbl = ReadSourceData(fileName);

    end %methods (public, Static)

end %classdef (PlumbingFixture)

