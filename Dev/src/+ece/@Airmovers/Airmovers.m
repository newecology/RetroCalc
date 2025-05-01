classdef Airmovers < handle
% Site to contain the calculations for Ventilation and Fan 
    properties
        % Name of the Airmovers, either ventilator or non-ventilator fan
        Name (:,1) string

        %Type of Airmovers
        Type (:,1) ece.enum.VentilationType

        % Quantity
        Quantity double
        
        % the design flow in cubic feet per minute CFM
        DesignCFMperUnit  double
        
        % fraction of total flow that is ventilation flow (moves air in or
        % out of the building). fraction 0 to 1
        FractionVentilation double {mustBeInRange(FractionVentilation, 0, 1)}

        % Average speed of the fan as a fraction of 0 to 1. 
        % If fan is variable speed, estimate average speed of fan when running.
        % Allows variable fan speed for two periods of the day, time1 and time2.
        AverageSpeed (1,2) double {mustBeInRange(AverageSpeed, 0, 1)}
        
        % Hours of operation per day in time periods 1 and 2
        OperationHoursPerDay (1,2) double {mustBeInRange(OperationHoursPerDay, 0, 24)}
        
        % ERV efficiencies
        HeatingSensibleEfficiency double = 0
        CoolingTotalEfficiency double = 0

        % MotorHP - Motor Horsepower (HP) of Fan. Not used in calculation, 
        % but can be used in validation.
        MotorHP (1,1) double

        % FracConditioned - Fraction of motor heat that contributes to heating 
        % the building.
        FractionConditioned (1,1) double

        % CalcMethod - Enumeration type for method of calculation to
        % perform when computing the result. (KWH?)
        CalcMethod (1,1) ece.enum.CalculationMethod

        % TotalStaticPressure_inch - Total static pressure on the fan in
        % inches of water gauge.
        TotalStaticPressure_inch (1,1) double

        % FanEfficiency - Fan efficiency.
        FanEfficiency (1,1) double %{mustBeInRange(FanEfficiency, 0, 1)}

        % MotorEfficiency - Motor Efficiency
        MotorEfficiency (1,1) double %{mustBeInRange(MotorEfficiency, 0, 1)}

        % MotorPowerDraw_kW - Motor input power draw in kiloWatts (kW),
        % if it is known. In this case select CalcMethod = 2.
        % If motor power is not known, but the flow and static pressure are
        % known, select CalcMethod = 1 and do not enter any value for
        % MotorPowerDraw.
        MotorPowerDraw_kW (1,1) double

        % OperationMonthRange - Range of months fan is in operation, given
        % as a 2-element array of month indices (eg., Nov to Feb would be
        % given as [11,2], May to Aug would be [5, 8])
        OperationMonths (1,2) double %{mustBeInRange(OperationMonths, 1, 12)}   
  
    end


% Some dependent properties for fan electric calculations
    properties (Dependent)
        % -- Define Dependent Properties
        % TotalAnnualKWH - Total KWH used in a year for a fan.
        TotalAnnualKWH (1,1) double

        % InternalGains - Measure of the kWh for each month only for those
        % in conditioned spaced.
        InternalGains_kWh (1,12) double

        % InternalGains_kBtu - Conversion of InternalGains from kWh to
        % kBtu (tracked monthly)
        InternalGains_kBtu (1,12) double

        %Setting the output properties to dependent so that with each
        %object creation they are updated automatically

        % MonthlyKWH - Array of KWH of fan use on a monthly basis.
        MonthlyKWH (1,12) double

        % Brake horsepower for each fan type
        BrakeHP (1,1) double

        % PowerDrawAllFans_kW
        PowerDrawAllFans_kW (1,2) double

    end %properties (Dependent)
    methods
        % -- Internals-related Class Methods
        % Define Constructor Method
        function obj = Airmovers()
            %Airmover Construct an instance of the Airmover class.
            %   The default Airmover constructor takes no arguments and
            %   returns a default instance of the Airmover object.

        end %function (constructor)

         % -- Property Get Methods
        function value = get.TotalAnnualKWH(obj)
            % TotalAnnualKWH Property Get Method
            %  Calculates the value for TotalAnnualKWH property when
            %  accessed from other properties of this object.

            % Calculate TotalAnnualKWH as sum of Monthly KWH.
            value = sum(obj.MonthlyKWH);

        end %function (propGet)

        function value = get.InternalGains_kWh(obj)
            % InternalGains_kWh Property Get Method
            %  Calculates the value for InternalGains_kWh property when
            %  accessed from other properties of this object.

            % Calculate InternalGains for conditioned area.
            value = obj.MonthlyKWH .* obj.FractionConditioned;

        end %function (propGet)

        function value = get.InternalGains_kBtu(obj)
            % InternalGains_kBtu Property Get Method
            %  Calculates the value for InternalGains_kBtu property when
            %  accessed from other properties of this object.

            % Calculate InternalGains_kBtu off InternalGains_kWh
            value = obj.InternalGains_kWh .* 3.413;
           
        end %function (propGet)


        % setting the BrakeHp property as dependent so that each time the
        % object is created the value automatically updates corresponding
        % to that object 
        function value = get.BrakeHP(obj)
            [value, ~] = obj.calculateFanInputPower();
            
        end

         % setting the PowerDrawAllPumps_kW property as dependent so that each time the
        % object is created the value automatically updates corresponding
        % to that object 
        function value = get.PowerDrawAllFans_kW(obj)
            [~, value] = obj.calculateFanInputPower();
        end

         % setting the MonthlyKWh property as dependent so that each time the
        % object is created the value automatically updates corresponding
        % to that object 
        function value = get.MonthlyKWH(obj)
            value = obj.computeMonthlyKWH();
        end

    end %methods (public Internals)

    methods (Access = public)
    %     % -- Declare Publically Accessible Methods
    %     % Method definitions will be fully realized in the correspondingly
    %     % named function script .m files in the Airmover class folder @Fan.
    % 
    %     % CalculateMotorProperties - Method to assess the Motor properties
    %     % of the fan and calculate any required ones using the selected 
    %     % CalculationMethod.
    %     [BrakeHP, PowerDrawAllFans_kW ] = calculateFanInputPower(obj);
    % 
    %     % ComputeMonthlyKWH - Method to compute the monthly KWH draw for a
    %     % fan.
    %     MonthlyKWH  = computeMonthlyKWH(obj);
    % 
        % Method to Compute the monthly ventilation for a ventilator given the inputs
        [HtngVentilationFlow, ClngVentilationFlow] = calcMonthlyVentilation(obj);

     end %methods (public)

    methods (Access = public, Static)
        % -- Declare Publically Accessible Static Methods Here
        % Public static methods declared here are defined in the class
        % folder @Fan under the .m method script of the same name.
        % Static methods are callable through the Fan class without
        % needing an instance of the object to be called.

        % FromSourceData - Method to generate a Fan object from a set
        % of input data that defines properties of the Fan.
        airMovers=ReadSourceData(fileName);

    end 
end
