function [soilConductivityTbl] = ReadSoilConductivityData(fileName)

% read table of soil conductivity values corresponding to wet, dry, typical
% soil et. Also R value of uninsulated concrete wall or slab (assume 8
% inches - very close for other thicknesses)
soilConductivityTbl = readtable(fileName,'Sheet','BGsurfaces','Range','A11:C17');
soilConductivityTbl.soilType = string(soilConductivityTbl.soilType);
soilConductivityTbl.units = string(soilConductivityTbl.units);

end  %function end statement