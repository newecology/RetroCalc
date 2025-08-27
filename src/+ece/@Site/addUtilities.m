function addUtilities(site,utilities)
%ADDUTILITIESS Method to add Utilities to the Utilities array in Site.
%   This method is a helper method to add Utilities to object collection
%   array in Site. It will place the Utility into the correct array based
%   on the concrete class type.

%% Arguments Block
% Validate input arguments.
arguments
    % site: Self-referential Site object.
    site (1,1) ece.Site

    % utilities: Array collection of Utility objects to be added to Site.
    utilities (:,1) ece.Utility

end %argblock

%% Assign Utilities to Corresponding Site Meter Array
% Switch by utility class to ensure they are placed in the correct array.
switch class(utilities)
    case "ece.Electricity"
        % Append Electric Utilities to Site Collection
        site.ElectricMeters = [site.ElectricMeters;utilities];

    case "ece.Water"
        % Append Water Utilities to Site Collection
        site.WaterMeters = [site.WaterMeters; utilities];
        
    case "ece.Gas"
        % Append Gas Utilities to Site Collection
        site.GasMeters = [site.GasMeters; utilities];

    case "ece.Propane"
        % Append Propane Utilities to Site Collection
        site.PropaneMeters = [site.PropaneMeters; utilities];

    case "ece.Oil"
        % Append Oil Utilities to Site Collection
        site.OilMeters = [site.OilMeters; utilities];

    otherwise
        % Throw an error that traps an unhandled object type.
        error('Unhandled utility type: %s', class(utilities));

end %switch/case


end %function

