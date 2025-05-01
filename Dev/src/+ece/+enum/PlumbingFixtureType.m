classdef PlumbingFixtureType < ece.enum.BaseList
    % Plumbing fixture type enumeration class 
        
    enumeration
        Toilets ("Toilets")

        Urinals ("Urinals")

        BathroomSink ("BathroomSink")

        KitchenSink ("KitchenSink")

        Shower ("Shower")

        InUnitDishwasher ("InUnitDishwasher")

        InUnitClotheswasher ("InUnitClotheswasher")

        CommonAreaClotheswasher ("CommonAreaClothesWasher")

        CommercialKitchenSink ("CommercialKitchenSink")

        CommercialDishwasher ("CommercialDishwasher")

        Irrigation ("Irrigation")

        CoolingTower ("CoolingTower")

        Other ("Other")

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
