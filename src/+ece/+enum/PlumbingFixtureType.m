classdef PlumbingFixtureType < ece.enum.BaseList
    % Plumbing fixture type enumeration class 
        
    enumeration
        Toilets ("Toilets")

        Urinals ("Urinals")

        BathroomSink ("Bathroom Sink")

        KitchenSink ("Kitchen Sink")

        Shower ("Shower")

        InUnitDishwasher ("In-Unit Dishwasher")

        InUnitClotheswasher ("In-Unit Clothes Washer")

        CommonAreaClotheswasher ("Common Area Clothes Washer")

        CommercialKitchenSink ("Commercial Kitchen Sink")

        CommercialDishwasher ("Commercial Dishwasher")

        Irrigation ("Irrigation")

        CoolingTower ("Cooling Tower")

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
