classdef Pump < handle
    %Pump Class definition file for pump object.
    %   A pump object represents a real pump that exists and is analyzed when
    %   calculating the total energy consumption for a building.
    %
    %   pump objects are distinct by their Name property, and reference
    %   their own quantity when entered.
    
    properties (Access = public, SetObservable)
        % -- Define Public Properties
        % Name - pump name. Can be the actual pump name or just a
        % string identifier for the pump.
        Name (1,1) string

        % Quantity - Number of this pump that exist for calculation
        % purposes.
        Quantity (1,1) double

        % MotorHP - Motor Horsepower (HP) of pump. Not used in calculation, 
        % but can be used in validation.
        MotorHP (1,1) double

        % FracConditioned - Fraction of motor heat that contributes to heating 
        % the building.
        FracConditioned (1,1) double

        % CalcMethod - Enumeration type for method of calculation to
        % perform when computing the result. (KWH?)
        CalcMethod (1,1) ece.enum.CalculationMethod


        % Flow_CFM - Airflow in cubic-feet/minute CFM.
        Flow_gpm (1,1) double

        % TotalStaticPressure_inch - Total static pressure on the pump in
        % inches of water gauge.
        HeadPressure_feet (1,1) double

        % pumpEfficiency - pump efficiency.
        PumpEfficiency (1,1) double

        % MotorEfficiency - Motor Efficiency
        MotorEfficiency (1,1) double

        % MotorPowerDraw_kW - Motor input power draw in kiloWatts (kW),
        % if it is known. In this case select CalcMethod = 2.
        % If motor power is not known, but the flow and static pressure are
        % known, select CalcMethod = 1 and do not enter any value for
        % MotorPowerDraw.
        MotorPowerDraw_kW (1,1) double

        % AvgSpeed - Average speed of the pump as a fraction 0 to 1. 
        % If pump is variable speed, input average speed of pump when running.
        AvgSpeed (1,1) double

        % OperationHoursPerDay - Hours per day the pump is in operation.
        OperationHoursPerDay (1,1) double

        % OperationMonthRange - Range of months pump is in operation, given
        % as a 2-element array of month indices (eg., Nov to Feb would be
        % given as [11,2], May to Aug would be [5, 8])
        OperationMonths (1,2) int32        
        
    end %properties (Public)

    properties (Access = private)
        % -- Define Private Properties

    end %properties (Private)

    properties (SetAccess = private, GetAccess = public)
        % -- Define Read-Only Properties

    end %propreties (Read-Only)

    properties (Access = private, Constant)
        % -- Define Internal Constant Properties
        % Constant properties are intended to unchanged over the lifetime
        % of the object. Internal ones are set to provide contextual
        % information needed for the object.

    end %properties (Constant, internal)

    properties (Dependent)
        % -- Define Dependent Properties
        % TotalAnnualKWH - Total KWH used in a year for a pump.
        TotalAnnualKWH (1,1) double

        % InternalGains - Measure of the kWh for each month only for those
        % in conditioned spaced.
        InternalGains_kWh (1,12) double

        % InternalGains_kBtu - Conversion of InternalGains from kWh to
        % kBtu (tracked monthly)
        InternalGains_kBtu (1,12) double

        % MonthlyKWH - Array of KWH of pump use on a monthly basis.
        MonthlyKWH (1,12) double

        % Brake horsepower for each pump type
        BrakeHP (1,1) double

        % PowerDrawAllpumps_kW
        PowerDrawAllPumps_kW (1,1) double

    end %properties (Dependent)

    methods
        % -- Internals-related Class Methods
        % Define Constructor Method
        function obj = Pump()
            %pump Construct an instance of the pump class.
            %   The default pump constructor takes no arguments and
            %   returns a default instance of the pump object. A pump
            %   object with loaded values can be instanced with
            %   the fromSourceData static method.
            %   This object construction style is useful when testing
            %   objects that are intended to be populated from externa
            %   data, as it decouples the object's existence from the
            %   intended supplemental data.

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
            value = obj.MonthlyKWH .* obj.FracConditioned;

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
            [value, ~] = obj.calculatePumpInputPower();
            
        end

         % setting the PowerDrawAllPumps_kW property as dependent so that each time the
        % object is created the value automatically updates corresponding
        % to that object 
        function value = get.PowerDrawAllPumps_kW(obj)
            [~, value] = obj.calculatePumpInputPower();
        end

         % setting the MonthlyKWh property as dependent so that each time the
        % object is created the value automatically updates corresponding
        % to that object 
        function value = get.MonthlyKWH(obj)
            value = obj.computeMonthlyKWH();
        end


    end %methods (public Internals)

    methods (Access = public)
        % -- Declare Publically Accessible Methods
        % Method definitions will be fully realized in the correspondingly
        % named function script .m files in the pump class folder @pump.

        % CalculateMotorProperties - Method to assess the Motor properties
        % of the pump and calculate any required ones using the selected 
        % CalculationMethod.
        [brakeHP, powerDrawAllPumps] = calculatePumpInputPower(obj);

        % ComputeMonthlyKWH - Method to compute the monthly KWH draw for a
        % pump.
        monthkWh = computeMonthlyKWH(obj);

    end %methods (public)


    methods (Access = private)
        % -- Declare Privately Accessible Methods Here
        % Method definitions will be fully realized and defined in the
        % correspondingly named function script .m files in the class
        % folder @pump. Private methods are only callable within 
        % objects of this same class.

    end %methods (private)


    methods (Access = public, Static)
        % -- Declare Publically Accessible Static Methods Here
        % Public static methods declared here are defined in the class
        % folder @pump under the .m method script of the same name.
        % Static methods are callable through the pump class without
        % needing an instance of the object to be called.

        % FromSourceData - Method to generate a pump object from a set
        % of input data that defines properties of the pump.
        pmp = ReadSourceData(fileName);

    end %methods (public, Static)


end %classdef (pump)

