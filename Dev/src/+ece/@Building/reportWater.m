
function reportWater(obj)
% Displays water usage summary report
disp("Monthly water usage for each type of plumbing fixture or appliance")
disp("Includes water used for irrigation and cooling towers")
disp(obj.WaterUsageTable)
disp(obj.DHWenergyUsageTable)
disp(obj.DHWfuelTable)

end