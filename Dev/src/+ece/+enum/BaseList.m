classdef (Abstract) BaseList
    % Base enumeration class for a choice list (dropdown control, etc.)
    
    %% Properties
    properties (Transient, SetAccess = 'immutable')

        % The display name to show in a dropdown, etc.
        DisplayName (1,1) string

    end


    %% Constructor
    methods

        function obj = BaseList(dispName)
            % Construct an instance of the BaseList subclass object.
            obj.DisplayName = dispName;
        end %function

    end %methods


    %% Static Methods
    methods (Static)

        % Generates the string array of display names
        displayNames = getDisplayList()
        % This must be implemented in the concrete class, because it needs
        % to provide the name of that class to get the list

    end %methods


end %classdef
