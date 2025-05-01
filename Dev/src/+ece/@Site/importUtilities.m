function importUtilities(site, dataSource)
%IMPORTUTILITIES Method to import Utility objects into the Site properties.
%   This method will take the input data source that contains the utility
%   information and convert it into the arrays of Utility objects.
% Note: This method may need to be enhanced as different input Data Sources
% are made available. As of 3/4/2025, we only handle EXCEL inputs.

%% Arguments Block
% Validate input arguments.
arguments
    % site: Self-referential Site object.
    site (1,1) ece.Site

    % dataSource: Input data source that contains the partitionable
    % information that creates Utility objects.
    dataSource (1,1) string

end %argblock

%% Import Electricity Utilities
% Pass the data source into the constructor for Electricity utilities to
% generate the array of Elec utils.
site.ElectricMeters = ece.Electricity.fromUtilityExcelFile(dataSource);

%% Import Gas Utilities
% Pass the data source into the constructor for Gas utilities to
% generate the array of Gas utils.
site.GasMeters = ece.Gas.fromUtilityExcelFile(dataSource);

%% Import Water Utilities
% Pass the data source into the constructor for Water utilities to generate
% the array of Water utils.
site.WaterMeters = ece.Water.fromUtilityExcelFile(dataSource);

end %function

