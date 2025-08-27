function removeUtilities(site,utilityMeterType,utilityIdxs)
%REMOVEUTILITIES Method to remove Utilities from the corresponding utility
% array in Site.
%   This method is a helper method to remove Utilities from object
%   collection array in Site by index(es).

%% Arguments Block
% Validate input arguments.
arguments
    % site: Self-referential Site object.
    site (1,1) ece.Site

    % utilityMeterType: Type of Utility to remove from.
    utilityMeterType (1,1) ece.enum.UtilityMeterType

    % utilityIdx: Array of indices to remove Utilities from.
    utilityIdxs (:,1) double

end %argblock

%% Remove Buildings from Site Array
% Remove specified buildings from the site by index and corresponding 
% Utility Type.
switch (utilityMeterType)
    case (ece.enum.UtilityMeterType.Electricity)
        % -- Remove Electric Meter
        site.ElectricMeters(utilityIdxs) = [];

    case (ece.enum.UtilityMeterType.Water)
        % -- Remove Water Meter
        site.WaterMeters(utilityIdxs) = [];

    case (ece.enum.UtilityMeterType.Gas)
        % -- Remove Gas Meter
        site.GasMeters(utilityIdxs) = [];

    case (ece.enum.UtilityMeterType.Oil)
        % -- Remove Oil Meter
        site.OilMeters(utilityIdxs) = [];

    case (ece.enum.UtilityMeterType.Propane)
        % -- Remove Propane Meter
        site.PropaneMeters(utilityIdxs) = [];

    otherwise
        % -- Unhandled Utility Type
        % Throw error that traps an unhandled utility object type.
        error('Unhandled utility type: %s', utilityMeterType);

end %switch/case

end %function

