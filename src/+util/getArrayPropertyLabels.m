function labels = getArrayPropertyLabels(className, propertyName)
% getArrayPropertyLabels: Returns a per-index label string array for a
% known array-typed property on an ece class. Used by the ECM Creation
% Panel and the Excel ECM workbook builder to annotate indexed dropdown
% entries so users don't have to remember what, e.g., HeatCoolSetpoints(3)
% means.
%
%   labels = util.getArrayPropertyLabels("ece.Building", "HeatCoolSetpoints")
%      → ["HtgTP1 (day)"; "HtgTP2 (night)"; "ClgTP1 (day)";
%         "ClgTP2 (night)"; "ClgRH"; "HtgRH"]
%
% Returns string.empty(0,1) if the className.propertyName pair is not
% registered. Unknown arrays still get expanded in the dropdown as
% "Name(1)", "Name(2)", ... just without the trailing label.
%
% To add a new array property: add a case below and regenerate
% examples/example_ECM_Package.xlsx and
% documentation/ECM_Property_Reference.md if you want them in sync.

    arguments
        className    (1,1) string
        propertyName (1,1) string
    end

    months = ["Jan"; "Feb"; "Mar"; "Apr"; "May"; "Jun"; ...
              "Jul"; "Aug"; "Sep"; "Oct"; "Nov"; "Dec"];

    key = className + "." + propertyName;
    switch key
        % -- Building ---------------------------------------------------
        case "ece.Building.HeatCoolSetpoints"
            labels = ["HtgTP1 (day)"; ...
                      "HtgTP2 (night)"; ...
                      "ClgTP1 (day)"; ...
                      "ClgTP2 (night)"; ...
                      "ClgRH"; ...
                      "HtgRH"];

        case "ece.Building.NumberOfBedroomUnits"
            labels = ["1BR"; "2BR"; "3BR"; "4BR"];

        case "ece.Building.HVACStartEndTimePeriod1"
            labels = ["Period 1 start hour"; "Period 1 end hour"];

        % -- Airmovers --------------------------------------------------
        case "ece.Airmovers.AverageSpeed"
            labels = ["Period 1 (day)"; "Period 2 (night)"];

        case "ece.Airmovers.OperationHoursPerDay"
            labels = ["Period 1 (day)"; "Period 2 (night)"];

        case "ece.Airmovers.OperationMonths"
            labels = ["Start month"; "End month"];

        % -- Pump -------------------------------------------------------
        case "ece.Pump.OperationMonths"
            labels = ["Start month"; "End month"];

        % -- Glazing / OpaqueSurface (monthly shading factors) ----------
        case "ece.Glazing.ShadingMonthly"
            labels = months;

        case "ece.OpaqueSurface.ShadingMonthly"
            labels = months;

        otherwise
            labels = string.empty(0,1);
    end

end
