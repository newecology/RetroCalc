function removePackages(obj,packageIdxs)
%REMOVEPACKAGES Method to remove Packages from the Package array in 
%Building.
%   This method is a helper method to remove Packages from object 
%   collection array in Building by index.

%% Arguments Block
% Validate input arguments.
arguments
    % obj: Self-referential Building object.
    obj (1,1) ece.Building

    % PackageIdxs: Array collection of indices of Packages objects to 
    % remove from Building Package collection.
    packageIdxs (:,1) double

end %argblock

%% Remove Packages from Building
% Remove Packages from array in Building at provided Package Idxs.
obj.Packages(packageIdxs) = [];

end %function

