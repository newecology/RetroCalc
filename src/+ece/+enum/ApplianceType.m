classdef ApplianceType < ece.enum.BaseList
    % APPLIANCETYPE Enumeration class for the different types of Appliance
    % objects that can exist.

    enumeration
        InUnitGasStoves                     ("In-Unit Gas Stoves")
        InUnitElectricStoves                ("In-Unit Electric Stoves")
        InUnitDishwashers                   ("In-Unit Dishwashers")
        InUnitClotheswashers                ("In-Unit Clotheswashers")
        InUnitGasClothesDryers              ("In-Unit Gas Clothes Dryers")
        InUnitElectricClothesDryers         ("In-Unit Electric Clothes Dryers")
        Refrigerators                       ("Refrigerators")
        CommonAreaClotheswashers            ("Common Area Clotheswashers")
        CommonAreaGasClothesDryers          ("Common Area Gas Clothes Dryers")
        CommonAreaElectricClothesDryers     ("Common Area Electric Clothes Dryers")
        CommercialDishwashers               ("Commercial Dishwashers")
        CommercialOvenElectric              ("Commercial Oven Electric")
        CommercialGriddleElectric           ("Commercial Griddle Electric")
    end % enumeration

    % Static Methods
    methods (Static)

        function displayNames = getDisplayList()
            % Generates the string array of display names.
            % Note: Useful for populating dropdownlists, etc.

            classPath = mfilename('class');
            enums = enumeration(classPath);
            displayNames = vertcat(enums.DisplayName);

        end %function

    end %methods

end %classdef
