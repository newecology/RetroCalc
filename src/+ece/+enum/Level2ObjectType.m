classdef Level2ObjectType < ece.enum.BaseList
    %LEVEL2OBJECTTYPE Enumeration class for the types of objects that can
    %be added to a Building that are used for Level 2 Analysis (and also
    %calibration.)
    %   These Object Types should match to defined object classes within
    %   the +ece folder. This enumeration class is intended to be used in
    %   conjunction with the Level2ObjectOrganizerPanel custom component to
    %   generalize which things can be input into the panel, so the single
    %   component can reference multiple objects.
    
    enumeration
        
        AirMover                ("Air Mover")
        Appliance               ("Appliance")
        BelowGradeSurface       ("Below Grade Surface")
        DHWPipesMechRoom        ("DHW Pipes Mech Room")
        DHWSystem               ("DHW System")
        DHWTank                 ("DHW Tank")
        Glazing                 ("Glazing")
        HeatCool                ("Heat/Cool")
        OpaqueSurface           ("Opaque Surface")
        PlumbingFixture         ("Plumbing Fixture")
        Pump                    ("Pump")
        SlabOnGrade             ("Slab On Grade")
        %Solar                  ("Solar")
        Space                   ("Space")

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
