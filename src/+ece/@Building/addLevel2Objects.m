function addLevel2Objects(bldg,level2Objs)
%ADDLEVEL2OBJECTS Method to add Level2Objs of a specific tpe to the
%corresponding array in Building.
%   This method is a helper method to add Level2Objs to object collection
%   array in Building. It will place the object into the correct array 
%   based on its exact class type.

%% Arguments Block
% Validate input arguments.
arguments
    % bldg: Self-referential Biulding object.
    bldg (1,1) ece.Building

    % level2Objs: Array collection of specific objects to be added to
    % Building, to be validated with switch case below.
    level2Objs (:,1) 

end %argblock

%% Obtain the # of Incoming Objects
% Get length of incoming object.
numObjs = numel(level2Objs);

%% Assign Level2Obj to Corresponding Building Object Array
% Switch by object class to ensure they are placed in the correct array.
switch class(level2Objs)
    case "ece.Airmovers"
        % Append Airmovers to Building
        bldg.Airmovers = [bldg.Airmovers;level2Objs];

    case "ece.Appliance"
        bldg.Appliances = [bldg.Appliances;level2Objs];

    case "ece.BelowGradeSurface"
        % Append BelowGradeSurface to Building
        % Map Building's Location property to incoming BGSurfaces Location
        for objIdx = 1:numObjs
            % Map bldg's Location ref to new object reference.
            level2Objs(objIdx).Location = bldg.Location;
        end %forloop

        % Add BG Surfaces to Building Array
        bldg.BelowGradeSurfaces = [bldg.BelowGradeSurfaces;level2Objs];

    case "ece.DHWpipesMechRoom"
        % Append DHWPipesMechRoom to Building
        bldg.DHWpipesMechRoom = [bldg.DHWpipesMechRoom;level2Objs];

    case "ece.DHWsystem"
        % Append DHWSystem to Building
        bldg.DHWsystems = [bldg.DHWsystems;level2Objs];

    case "ece.DHWtanks"
        % Append DHWtanks to Building
        bldg.DHWtanks= [bldg.DHWtanks;level2Objs];

    case "ece.Glazing"
        % Append Glazing to Building
        bldg.GlazedSurfaces = [bldg.GlazedSurfaces;level2Objs];

    case "ece.HeatCool"
        % Append HeatCool to Building
        bldg.HeatCool = [bldg.HeatCool;level2Objs];

    case "ece.OpaqueSurface"
        % Append Opaque Surfaces to Building
        bldg.OpaqueSurfaces = [bldg.OpaqueSurfaces;level2Objs];

    case "ece.PlumbingFixture"
        % Append Plumbing Fixtures to Building
        bldg.PlumbingFixtures = [bldg.PlumbingFixtures;level2Objs];

    case "ece.Pump"
        % Append Pumps to Building
        bldg.Pumps = [bldg.Pumps;level2Objs];

    case "ece.SlabOnGrade"
        % Append Slab On Grades to Building
        bldg.SlabOnGrade = [bldg.SlabOnGrade;level2Objs];

    %case "ece.Solar"
        % Append Airmovers to Building
        % TODO: Check with New Ecology

    case "ece.Space"
        % Append Spaces to Building
        bldg.Spaces = [bldg.Spaces;level2Objs];

    otherwise
        % Throw an error that traps an unhandled object type.
        error('Unhandled Level2Obj type: %s', class(level2Objs));

end %switch/case


end %function

