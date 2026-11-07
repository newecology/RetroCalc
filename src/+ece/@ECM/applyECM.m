function applyECM(obj,bldg)
%APPLYECM Method the applies the changes within the ECM to a provided
%Building to create an updated Building copy.
%   To apply an ECM, each component MeasureComponent object is applied to
%   the input Building object. This method essentially calls the
%   APPLYMEASURE method for each MeasureComponent objects in the ECM on the
%   Building.
%
%   Snapshot semantics for Object# MCs: index-based Edit/Delete MCs are
%   resolved to specific object handles at ECM entry (i.e. against the
%   pristine collection as the user sees it in the UI). This prevents the
%   "index shift" bug where MC N's Object# refers to a different object
%   than the user labeled because earlier MCs already removed items and
%   the array shifted underneath. Filter-mode MCs are unchanged and still
%   re-evaluate against the live post-previous-MC state.


%% Arguments Block
arguments
    % obj: Self-referential ECM object.
    obj (1,1) ece.ECM

    % building: Building object that ECM is applied to.
    bldg (1,1) ece.Building

end %argblock

%% Snapshot Object# targets at ECM entry
% For each Edit/Delete MC that uses Object#-based filter criteria, resolve
% the indices to actual object handles NOW (before any MC has run). Store
% them per-MC so applyMeasure can operate on handles rather than indices.
snapshots = cell(obj.NumComponents,1);
for mcIdx = 1:obj.NumComponents
    mc = obj.MeasureComponents(mcIdx);

    op = lower(mc.Operation);
    if ~(op == "edit" || op == "delete")
        continue
    end
    fc = mc.FilterCriteria;
    if ismissing(fc) || strlength(fc) == 0
        continue
    end
    if ~contains(fc, "Object#")
        continue
    end
    if strcmp(mc.ObjectOfReference,"Building")
        continue   % Building itself isn't an array — Object# doesn't apply
    end

    collection = bldg.(mc.ObjectVarName);
    if isempty(collection)
        continue
    end

    digitStrs = extract(string(fc), digitsPattern);
    indicNums = str2double(digitStrs);
    % Filter out (rather than clip) out-of-range indices — clipping silently
    % targeted the boundary element, which is worse than skipping.
    validMask = ~isnan(indicNums) & indicNums >= 1 & indicNums <= numel(collection);
    if ~any(validMask)
        continue
    end
    snapshots{mcIdx} = collection(indicNums(validMask));
end

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
    % Apply current MC to the input Building, passing pre-resolved handle
    % targets when the MC is Object#-based (empty otherwise → applyMeasure
    % takes its existing parse-from-FilterCriteria path).
    currentMC.applyMeasure(bldg, snapshots{mcIdx});

    % No need to make a copy of the resultant Building, because all MC's
    % within an ECM should be impacting the single Building reference in
    % the ECM and do not need to carry their own Building reference copy.

end %forloop

end %function
