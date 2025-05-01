classdef UtilityPayerType < ece.enum.BaseList
    %UTILITYPAYERTYPE Enumeration class for the types of payer for
    %Utility objects.
    %   Depending on the utility and building, certain utilites can be paid
    %   for by the Tenant, Building owner, or some other party.
    
    enumeration
        % Tenant - Utility paid by Tenant/Individual
        Tenant ("Tenant")
        
        % Building - Utility paid by Building Owner/PropManager
        Building ("Building")

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

        function payerType = fromNumber(number)
            % Getter method that will map a number to a corresponding
            % enumeration class member.
            
            % Get all enumeration members
            payerEnums = enumeration("ece.enum.UtilityPayerType");

            % Validate input into an output.
            if number >= 1 && number <= numel(payerEnums)
                % Return selected payer type.
                payerType = payerEnums(number);
    
            else
                % Number out of range, return error.
                error("Invalid number. No corresponding " + ...
                    "UtilityPayerType found.");
            end %endif
            
        end %function

    end %methods

end %classdef
