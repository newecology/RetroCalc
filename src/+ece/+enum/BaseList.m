classdef (Abstract) BaseList
% Implements the base capabilities for hpw enumerations that are a list of
% choices for the user.


    %% Properties
    properties (Transient, SetAccess = 'immutable')

        % The display name to show in a dropdown, etc.
        DisplayName (1,1) string

    end %properties


    %% Constructor
    methods 
        
        function obj = BaseList(dispName)

            arguments
                dispName (1,1) string
            end

            % Store inputs
            obj.DisplayName = dispName;

        end % function

    end %methods


    %% Public Methods
    methods

        function out = toCategorical(obj)
            % Returns an array of categoricals for the given enumerations

            [~,catNames] = enumeration(obj);
            catNames = string(catNames);
            out = categorical(string(obj), catNames);

        end %function


        function out = toDisplayName(obj)
            % Returns an array of display names for the given enumerations

            out = reshape([obj.DisplayName], size(obj));

        end %function


        function out = toDisplayNameCategorical(obj)
            % Returns an array of display names for the given enumerations

            out = reshape([obj.DisplayName], size(obj));
            displayNames = ece.enum.BaseList.classToDisplayNames(class(obj));
            out = categorical(out, displayNames);

        end %function

    end %methods


    %% Hidden Static Methods
    methods (Static, Hidden)

        function [displayNames, enums] = classToDisplayNames(classPath)
            % Gets the array of DisplayName for the given enumeration
            % classname
            
            arguments (Input)
                
                % Enumeration class path
                classPath (1,1) string

            end %arguments

            arguments (Output)
                
                % Display names
                displayNames (:,1) string
                
                % Enumerations
                enums ece.enum.BaseList

            end %arguments

            % Get the enumeration members
            enums = enumeration(classPath);

            % Get the DisplayName array for these enumerations
            displayNames = vertcat(enums.DisplayName);

        end %function


        function enumsOut = stringToEnums(classPath, displayNamesIn)
            % Converts an array of display names to enumeration members
            arguments (Input)
                
                % Enumeration class path
                classPath (1,1) string
                
                % Display names input
                displayNamesIn string

            end %arguments

            arguments (Output)
                
                % Enumerations
                enumsOut ece.enum.BaseList

            end %arguments

            % Get the enumeration info
            [displayNames, enums] = ...
                ece.enum.BaseList.classToDisplayNames(classPath);

            % Preallocate outputs
            enumsOut = repmat(enums(1), size(displayNamesIn));

            % Match the input names
            [isFound, foundIdx] = ismember(displayNamesIn, displayNames);

            % Populate the enums that match
            enumsOut(isFound) = enums(foundIdx(isFound));

        end %function
        
    end %methods

end %classdef