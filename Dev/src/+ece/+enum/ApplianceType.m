classdef ApplianceType < ece.enum.BaseList
    % Appliance type enumeration class 
        
    enumeration
      
        InUnitGasStoves ("InUnitGasStoves")

        InUnitElectricStoves ("InUnitElectricStoves")

        InUnitDishwashers ("InUnitDishwashers")

        InUnitClotheswashers ("InUnitClotheswashers")

        InUnitGasClothesDryers ("InUnitGasClothesDryers")

        InUnitElectricClothesDryers ("InUnitElectricClothesDryers")

        Refrigerators ("Refrigerators")

        CommonAreaClotheswashers ("CommonAreaClotheswashers")

        CommonAreaGasClothesDryers ("CommonAreaGasClothesDryers")

        CommonAreaElectricClothesDryers ("CommonAreaElectricClothesDryers")

        CommercialDishwashers ("CommercialDishwashers")

        CommercialOvenElectric ("CommercialOvenElectric")

        CommercialGriddleElectric ("CommercialGriddleElectric")

        None ("None")
        
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
