classdef HeatCool < handle & matlab.mixin.Copyable
    % Class to implement the Systems for Heating and cooling

    properties   % from user inputs
        % Name: String name for labeling an instance of the object.
        Name (1,1) string = "Default HeatCool System";

        % SystemType: Type of Heat/Cool System this object belongs to.
        SystemType (1,1) ece.enum.SystemType = ...
            ece.enum.SystemType.condGasBoilerOAreset;

        % SystemFunction: Type of function this Heat/Cool System performs.
        SystemFunction (1,1) ece.enum.SystemFunction = ...
            ece.enum.SystemFunction.HeatingOnly;

        % EnergySource: Source of energy that powers the Heat/Cool System.
        EnergySource (1,1) ece.enum.EnergySourceType = ...
            ece.enum.EnergySourceType.Electricity;

        % Quantity: Amount of individual objects in System to evaluate.
        % Acts as multiplier.
        Quantity (1,1) double = 0;

        % HeatCapacityEach
        HeatCapacityEach (1,1) double = 0;

        % CoolCapacityEach
        CoolCapacityEach (1,1) double = 0;

        % HeatCapUnits: Units of Heat Capacity.
        HeatCapUnits (1,1) ece.enum.HeatCapUnits = ...
            ece.enum.HeatCapUnits.kBtuPerHour;

        % CoolCapUnits: Units of Cooling capacity.
        CoolCapUnits (1,1) ece.enum.CoolCapUnits = ...
            ece.enum.CoolCapUnits.kBtuPerHour;

        % Heat Frac: Fraction of object used for Heating.
        HeatFrac (1,1) double = 0;

        % Cool Frac: Fraction of object used for Cooling.
        CoolFrac (1,1) double = 0;

        ControlskW (1,1) double = 0;

        % Efficiency Values
        DistEffHtg (1,1) double = 0;
        DistEffClg (1,1) double = 0;
        HeatEff (1,1) double = 0;
        CoolEff (1,1) double = 0;

        % Heat/CoolEffUnits: Units of Heating/Coolin efficiency.
        HeatEffUnits (1,1) ece.enum.HeatingEfficiencyUnits = ...
            ece.enum.HeatingEfficiencyUnits.ThermalEfficiency;
        CoolEffUnits (1,1) ece.enum.CoolingEfficiencyUnits = ...
            ece.enum.CoolingEfficiencyUnits.EER;

    end % properties

    properties (Access = private)
        % UseReferenceValueFlag: Flag to indicate the user intends for the
        % reference value to be used.
        UseReferenceValueFlag (1,1) logical = false;

    end %properties

    properties (Dependent)

        % System efficiency as a function of outdoor air temperature, heating.
        HeatingEfficiencyCurve (1, 5) double

        % System efficiency as a function of outdoor air temperature, cooling.
        CoolingEfficiencyCurve (1, 5) double

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

            % Assign NaN to Efficiency Values to force default result
            % acquisition?
            obj.DistEffHtg = NaN;
            obj.HeatEff = NaN;
            obj.DistEffClg = NaN;
            obj.CoolEff = NaN;

        end %function (constructor)

        %Getter funtion for the properties EffCurveHtg  and EffCurveClg ,
        % so that their values are automatically updated for each each object of the class

        
        function value = get.HeatingEfficiencyCurve(obj)
            [value,~] = obj.calculateEfficiencies;
        end  %end function

        function value = get.CoolingEfficiencyCurve(obj)
            [~,value] = obj.calculateEfficiencies;
        end  %end function

        function set.DistEffHtg(obj,value)
            % Setter for DistEffHtg
            %   Depending on the input value, the value is directly set or
            %   used to pull the default reference value for HeatCool.

            % -- Non-NAN values get directly set.
            if ~isnan(value)
                obj.DistEffHtg = value;
                return;
            end %endif

            % -- Set Value to 0 if No Heating
            % Determine Heating/Cooling References
            isHeating = ismember(obj.SystemFunction,...
                [ece.enum.SystemFunction.HeatingOnly,ece.enum.SystemFunction.BothHeatingAndCooling]);
            if ~isHeating
                obj.DistEffHtg = 0;
                return;
            end %endif

            % -- Get Reference Value
            % Get Reference Table
            heatSysData = ece.Reference.HeatSysData;

            % Obtain Default Value from Reference Table
            obj.DistEffHtg = heatSysData.DefaultDistribEff(...
                heatSysData.SystemType == obj.SystemType);

        end %Setter Function


        function set.HeatEff(obj,value)
            % Setter for HeatEff
            %   Depending on the input value, the value is directly set or
            %   used to pull the default reference value for HeatCool.

            % -- Non-NAN values get directly set.
            if ~isnan(value)
                obj.HeatEff = value;

            else
                % -- Set Value to 0 or Reference
                % Determine Heating/Cooling References
                isHeating = ismember(obj.SystemFunction,...
                    [ece.enum.SystemFunction.HeatingOnly,...
                    ece.enum.SystemFunction.BothHeatingAndCooling]);

                % Determine Value
                if ~isHeating
                    % No Heating --> 0
                    obj.HeatEff = 0;
                    
                else
                    % Heating --> Get Reference Data
                    % Get Reference Table
                    heatSysData = ece.Reference.HeatSysData;

                    % Obtain Default Value from Reference Table
                    obj.HeatEff = heatSysData.DefaultHeatingEff(...
                        heatSysData.SystemType == obj.SystemType);

                    % Set Default HeatEffUnits
                    obj.HeatEffUnits = heatSysData.EffUnits(...
                        heatSysData.SystemType == obj.SystemType);

                end %endif

            end %endif

            % -- Convert Units
            % If input units is HSPF, convert to COP.


        end %Setter Function


        function set.HeatEffUnits(obj,value)
            % Setter for HEatEffUnits
            %   Depending on the input value, the value is directly set or
            %   used to pull the default reference value for HeatCool.

            % -- Non-NAN values get directly set.
            if ~isempty(value)
                obj.HeatEffUnits = value;

            else
                % -- NAN Values get Default Value from Reference
                % Determine Heating/Cooling References
                isHeating = ismember(obj.SystemFunction,...
                    [ece.enum.SystemFunction.HeatingOnly,...
                    ece.enum.SystemFunction.BothHeatingAndCooling]);

                % Get Reference Table
                heatSysData = ece.Reference.HeatSysData;

                % Obtain Default Value from Reference Table
                obj.HeatEffUnits = heatSysData.EffUnits(...
                    heatSysData.SystemType == obj.SystemType);

            end %endif




        end %Setter Function


        function set.DistEffClg(obj,value)
            % Setter for DistEffClg
            %   Depending on the input value, the value is directly set or
            %   used to pull the default reference value for HeatCool.

            % -- Non-NAN values get directly set.
            if ~isnan(value)
                obj.DistEffClg = value;
                return;
            end %endif

            % -- Set Value to 0 if No Cooling
            % Determine Heating/Cooling References
            isCooling = ismember(obj.SystemFunction,...
                [ece.enum.SystemFunction.CoolingOnly,...
                ece.enum.SystemFunction.BothHeatingAndCooling]);
            
            if ~isCooling
                obj.DistEffClg = 0;
                return;
            end %endif

            % -- Get Reference Value 
            % Get Reference Table
            coolSysData = ece.Reference.CoolSysData;

            % Obtain Default Value from Reference Table
            obj.DistEffClg = coolSysData.DefaultDistribEff(...
                coolSysData.SystemType == obj.SystemType);

        end %Setter Function


        function set.CoolEff(obj,value)
            % Setter for CoolEff
            %   Depending on the input value, the value is directly set or
            %   used to pull the default reference value for HeatCool.

            % -- Non-NAN values get directly set.
            if ~isnan(value)
                obj.CoolEff = value;

            else
                % -- Set Value to 0 Or Reference
                % Determine Heating/Cooling References
                isCooling = ismember(obj.SystemFunction,...
                    [ece.enum.SystemFunction.CoolingOnly,...
                    ece.enum.SystemFunction.BothHeatingAndCooling]);
             
                % Determine Cooling Value
                if ~isCooling
                    % No Cooling --> 0
                    obj.CoolEff = 0;

                else
                    % Cooling --> Get Reference Value
                    % Get Reference Table
                    coolSysData = ece.Reference.CoolSysData;
        
                    % Obtain Default Value from Reference Table
                    obj.CoolEff = coolSysData.DefaultCoolingEff(...
                        coolSysData.SystemType == obj.SystemType);

                    % Set Default CoolEffUnits
                    obj.CoolEffUnits = coolSysData.EffUnits(...
                        coolSysData.SystemType == obj.SystemType);

                end %endif

            end %endif



        end %Setter Function


        function set.CoolEffUnits(obj,value)
            % Setter for CoolEffUnits
            %   Depending on the input value, the value is directly set or
            %   used to pull the default reference value for HeatCool.

            % -- Non-Empty values get directly set.
            if ~isempty(value)
                obj.CoolEffUnits = value;

            else
                % -- NAN Values get Default Value from Reference
                % Determine Heating/Cooling References
                isCooling = ismember(obj.SystemFunction,...
                    [ece.enum.SystemFunction.CoolingOnly,...
                    ece.enum.SystemFunction.BothHeatingAndCooling]);

                % Get Reference Table
                coolSysData = ece.Reference.CoolSysData;

                % Obtain Default Value from Reference Table
                obj.CoolEffUnits = coolSysData.EffUnits(...
                    coolSysData.SystemType == obj.SystemType);

            end %endif

  
        end %Setter Function


    end % end method block

    methods(Access = public, Static)
        HeatCoolArr = readSourceData(fileName);
    end %methods (Access = public)


    methods

        %Declaring the method to calculate the coefficients for the heating and cooling
        %curves for the various equipments
        [EffCurveHtg, EffCurveClg] = calculateEfficiencies(obj);


    end   % method


end  % classdef
