classdef Level2PlotType < ece.enum.BaseList
    % Level2PlotType Enumeration class for the different types of
    % Graph/Plots that can be displayed in Level2Calibration window.

    enumeration
        ActualVsModelGasUsage           ("Comparative Gas Usage")
        ActualVsModelElectricUsage      ("Comparative Electric Usage")
        ActualVsModelWaterUsage         ("Comparative Water Usage")
        ActualVsModelOilUsage           ("Comparative Oil Usage")
        ActualVsModelPropaneUsage       ("Comparative Propane Usage")
        ElectricComponentContribution   ("Electric Contribution")
        GasComponentContribution        ("Gas Contribution")
        %SpaceHeatingBySystem            ("Space Heating")
        %SpaceCoolingBySystem            ("Space Cooling")
        %DHWEnergyBySystem               ("DHW Energy")
        BuildingEnvelopeHeatLoss        ("Building Envelope Heat Loss")
        InternalGainsBreakdown          ("Internal Gains Breakdown")
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
