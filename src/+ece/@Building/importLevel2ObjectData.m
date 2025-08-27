function importLevel2ObjectData(bldg, level2DataFile)
%IMPORTLEVEL2OBJECTDATA Method to import Level2 object data into a Building.
%   This method takes an input excel file that contains all the information
%   about the Level2 object data and populates it into the Building. Each
%   object is created and stored in the corresponding array of objects
%   within the Building in question.

%% Arguments Block
arguments
    % bldg: Reference to Building object.
    bldg (1,1) ece.Building
    % level2DataFile: Name of filepath containing excel data of L2 objects.
    level2DataFile (1,1) string
end %argblock

%% Validated File Path
% Check that the passed in argument corresponds to a real and accessible
% path.
validFile = isfile(level2DataFile);
if ~validFile
    % Throw error that describes issues and returns.
    error("Unable to load Level 2 Building data. Provided file path" + ...
        " ('" + level2DataFile + "') does not exist or is " + ...
        "not a valid file.");
end %endif

%% Import Level 2 Object Data
% With the provided data file, call all the Level2 objects' import methods
% on the file to populate the building's corresponding arrays.
% AirMovers
airMovers = ece.Airmovers.readSourceData(level2DataFile);
bldg.addLevel2Objects(airMovers);

% Pumps
pumps = ece.Pump.readSourceData(level2DataFile);
bldg.addLevel2Objects(pumps);

% OpaqueSurfaces
opaqueSurfaces = ece.OpaqueSurface.readSourceData(level2DataFile);
bldg.addLevel2Objects(opaqueSurfaces);

% GlazedSurfaces
glazedSurfaces = ece.Glazing.readSourceData(level2DataFile);
bldg.addLevel2Objects(glazedSurfaces);

% BelowGradeSurfaces
bgSurfaces = ece.BelowGradeSurface.readSourceData(level2DataFile);
bldg.addLevel2Objects(bgSurfaces);

% SlabOnGrade
slabsOnGrade = ece.SlabOnGrade.readSourceData(level2DataFile);
bldg.addLevel2Objects(slabsOnGrade);

% Spaces
spaces = ece.Space.readSourceData(level2DataFile);
bldg.addLevel2Objects(spaces);

% Appliances
appliances = ece.Appliance.readSourceData(level2DataFile);
bldg.addLevel2Objects(appliances);

% PlumbingFixtures
plumbingFixtures = ece.PlumbingFixture.readSourceData(level2DataFile);
bldg.addLevel2Objects(plumbingFixtures);

% DHWsystems
dhwSystems = ece.DHWsystem.readSourceData(level2DataFile);
bldg.addLevel2Objects(dhwSystems);

% DHWtanks
dhwTanks = ece.DHWtanks.readSourceData(level2DataFile);
bldg.addLevel2Objects(dhwTanks);

% DHWpipesMechRoom
dhwPMRs = ece.DHWpipesMechRoom.readSourceData(level2DataFile);
bldg.addLevel2Objects(dhwPMRs);

% HeatCool
heatCools = ece.HeatCool.readSourceData(level2DataFile);
bldg.addLevel2Objects(heatCools);

end %function

