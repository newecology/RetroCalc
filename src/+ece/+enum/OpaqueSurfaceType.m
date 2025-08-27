classdef OpaqueSurfaceType < ece.enum.BaseList
    % OpaqueSurfaceType Enumeration class for the types of opaque surfaces
        
    enumeration
        % Wall - vertical opaque wall.
        Wall ("Wall")

        % Roof - roof section that is insulated and therefore makes up the thermal 
        % boundary of the building. If it is a sloped roof then the azimuth
        % is needed.
        Roof ("Roof")

        % AtticFloor - insulated attic floor that makes up the primary thermal boundary 
        % of the building, and is therefore entered instead of the roof.
        AtticFloor ("AtticFloor")
        
        % Door - opaque door. Glazed doors are entered under glazed
        % surfaces.
        Door ("Door")
        
        % OverhangingFloor - horizontal section of floor that is cantilevered
        % or overhanging, i.e. exposed to the outside.
        OverhangingFloor ("OverhangingFloor")

        % Adiabatic - any surface that meets a conditioned space and is 
        % therefore assumed to be adiabatic, such as the side walls of a row
        % house.
        Adiabatic ("Adiabatic")

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
