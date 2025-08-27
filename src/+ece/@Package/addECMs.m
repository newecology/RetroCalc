function addECMs(obj,ecms)
%ADDECMS Method to add ECMs to the ECM array in Package.
%   This method is a helper method to add ECMs to object collection
%   array in Package.

%% Arguments Block
% Validate input arguments.
arguments
    % obj: Self-referential Package object.
    obj (1,1) ece.Package

    % ecms: Array collection of ECM objects to be added to Package.
    ecms (:,1) ece.ECM

end %argblock

%% Assign ECMs to Package
% Determine which ECM being added to Package are unique - can only
% have one of each distinct ECM added to a Package.
newECMs = setdiff(ecms,obj.ECMs);

% Concatenate the new ecms to the ECM array.
obj.ECMs = [obj.ECMs;newECMs];


end %function

