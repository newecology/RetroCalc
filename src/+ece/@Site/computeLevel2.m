function computeLevel2(site,buildingRef)
%COMPUTELEVEL2 Method to compute the Level2 of a selected Building within the Site.
%   This method creates a Level2 object for each of the component Buildings
%   using the Level2 class static constructor. At the end, the Level2 for 
%   the Site itself is computed as the sum of each buildings' HEA results.

%% Argument Block
arguments
    % site: Self-referencing Site object.
    site (1,1) ece.Site

    % buildingRef: Reference to Building within Site to do Level2 calc on.
    buildingRef (1,1) = [];

end %argblock

%%




end %function

