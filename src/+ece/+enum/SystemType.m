classdef SystemType < ece.enum.BaseList
      enumeration
     
        condGasBoilerOAreset ("Condensing Gas Boiler with Outdoor Air Reset")
        condGasBoilerNoOAreset ("Condensing Gas Boiler with No Outdoor Air Reset");
        nonCondGasOrOilBoilerOAreset ("Non-condensing Gas/Oil Boiler with Outdoor Air Reset");
        nonCondGasOrOilBoilerNoOAreset ("Non-condensing Gas/Oil Boiler with No Outdoor Air Reset")
        condGasFurnace ("Condensing Gas Furnace");
        nonCondGasOrOilFurnace ("Non-condensing Gas or Oil Furnace");
        ASHPlessThan6TonsDucted ("Air Source Heat Pump < 6 Tons - Ducted");
        ASHPlessThan6TonsNonDucted ("Air Source Heat Pump < 6 Tons - Non-ducted");
        ASHPorVRFgreaterThan6TonsDucted ("Air Source Heat Pump or VRF >=6 Tons Ducted");
        ASHPorVRFgreaterThan6TonsNonDucted ("Air Source Heat Pump or VRF >=6 Tons Non-ducted");
        electricResistance ("Electric Resistance");
        PTACorPTHP ("packaged terminal Air conditioner or Heat Pump");
        waterSourceHeatPump ("Water Source Heat Pump");
        groundSourceHeatPump ("ground Source Heat Pump");
        windowAirConditioner ("Window Air Conditioner")
        waterCooledChiller ("Water-cooled Chiller")
        airCooledChiller ("Air-cooled Chiller")
        all ("All System Types")

    end % enumeration

    % Static Methods
    methods (Static)

        function displayNames = getDisplayList()
            % Generates the string array of display names.
            % Note: Useful for populating dropdownlists, etc.

            classPath = mfilename('class');
            enums = enumeration(classPath);
            displayNames = vertcat(enums.DisplayName);

        end

    end %methods

end %classdef