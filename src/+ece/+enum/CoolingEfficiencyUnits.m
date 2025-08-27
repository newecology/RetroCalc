classdef CoolingEfficiencyUnits < ece.enum.BaseList
      enumeration
     
        EER             ("Energy Efficiency Ratio - 95Fdb")
        EER2            ("Energy Efficiency Ratio 2 - 95Fdb")
        SEER            ("Seasonal Energy Efficiency Ratio")
        SEER2           ("Seasonal Energy Efficiency Ratio 2")
        IEER            ("Integrated Energy Efficiency Ratio")
        IPLV            ("Integrated Part Load Value as COP")
        averageCOP      ("Seasonal Average COP")
        ASHP_COP95F     ("COP at 95F Drybulb Outdoor Air Temperature")
        NA              ("N/A")

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