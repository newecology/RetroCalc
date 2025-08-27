 % Displays all summary reports (water, appliance, energy)
 function bldg=reportSummary(obj)
            obj.reportWater();
            obj.reportAppliances();
            obj.reportEnergy();
 end
