classdef SystemType < ece.enum.BaseList
      enumeration
     
        condGasBoilerOAreset ("condensing gas boiler with outdoor air reset")
        condGasBoilerNoOAreset ("condensing gas boiler with no outdoor air reset");
        nonCondGasOrOilBoilerOAreset ("non-condensing gas/oil boiler with outdoor air reset");
        nonCondGasOrOilBoilerNoOAreset ("non-condensing gas/oil boiler with no outdoor air reset")
        condGasFurnace ("condensing gas furnace");
        nonCondGasOrOilFurnace ("non-condensing gas or oil furnace");
        ASHPlessThan6TonsDucted ("air source heat pump < 6 tons - ducted");
        ASHPlessThan6TonsNonDucted ("air source heat pump < 6 tons - non-ducted");
        ASHPorVRFgreaterThan6TonsDucted ("air source heat pump or VRF >=6 tons ducted");
        ASHPorVRFgreaterThan6TonsNonDucted ("air source heat pump or VRF >=6 tons non-ducted");
        electricResistance ("electric resistance");
        PTACorPTHP ("packaged terminal air conditioner or heat pump");
        waterSourceHeatPump ("water source heat pump");
        groundSourceHeatPump ("ground source heat pump");
        windowAirConditioner ("window air conditioner")
        waterCooledChiller ("water-cooled chiller")
        airCooledChiller ("air-cooled chiller")
        all ("all system types")

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