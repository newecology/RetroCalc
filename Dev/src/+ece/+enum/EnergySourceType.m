classdef EnergySourceType < ece.enum.BaseList
    % OpaqueSurfaceType Enumeration class for the types of opaque surfaces
        
    enumeration
        % Electricity
        Electricity ("Electricity")
        % Gas
        Gas ("Gas")
        % Propane
        Propane ("Propane")
        % Oil
        HeatingOil ("#2 Heating Oil")
        % Wood
        Wood ("Wood")
        % Diesel fuel
        DieselFuel ("Diesel fuel")
        % District steam
        DistricSteam ("District steam")
        % None
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
