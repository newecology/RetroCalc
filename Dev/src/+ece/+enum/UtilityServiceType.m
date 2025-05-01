classdef UtilityServiceType < ece.enum.BaseList
    %UTILITYSERVICETYPE Enumeration class for the types of meters that are 
    % used to track a utility's usage.
    %   Utilities can serve different things. Dwellings, non-dwellings.
    
    enumeration
        % Dwelling - metered in occupied areas.
        Dwelling ("Dwelling")

        % Other - serves Halls, Basement, Mechanicals, etc.
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

        end %function

        function serviceType = fromNumber(number)
            % Getter method that will map a number to a corresponding
            % enumeration class member.

            % Get all enumeration members
            serviceEnums = enumeration("ece.enum.UtilityServiceType");

            % Validate input into an output.
            if number >= 1 && number <= numel(serviceEnums)
                % Return selected service type.
                serviceType = serviceEnums(number);

            else
                % Number out of range, return error.
                error("Invalid number. No corresponding " + ...
                    "UtilityServiceType found.");
            end %endif

        end %function

    end %methods

end %classdef
