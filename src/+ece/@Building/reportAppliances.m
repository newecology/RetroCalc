% Displays appliance usage and internal gain report
function reportAppliances(obj)
      disp("Appliance energy usage by appliance type")
      disp(obj.ApplianceResultsTable)
      disp("Appliance monthly energy table")
      disp(obj.ApplianceEnergyTable12)
end
