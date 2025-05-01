classdef HEA 
    %HEA Class to describe a Historical Energy Analysis (HEA) object.
    %   The HEA object contains a set of properties that are computed from
    %   the associated Building/Site. For each utility in the Building,
    %   there is an annual usage/cost associated with it that is rolled up
    %   by the HEA.
    
    properties (GetAccess = public, SetAccess = public)
        % Electricity_kWh: Electricity usage in kWh.
        Electricity_kWh (1,1) double

        % Gas_therms: Annual gas usage in therms.
        Gas_therms (1,1) double

        % Water_gallons: Annual water usage in gallons.
        Water_gallons (1,1) double

        % EUI: Energy use index.
        EUI (1,1) double

        % CostElectricity: Annual cost of electricity.
        CostElectricity (1,1) double

        % CostGas: Annual cost of gas.
        CostGas (1,1) double

        % CostElectricity: Annual cost of water.
        CostWater (1,1) double

        % CostTotal: Total cost of all Utilities.
        CostTotal (1,1) double

        % CO2: Total use of CO2.
        CO2 (1,1) double

        % WaterResidential_gallons: Annual residential water use in 
        % gallons.
        WaterResidential_gallons (1,1) double

        % WaterNonResidential_gallons: Annual non-residential water use in
        % gallons.
        WaterNonResidential_gallons (1,1) double

        % SpaceHeat_kWh: Annual space heat kWh usage.
        SpaceHeat_kWh (1,1) double

        % SpaceHeatFuel_therms: Annual space heat fuel usage in therms.
        SpaceHeatFuel_therms (1,1) double

        % SpaceHeat_kBtuFt2: Annual space heat in kBtu per sq. ft.
        SpaceHeat_kBtuFt2 (1,1) double

        % SpaceCool_kBtuFt2: Annual space cooling in kBtu per sq.ft.
        SpaceCool_kBtuFt2 (1,1) double

        % DHW_kHw: Domestic hot water usage in kWh. (TODO: This seems to
        % need to be set later by something else outside HEA).
        DHW_kWh (1,1) double

        % DHWFuel_kBtu: Domestic hot water usage in kBtu for fuel.
        DHWFuel_kBtu (1,1) double

        % DHW_kBtuFt2: Domestic hot water usage in kBtu per sqft.
        DHW_kBtuFt2 (1,1) double

        % NonHVAC_kBtuFt2: NonHVAC usage in kbtu per sqft.
        NonHVAC_kBtuFt2 (1,1) double

        % ApplianceFuel_kBtu: Fuel usage for all appliance in kBtu.
        ApplianceFuel_kBtu (1,1) double

    end %properties

    properties (Dependent)
        % ResultsTable: Table of Results, rolling up all property values
        % into a table.
        ResultsTable table

    end %properties (Dependent)
    
    methods %Internal Methods

        function obj = HEA()
            %HEA Construct an instance of this class.
            %   An HEA object can be created from a Building or Site.

        end %function

        function value = get.ResultsTable(obj)
            % Getter for ResultsTable.
            %   Outputs the properties of the HEA object as a single-row
            %   table for easy visualizations.

            % Create array of properties.
            propArray = [obj.Electricity_kWh,obj.Gas_therms,...
                obj.Water_gallons,obj.EUI,obj.CostElectricity,...
                obj.CostGas,obj.CostWater,obj.CostTotal,...
                obj.CO2,obj.WaterResidential_gallons,...
                obj.WaterNonResidential_gallons,obj.SpaceHeat_kWh,...
                obj.SpaceHeatFuel_therms,obj.SpaceHeat_kBtuFt2,...
                obj.SpaceCool_kBtuFt2,obj.DHW_kWh,obj.DHWFuel_kBtu,...
                obj.DHW_kBtuFt2,obj.NonHVAC_kBtuFt2,...
                obj.ApplianceFuel_kBtu];

            % Create array of table column names.
            tableColNames = ["Electricity_kWh","Gas_therms",...
                "Water_gallons","EUI","CostElectricity","CostGas",...
                "CostWater","CostTotal","CO2","WaterResidential_gallons",...
                "WaterNonResidential_gallons","SpaceHeat_kWh",...
                "SpaceHeatFuel_therms","SpaceHeat_kBtuFt2",...
                "SpaceCool_kBtuFt2","DHW_kWh","DHWFuel_kBtu",...
                "DHWFuel_kBtuFt2","NonHVAC_kBtuFt2",...
                "ApplianceFuel_kBtu"];

            % Put Table together for outputs.
            value = array2table(propArray,...
                "VariableNames",tableColNames);            

        end %function
        
    end %methods

end %classdef

