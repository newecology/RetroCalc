function applyPackage(obj,bldg)
%APPLYPACKAGE Method for applying a Package to an input Building.
%  This method applies the Package's ECMs to the input Building for each
%  ECM included the package. 
%  Each ECM will call its own apply method onto the provided building. For
%  all ECMs in a Package, each ECM will be applied to the building
%  resulting in the appliance of the last ECM (for an aggregated change.)

%% Arguments Block
arguments
    % obj: Self-referential Package object.
    obj (1,1) ece.Package

    % building: Building object that Package is applied to.
    bldg (1,1) ece.Building

end %argblock

%% Apply Package's ECMs to Buildings
% Iterative apply each ECM in the Package to the provided Building. Each
% subsequent ECM is applied to a version of the input Building with all
% previous ECMs applied to it.

% Reset ECMBuilding's first Building as direct copy of provided building.
obj.ECMBuildings = bldg;

% Iterate through each ECM in Package.
for ecmIdx = 1:(obj.NumECMs)
    % -- Prepare ECM
    % Get ECM Reference
    currentECM = obj.ECMs(ecmIdx);

    % -- Prepare Building Copy Input
    % Determine which Building to copy as input for current ECM.
    %   A copy is necessary to break reference to base building. By
    %   copying the Building, it is now a distinct reference.
    if (ecmIdx == 1)
        % The first ECM uses the directly input building.
        inputBuilding = obj.ECMBuildings(1);
    else
        % All subsequent ECMs use previous ECMBuilding
        inputBuilding = copy(obj.ECMBuildings(ecmIdx-1));
    end %endif
    
    % -- Apply ECM
    % Apply current ECM to ECMBuilding.
    currentECM.applyECM(inputBuilding);

    % Store Building Reference in Package
    obj.ECMBuildings(ecmIdx) = inputBuilding;

    % Calculate impacts on current ECM
    %impct       = utility.calcImpactOnBuilding(copyBldg,bldg);

    % update current ECM's impact property
    %obj.ECMs(ecmIdx).ImpactOnBuilding= impct;

end %forloop

end %classdef