classdef DHWtanks < handle & matlab.mixin.Copyable
    % DHWTANKS Class definition for DHWtank object.
    %  Describes the properties of a domestic hot water (DHW) tank that can
    %  be included in a Building for Level 2 Analysis.
   
    properties (Access = public)
        % -- Define Public Properties
        
        % Name: String name for labeling an instance of the object.
        Name (1,1) string = "Default DHW Tank";

        % Quantity: How many tanks of this type
        Quantity (1,1) double = 1;
        
        % Volume in gallons of each tank
        Volume_gal (1,1) double = 0;

        % Tank temperature °F
        TankTemp_F (1,1) double = 130;

        % reference temperature (temperature of room the tank is in) °F
        RefTemp_F (1,1) double = 70;

        % heat loss per hour as a percent of energy in the tank relative to
        % the reference temperature
        PercentLossHr (1,1) double = 1;

        % hours per year that the tank is hot (if always = 8760 hours)
        HoursHot (1,1) double = 8760;

        % fraction of heat loss in conditioned space and that contributes
        % to heating the building
        FracCond (1,1) double = 0.5;

        % controls kW. power draw of any on-board controls or pump
        % default 50 Watts
        ControlskW (1,1) double = 0;

    end %properties (Public)
  
    methods
        % -- Internals-related Class Methods
        % Define Constructor Method
        function obj = DHWtanks()
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

        DHWtanksTbl = readSourceData(fileName);

    end %methods (public, Static)

end %classdef (DHW tanks)

