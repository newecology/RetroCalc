function removeECMs(obj,ecmIdxs)
%REMOVEECMS Method to remove ECMs from the ECM array in Package.
%   This method is a helper method to remove ECMs from object collection
%   array in Package by index.

%% Arguments Block
% Validate input arguments.
arguments
    % obj: Self-referential Package object.
    obj (1,1) ece.Package

    % ecmIdxs: Array collection of indices of ECMs objects to remove from
    % Package ECM collection
    ecmIdxs (:,1) double

end %argblock

%% Remove ECMs from Package
% Remove ECMs from array in Package at provided ECM Idxs.
obj.ECMs(ecmIdxs) = [];

end %function

