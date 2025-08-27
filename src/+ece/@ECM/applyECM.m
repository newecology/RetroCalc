function applyECM(obj,bldg)
%APPLYECM Method the applies the changes within the ECM to a provided 
%Building to create an updated Building copy.
%   To apply an ECM, each component MeasureComponent object is applied to
%   the input Building object. This method essentially calls the 
%   APPLYMEASURE method for each MeasureComponent objects in the ECM on the
%   Building.


%% Arguments Block
arguments
    % obj: Self-referential ECM object.
    obj (1,1) ece.ECM

    % building: Building object that ECM is applied to.
    bldg (1,1) ece.Building

end %argblock

%% Apply ECM's MeasureComponents to Buildings
% Iteratively apply each MC in the ECM to the provided Building. Each
% subsequent MC is applied to a version of the input Building with all
% previous MCs applied to it.

% Note: It is intended that the building a single ECM applies to should
% be the same reference for all included MeasureComponents.

% Loop operation on each MeasureComponent objects
for mcIdx = 1:(obj.NumComponents)
    % -- Prepare MeasureComponent
    % Get reference to MeasureComponent
    currentMC = obj.MeasureComponents(mcIdx);
    
    % -- Apply MeasureComponent
    % Apply current MC to the input Building.
    currentMC.applyMeasure(bldg);

    % No need to make a copy of the resultant Building, because all MC's
    % within an ECM should be impacting the single Building reference in
    % the ECM and do not need to carry their own Building reference copy.
    
end %forloop

end %function