function importBuildings(site, dataSource)
%IMPORTBUILDINGS Method to import Building objects into the Site properties.
%   This method will take the input data source that contains the building
%   information and convert it into the arrays of Building objects.
% Note: This method may need to be enhanced as different input Data Sources
% are made available. As of 3/4/2025, we only handle EXCEL inputs.

%% Arguments Block
% Validate input arguments.
arguments
    % site: Self-referential Site object.
    site (1,1) ece.Site

    % dataSource: Input data source that contains the partitionable
    % information that creates Building objects.
    dataSource (1,1) string

end %argblock

%% Import Building Objects
% Pass the data source into the constructor for Building objects to
% generate the array of Buildings on the site.
site.Buildings = ece.Building.fromBuildingExcelFile(dataSource);


end %function

