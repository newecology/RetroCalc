function removeLevel2Objects(bldg,level2ObjType,removeIdxs)
%REMOVELEVEL2OBJECTS Method to remove Level2Objs from the corresponding 
% object array in Building.
%   This method is a helper method to remove specific Level2 objects from 
%  object collection array in Building by index(es).

%% Arguments Block
% Validate input arguments.
arguments
    % site: Self-referential Building object.
    bldg (1,1) ece.Building

    % level2ObjType: Type of Level 2 Obj to remove.
    level2ObjType (1,1) ece.enum.Level2ObjectType

    % removeIdx: Array of indices to remove object from array.
    removeIdxs (:,1) double

end %argblock

%% Remove Objects from Building Array
% Remove specified objects from the Building by index and corresponding
% Level2ObjType
switch (level2ObjType)
    case (ece.enum.Level2ObjectType.AirMover)
        % -- Remove AirMovers
        bldg.Airmovers(removeIdxs) = [];

    case (ece.enum.Level2ObjectType.Appliance)
        % -- Remove Appliances
        bldg.Appliances(removeIdxs) = [];

    case (ece.enum.Level2ObjectType.BelowGradeSurface)
        % -- Remove BelowGradeSurfaces
        bldg.BelowGradeSurfaces(removeIdxs) = [];

    case (ece.enum.Level2ObjectType.DHWPipesMechRoom)
        % -- Remove DHWPipesMechRooms
        bldg.DHWpipesMechRoom(removeIdxs) = [];

    case (ece.enum.Level2ObjectType.DHWSystem)
        % -- Remove DHWSystem
        bldg.DHWsystems(removeIdxs) = [];
        
    case (ece.enum.Level2ObjectType.DHWTank)
        % -- Remove DHWTank
        bldg.DHWtanks(removeIdxs) = [];

    case (ece.enum.Level2ObjectType.Glazing)
        % -- Remove Glazed Surfaces
        bldg.GlazedSurfaces(removeIdxs) = [];

    case (ece.enum.Level2ObjectType.HeatCool)
        % -- Remove HeatCool
        bldg.HeatCool(removeIdxs) = [];
        
    case (ece.enum.Level2ObjectType.OpaqueSurface)
        % -- Remove Opaque Surfaces
        bldg.OpaqueSurfaces(removeIdxs) = [];

    case (ece.enum.Level2ObjectType.PlumbingFixture)
        % -- Remove Plumbing Fixtures
        bldg.PlumbingFixtures(removeIdxs) = [];

    case (ece.enum.Level2ObjectType.Pump)
        % -- Remove Pump
        bldg.Pumps(removeIdxs) = [];

    case (ece.enum.Level2ObjectType.SlabOnGrade)
        % -- Remove Slabs On Grade
        bldg.SlabOnGrade(removeIdxs) = [];

    case (ece.enum.Level2ObjectType.Space)
        % -- Remove Spaces
        bldg.Spaces(removeIdxs) = [];

    otherwise
        % -- Unhandled Level2Obj Type
        % Throw error that traps an unhandled Level2 object type.
        error('Unhandled Level 2 Object type: %s', level2ObjType);

end %switch/case

end %function

