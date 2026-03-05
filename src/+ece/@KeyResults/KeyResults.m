classdef KeyResults 
    %KEYRESULTS Class to describe a set of key results from an analysis.
    %   The KeyResults object contains a set of properties that are 
    %   computed from an associated Building/Site. These KeyResults are 
    %   common between the HEA (Historical Energy Analysis) and Level2 
    %   calculation results. Since they are the same, they can be compared.
       
    properties (GetAccess = public, SetAccess = public)
        % Electricity_kWh: Electricity usage in kWh.
        Electricity_kWh (1,1) double

        % Gas_therms: Annual gas usage in therms.
        Gas_therms (1,1) double

        % Water_gallons: Annual water usage in gallons.
        Water_gallons (1,1) double

        % Oil_Gallons: Annual Oil USage in gallons
        Oil_gallons (1,1) double

        %Propane_gallons: Annual Propane usage in gallons
        Propane_gallons (1,1) double

        % EUI: Energy use index.
        EUI (1,1) double

        % AnnualCostOfElectricity: Annual cost of electricity.
        AnnualCostOfElectricity (1,1) double

        % UnitCostOfElectricity: Dollar per kWh cost of electric.
        UnitCostOfElectricity (1,1) double
        
        % AnnualCostOfGas: Annual cost of gas.
        AnnualCostOfGas (1,1) double

        % UnitCostOfGas: Dollar per therm cost of gas.
        UnitCostOfGas (1,1) double

        % AnnualCostOfWater: Annual cost of water.
        AnnualCostOfWater (1,1) double

        % Unit Cost of Water: Dollar per gallon cost of water.
        UnitCostOfWater (1,1) double

        % AnnualCostOfOil: Annual cost of Oil.
        AnnualCostOfOil (1,1) double

        % Unit Cost of Oil: Dollar per gallon cost of Oil.
        UnitCostOfOil (1,1) double

        % AnnualCostOfPropane: Annual cost of Propane.
        AnnualCostOfPropane (1,1) double

        % Unit Cost of Propane: Dollar per gallon cost of Propane.
        UnitCostOfPropane (1,1) double

        % AnnualCostTotal: Total cost of all Utilities combined.
        AnnualCostTotal (1,1) double        

        % CO2e: Total use of CO2 equivalent in kg.
        CO2e (1,1) double

        % WaterResidential_gallons: Annual residential water use in 
        % gallons.
        WaterResidential_gallons (1,1) double

        % WaterNonResidential_gallons: Annual non-residential water use in
        % gallons.
        WaterNonResidential_gallons (1,1) double

        % Water residential gallons per day per bedroom.
        Water_GPDBedroom (1,1) double

        % SpaceHeat_kWh: Annual space heat kWh usage.
        SpaceHeat_kWh (1,1) double

        % SpaceHeatFuel_therms: Annual space heat fuel usage in therms.
        SpaceHeatGas_therms (1,1) double

        % SpaceHeatOil_kBtu: Annual space heat oil usage in kBtu
        % This usage is in kBtu instead of gallons because there are
        % different types of oil with different Btu content, so the space
        % heating and DHW oil energy is in kBtu.
        SpaceHeatOil_kBtu (1,1) double

        % SpaceHeatPropane_gallons: Annual space heat oil usage in gallons
        SpaceHeatPropane_gallons (1,1) double

        % SpaceHeat_kBtuFt2: Annual space heat in kBtu per sq. ft.
        SpaceHeat_kBtuFt2 (1,1) double

        % Space cooling kWh. Annual space cooling in kWh.
        SpaceCool_kWh (1,1) double

        % SpaceCool_kBtuFt2: Annual space cooling in kBtu per sq.ft 
        % (electricity only).
        % Space cooling by energy sources other than electricity (such as
        % gas or district steam) is not provided for at this time.
        SpaceCool_kBtuFt2 (1,1) double

        % DHW_kHw: Domestic hot water usage in kWh. (TODO: This seems to
        % need to be set later by something else outside HEA).
        DHW_kWh (1,1) double

        % DHWGas_therms: Domestic hot water usage in therms for gas.
        DHWGas_therms (1,1) double

        % DHWOil_kBtu: Domestic hot water usage in kBtu for Oil.
        DHWOil_kBtu (1,1) double

        % DHWPropane_kBtu: Domestic hot water usage in Gallons for Propane.
        DHWPropane_gallons (1,1) double

        % DHW_kBtuFt2: Domestic hot water usage in kBtu per sqft for
        % electricity, gas, and propane.
        DHW_kBtuFt2 (1,1) double

        % NonHVACelec_kBtuFt2: NonHVAC electricity usage in kbtu per sqft.
        % Electricity that is not used for heating or cooling. It is used
        % for lights, plug loads, appliances, fans, and pumps.
        NonHVACelec_kBtuFt2 (1,1) double

        % ApplianceFuel_Therms: Fuel usage for appliances in Therms.
        % Includes natural gas and propane used for cooking and clothes drying.
        % Does not include heating of domestic hot water   
        ApplianceFuel_Therms (1,1) double
        

        % ApplianceFuel_kBtu: Fuel usage for appliances in kBtu/ft2.
        % Includes natural gas and propane used for cooking and clothes drying.
        % Does not include heating of domestic hot water.
        ApplianceFuel_kBtuFt2 (1,1) double

        % NonHVACelec_kWh: NonHVAC electricity usage in kWh
        NonHVACelec_kWh (1,1) double


    end %properties

    properties (Dependent)
        % ResultsTable: Table of Results, rolling up all property values
        % into a table.
        ResultsTable table

        % DisplayResultsTable: Table of Results, in display form. This
        % means that all numeric values are converted to string.
        DisplayResultsTable table

    end %properties (Dependent)
    
    methods %Internal Methods

        function obj = KeyResults()
            %KEYRESULTS Construct an instance of this class.
            %   A KeyResults object can be created from a Building or Site.

        end %function

        function value = get.ResultsTable(obj)
            % Getter for ResultsTable.
            %   Outputs the properties of the KeyResults object as a 
            %   single-row table for easy visualizations.

            % Create array of properties.
            propArray = [obj.Electricity_kWh, obj.Gas_therms,...
                obj.Water_gallons, obj.Oil_gallons, obj.Propane_gallons, ...
                obj.EUI, obj.AnnualCostOfElectricity, obj.UnitCostOfElectricity, ...
                obj.AnnualCostOfGas, obj.UnitCostOfGas, obj.AnnualCostOfWater, ...
                obj.UnitCostOfWater, obj.AnnualCostOfOil, obj.UnitCostOfOil, ...
                obj.AnnualCostOfPropane, obj.UnitCostOfPropane, obj.AnnualCostTotal,...
                obj.CO2e, obj.WaterResidential_gallons,...
                obj.WaterNonResidential_gallons, obj.Water_GPDBedroom, ...
                obj.SpaceHeat_kWh, obj.SpaceHeatGas_therms, obj.SpaceHeatOil_kBtu,...
                obj.SpaceHeatPropane_gallons, obj.SpaceHeat_kBtuFt2,...
                obj.SpaceCool_kWh, obj.SpaceCool_kBtuFt2, ...
                obj.DHW_kWh, obj.DHWGas_therms, obj.DHWOil_kBtu, ...
                obj.DHWPropane_gallons, obj.DHW_kBtuFt2,...
                obj.NonHVACelec_kBtuFt2,obj.NonHVACelec_kWh, ...
                obj.ApplianceFuel_Therms, obj.ApplianceFuel_kBtuFt2];

            % Create array of table column names.
            tableColNames = ["Electricity (kWh)","Gas (therms)",...
                "Water (gallons)", "Oil (gallons)", "Propane (gallons)", ...
                "EUI", "Cost Electricity", "Unit Cost of Electricity", ...
                "Cost Gas", "Unit Cost of Gas", "Cost Water", "Unit Cost of Water", ...
                "Cost Oil", "Unit Cost of Oil", "Cost Propane", ...
                "Unit Cost of Propane", "Cost Total", "CO2 equivalent", ...
                "Water - Residential (gallons)", "Water - NonResidential (gallons)", ...
                "Water - gallons per day per bedroom", "Space Heat (kWh)",...
                "Space Heat Gas (therms)", "Space Heat Oil (kBtu)", ...
                "Space Heat Propane (gallons)", "Space Heat Energy (kBtuFt2)", ...
                "Space Cooling (kWh)", "Space Cooling (kBtuFt2)", ...
                "DHW (kWh)", "DHW Gas (therms)", "DHW Oil (kBtu)", ...
                "DHW Propane (gallons)", "DHW Energy(kBtuFt2)", ...
                "Non-HVAC Electricity (kBtuFt2)","Non-HVAC Electricity (kWh)","Appliance Fuel(Therms)","Appliance Fuel (kBtuFt2)"];

            % Put Table together for outputs.
            value = table(tableColNames',propArray',...
                'VariableNames',["Property","Value"]);            

        end %function

        function value = get.DisplayResultsTable(obj)
            % Getter for DisplayResultsTable.
            %   Outputs the string-modified vresion of ResultsTable for
            %   display into a UI. Casts all numeric columns to two-decimal
            %   formatted strings.

            % -- Create String Version of ResultsTable
            % Convert numeric portion of table to string and reassign.
            numMatrix = obj.ResultsTable{:,end};
            stringMatrix = compose("%0.2f",numMatrix);

            % Assign Strings back to Table
            strTable = obj.ResultsTable;
            strTable = convertvars(strTable,@isnumeric,"string");
            strTable{:,end} = stringMatrix;

            % Return Output
            value = strTable;

        end %function
        
    end %methods

end %classdef

