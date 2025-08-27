classdef PlumbingFixture < handle & matlab.mixin.Copyable
    %   class definition file 
   
    properties (Access = public)
        % -- Define Public Properties
        % Name: String name for ilabeling an instance of the object.
        Name (1,1) string = "Default Plumbing Fixture";
        
        % Type - Enumeration for plumbing fixture type or water end use.
        % Toilet, urinal, bathroom sink, shower, irrigation, cooling tower,
        % etc.
        PlumbingFixtureType (1,1) ece.enum.PlumbingFixtureType = ...
            ece.enum.PlumbingFixtureType.Toilets;

        % Gallons - fixture usage in gallons, but units vary
        Gallons (1,1) double = 0;

        % GallonUnits: Unit Type for Gallons.
        GallonUnits (1,1) string = "Gallons/Use";

        % Uses: Number of uses for the Uses per X.
        Uses (1,1) double = 0;
        
        % UsesUnits: Unit Type for Uses per X. Replaces "per X".
        UsesUnits (1,1) string = "Use/time/entity";

        % temperature at point of use. °F
        UseTemp_F (1,1) double = 0;

        % Fraction of total fixtures of that type. If half the showers are
        % 1 gpm, and half are 2 gpm, each of 2 shower objects will have .5 for
        % FractionTotal
        FractionTotal (1,1) double = 0;

    end %properties (Public)

    properties (Access = public, Dependent)
        % DisplayGallonUnits: Display Units Type for Gallon.
        DisplayGallonUnits (1,1) string

        % DisplayUsesUnits: Display Units Type for Uses.
        DisplayUsesUnits (1,1) string

    end %properties (Public, Dependent)
  
    methods %Internal Methods
        % -- Internals-related Class Methods
        % Define Constructor Method
        function obj = PlumbingFixture()
            %   Construct an instance of this class        
        end %function (constructor)
    
        function value = get.DisplayGallonUnits(obj)
            % Getter for DisplayGallonUnits.
            %   Maps the object's PlumbingFixtureType to a description of
            %   the what the Gallon units are used for. For example,
            %   Gallons for Toilet are in units of Gallons per flush.
            
            % Output Based on Switch Case
            switch obj.PlumbingFixtureType
                case {ece.enum.PlumbingFixtureType.Toilets,...
                        ece.enum.PlumbingFixtureType.Urinals}
                    % Gallon per Flush Types
                    value = "gal/flush";

                case {ece.enum.PlumbingFixtureType.BathroomSink,...
                        ece.enum.PlumbingFixtureType.KitchenSink,...
                        ece.enum.PlumbingFixtureType.Shower,...
                        ece.enum.PlumbingFixtureType.CommercialKitchenSink}
                    % Gallons per Minute Types
                    value = "gal/min";

                case {ece.enum.PlumbingFixtureType.InUnitDishwasher,...
                        ece.enum.PlumbingFixtureType.CommercialDishwasher}
                    % Gallones per Cycle
                    value = "gal/cycle";

                case {ece.enum.PlumbingFixtureType.InUnitClotheswasher,...
                        ece.enum.PlumbingFixtureType.CommonAreaClotheswasher}
                    % Gallons per Load
                    value = "gal/load";

                case {ece.enum.PlumbingFixtureType.Irrigation,...
                        ece.enum.PlumbingFixtureType.CoolingTower,...
                        ece.enum.PlumbingFixtureType.Other}
                    % Gallons Annual
                    value = "gal/yr";

                otherwise
                    % Unhandled Types get no unit.
                    value = "unused";

            end %switch/case

        end %function


        function value = get.DisplayUsesUnits(obj)
            % Getter for DisplayUsesUnits.
            %   Maps the object's PlumbingFixtureType to a description of
            %   the what the Uses values are used for. For example,
            %   UseUnits for Toilet are in units of flush/day/person.
            
            % Output Based on Switch Case
            switch obj.PlumbingFixtureType
                case {ece.enum.PlumbingFixtureType.Toilets,...
                        ece.enum.PlumbingFixtureType.Urinals}
                    % Gallon per Flush Types
                    value = "flush/day/person";

                case {ece.enum.PlumbingFixtureType.BathroomSink,...
                        ece.enum.PlumbingFixtureType.KitchenSink,...
                        ece.enum.PlumbingFixtureType.Shower,...
                        ece.enum.PlumbingFixtureType.CommercialKitchenSink}
                    % Gallons per Minute Types
                    value = "min/day/person";

                case {ece.enum.PlumbingFixtureType.InUnitDishwasher,...
                        ece.enum.PlumbingFixtureType.CommercialDishwasher}
                    % Gallones per Cycle
                    value = "cycle/week/apartment";

                case {ece.enum.PlumbingFixtureType.InUnitClotheswasher,...
                        ece.enum.PlumbingFixtureType.CommonAreaClotheswasher}
                    % Gallons per Load
                    value = "load/week/apartment";

                case {ece.enum.PlumbingFixtureType.Irrigation,...
                        ece.enum.PlumbingFixtureType.CoolingTower,...
                        ece.enum.PlumbingFixtureType.Other}
                    % Gallons Annual
                    value = "unused";

                otherwise
                    % Unhandled Types get no unit.
                    value = "unused";

            end %switch/case

        end %function


    end %methods (public Internals)

    methods   (Access = public, Static)
        % -- Declare Publically Accessible Static Methods Here
        % Public static methods declared here are defined in the class
        % folder  .m method script of the same name.
        % Static methods are callable through the class without
        % needing an instance of the object to be called.
        % FromSourceData - Method to generate an object from a set
        % of input data that defines properties.

        plumbingFixtures = readSourceData(fileName);

    end %methods (public, Static)

end %classdef (PlumbingFixture)

