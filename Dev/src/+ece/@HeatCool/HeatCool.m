% Class to implement the Systems for Heating and cooling
classdef HeatCool < handle
    properties   % from user inputs
        SystemName string
        SystemType (1,1) ece.enum.SystemType
        SystemFunction (1,1) ece.enum.SystemFunction
        EnergySource (1,1) ece.enum.EnergySourceType 
        Quantity int16 
        HeatCapacityEach double
        HeatCapUnits (1,1) ece.enum.HeatCapUnits
        CoolCapacityEach double
        CoolCapUnits (1,1) ece.enum.CoolCapUnits
        HeatFrac double
        CoolFrac double
        ControlskW double 
        DistEffHtg double
        DistEffClg double
        HeatEff (1,1) double
        HeatEffUnits (1,1) ece.enum.HeatingEfficiencyUnits
        CoolEff (1,1) double
        CoolEffUnits (1,1) ece.enum.CoolingEfficiencyUnits
        
    end
  
properties (Dependent)

    % System efficiency as a function of outdoor air temperature, heating.
    EffCurveHtg (1, 5) double

    % System efficiency as a function of outdoor air temperature, cooling.
    EffCurveClg (1, 5) double

end  % read only properties

methods
    % -- Internals-related Class Methods
    % Define Constructor Method
    function obj = HeatCool()
        % Heating / cooling system. Construct an instance of this class
        %   The default constructor takes no arguments and
        %   returns a default instance of the object. An
        %   object with loaded values can be instanced with
        %   the fromSourceData static method.
        %   This object construction style is useful when testing
        %   objects that are intended to be populated from external
        %   data, as it decouples the object's existence from the
        %   intended supplemental data.

    end %function (constructor)
%Getter funtion for the properties EffCurveHtg   and EffCurveClg , 
% so that their values are automatically updated for each each object of the class  

    function value = get.EffCurveHtg(obj)
          [value,~] = obj.calcHeatCoolEffs;
    end  %end function
   
    function value = get.EffCurveClg(obj)
          [~,value] = obj.calcHeatCoolEffs;
    end  %end function
   
end % end method block     
    methods(Access = public, Static)
        HeatCoolArr = ReadSourceData(fileName);
    end
    %methods (Access = public)
     
    %end

methods  

   %Declaring the method to calculatye the coefficients for the heating and cooling
   %curves for the various equipments
   [EffCurveHtg, EffCurveClg] = calcHeatCoolEffs(obj);


end   % method


end  % classdef
