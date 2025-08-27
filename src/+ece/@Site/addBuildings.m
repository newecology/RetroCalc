function addBuildings(site,bldgs)
%ADDBUILDINGS Method to add Buildings to the Building array in Site.
%   This method is a helper method to add Buildings to object collection
%   array in Site. In addition to adding to the Building, this will also
%   flow down any properties from Site that are mirrored within Building.

%% Arguments Block
% Validate input arguments.
arguments
    % site: Self-referential Site object.
    site (1,1) ece.Site

    % bldgs: Array collection of Building objects to be added to Site.
    bldgs (:,1) ece.Building

end %argblock

%% Populate Building Properties from Site  
% Pipe in any properties from Site that are copied in to Building.
% Compute number of Buildings
numBuildings = length(bldgs);

% Iteratively Update Building Properties
for bldgIdx = 1:numBuildings
    % Pipe properties from Site to Building.
    % Location
    bldgs(bldgIdx).Location = site.Location;

    % CO2 to Electric Ratio
    bldgs(bldgIdx).CarbonEqValueElectricity_kgPerkWh = ...
        site.CarbonEqValueElectricity_kgPerkWh;
    
    % CO2 to Gas Therms Ratio
    bldgs(bldgIdx).CarbonEqValueGas_kgPerTherm = ...
        site.CarbonEqValueGas_kgPerTherm;

    % CO2 to Oil Gallons Ratio
    bldgs(bldgIdx).CarbonEqValueOil_kgPerGallon = ...
        site.CarbonEqValueOil_kgPerGallon;    

    % CO2 to Propane Gallons Ratio
    bldgs(bldgIdx).CarbonEqValuePropane_kgPerGallon = ...
        site.CarbonEqValuePropane_kgPerGallon;    

end %forloop

%% Assign Buildings to Site
% Append Buildings Array to Site Array to concatenate Buildings.
site.Buildings = [site.Buildings;bldgs];


end %function

