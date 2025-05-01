function [SpaceTypeDataTbl] = ReadSpaceTypeData(fileName)

% read table of soil conductivity values corresponding to wet, dry, typical
% soil et. Also R value of uninsulated concrete wall or slab (assume 8
% inches - very close for other thicknesses)
SpaceTypeDataTbl = readtable(fileName,'Sheet','spaces','Range','A2:I25');
SpaceTypeDataTbl.SpaceType = string(SpaceTypeDataTbl.SpaceType);

%this command not working. why?
SpaceTypeDataTbl(SpaceTypeDataTbl.SpaceType == "" , :) = [];

end  %function end statement