function removeBuildings(site,bldgIdxs)
%REMOVEBUILDINGS Method to remove Buildings from the Building array in Site.
%   This method is a helper method to remove Buildings from object collection
%   array in Site by index(es).

%% Arguments Block
% Validate input arguments.
arguments
    % site: Self-referential Site object.
    site (1,1) ece.Site

    % bldgIdx: Array of indices to remove Buildings from.
    bldgIdxs (:,1) double

end %argblock

%% Remove Buildings from Site Array
% Remove specified buildings from the site by index.
site.Buildings(bldgIdxs) = []; 


end %function

