classdef RealEstateType < ece.enum.BaseList
    %REALESTATETYPE Enumeration class for the types of real estate a
    %Utility can be associated with.
    %   Utilites can belong to commercial, residential, or other kinds of
    %   real estate. These types are tracked with this enumeration class.
    
    enumeration
        % Residential - residential real estate type.
        Residential ("Residential")
        
        % Commercial - commercial real estate type.
        Commercial ("Commercial")

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

        function estateType = fromNumber(number)
            % Getter method that will map a number to a corresponding
            % enumeration class member.

            % Get all enumeration members
            realEstateEnums = enumeration("ece.enum.RealEstateType");

            % Validate input into an output.
            if number >= 1 && number <= numel(realEstateEnums)
                % Return selected estate type.
                estateType = realEstateEnums(number);

            else
                % Number out of range, return error.
                error("Invalid number. No corresponding " + ...
                    "RealEstateType found.");
            end %endif

        end %function

    end %methods

end %classdef
