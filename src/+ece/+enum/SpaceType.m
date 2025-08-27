classdef SpaceType < ece.enum.BaseList
    % OpaqueSurfaceType Enumeration class for the types of opaque surfaces
        
    enumeration
        % Residential
        Residential ("Residential")

        % Corridor 
        Corridor ("Corridor")

        % Stairwell_Elevator
        Stairwell_Elevator ("Stairwell_Elevator")
        
        % CommonArea
        CommonArea ("CommonArea")
        
        % Mechanical
        Mechanical ("Mechanical")

        % Office_Lounge
        Office_Lounge ("Office_Lounge")

        % Laundry
        Laundry ("Laundry")

        % Restroom
        Restroom ("Restroom")

        % Fitness
        Fitness ("Fitness")

        % Retail
        Retail ("Retail")

        % Restaurant
        Restaurant ("Restaurant")

        % Theater
        Theater ("Theater")

        % School
        School ("School")

        % Storage
        Storage ("Storage")

        % Unconditioned
        Unconditioned ("Unconditioned")

        % Other
        Other ("Other")


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
