classdef DHWsystem < handle & matlab.mixin.Copyable
    %   DHWSYSTEM Class definition file for both the water system and the 
    %   domestic hot water system.
   
    properties (Access = public)
        % -- Define Public Properties
        % Name: String name for labeling an instance of the object.
        Name (1,1) string = "Default DHW System";
        
        % Type - Enumeration for domestic hot water system type.
        % gas-fired heater with indirect tank, gas-fired tank
        % demand gas, electric tank, demand electric, heat pump water heater
        WaterHeaterType (1,1) ece.enum.WaterHeaterType = ...
            ece.enum.WaterHeaterType.GasFiredHeaterWithIndirectTank;
        
        % does the DHW system have recirculation? 0 = no, 1 = yes
        DHWrecirculation (1,1) logical = true;

        % recirculation loop type or quality
        % compact insulated, average, long runs poorly insulated
        RecircLoopType (1,1) ece.enum.RecircLoopType = ...
            ece.enum.RecircLoopType.Average;

        % minimum temperature of cold water from the plumbing mains
        % which usually occurs in February (northern hemisphere). °F
        ColdWaterMinTempFeb_F (1,1) double = 44;

        % maximum temperature of cold water from the plumbing mains
        % which usually occurs in August (northern hemisphere). °F
        ColdWaterMaxTempAug_F (1,1) double = 66;

        % outlet temperature of a water heater serving residences. °F
        HeaterOutputTemp_F (1,1) double = 125;

        % outlet temperature of a commercial kitchen water heater. °F
        HeaterOutputTempCommlKitchen_F (1,1) double = 140;

        % efficiency of the water heater at steady state
        SteadyStateEfficiency (1,1) double = 0;

        % seasonal variation of the heater efficiency if any, expressed as
        % the amplitude of a sin wave
        EfficiencySeasonalAmplitude (1,1) double = 0;

        % heat losses from the circulation piping as a fraction of the
        % fixture load. in July when losses are presumed at a minimum.
        CircLossesJulyFracOfLoad (1,1) double = 0.2;

        % seasonal variation of the circulation losses if any, expressed as
        % the amplitude of a sin wave
        CircLossesSeasonalAmplitude (1,1) double = 0.1;

        % fraction of heat loss from heater that enters conditioned space
        CircLossesFracCond (1,1) double = 0.75;

        % controls kW. power draw of any on-board controls or pump
        % default 50 Watts. this energy does not heat the water.
        ControlskW (1,1) double = 0.02;

        % fraction of the building load served by this water heater
        FractionBuildingLoadServed (1,1) double = 0;

    end %properties (Public)
  
    methods %Internal Methods
        
        function obj = DHWsystem()
            %   Construct an instance of this class.

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

        DHWsystemArray = readSourceData(fileName);

    end %methods (public, Static)

end %classdef (DHW tanks)

