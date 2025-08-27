classdef HEAPlotType < ece.enum.BaseList
    % HEAPlotType Enumeration class for the different types of
    % Graph/Plots that can be displayed in HEA Summary window.

    enumeration
        TotalMonthlyGasUsage        ("Total Monthly Gas Usage")
        TotalMonthlyElectricUsage   ("Total Monthly Electric Usage")
        TotalMonthlyWaterUsage      ("Total Monthly Water Usage")
        TotalMonthlyOilUsage        ("Total Monthly Oil Usage")
        TotalMonthlyPropaneUsage    ("Total Monthly Propane Usage")
        TotalBaseloadUsage          ("Total Baseload Usage")
        %HeatingVsHDD65              ("Heating Usage vs HDD65")
        %CoolingVsCDD70              ("Cooling Usage vs CDD70")
        %WaterTotalVsNonRes          ("Total vs. Nonresidential Water Usage")
        GasUsageBreakdown           ("Gas Usage by Component")
        ElectricUsageBreakdown      ("Electric Usage by Component")
        WaterUsageBreakdown         ("Water Usage by Component")
        OilUsageBreakdown           ("Oil Usage by Component")
        PropaneUsageBreakdown       ("Propane Usage by Component")
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

    end %methods

end %classdef
