function addPackages(obj,packages)
%ADDPACKAGES Method to add Packages to the Package array in Building.
%   This method is a helper method to add Packages to object collection
%   array in Building.

%% Arguments Block
% Validate input arguments.
arguments
    % obj: Self-referential Building object.
    obj (1,1) ece.Building

    % Packages: Array collection of Package objects to be added to
    % Building.
    packages (:,1) ece.Package

end %argblock

%% Assign Packages to Building
% Determine which Packages being added to Building are unique - can only
% have one of each distinct package added to a Building.
newPackages = setdiff(packages,obj.Packages);

% Concatenate the new packages to the Package array.
obj.Packages = [obj.Packages;newPackages];

end %function

