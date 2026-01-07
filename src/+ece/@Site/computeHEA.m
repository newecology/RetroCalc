function computeHEA(site)
%COMPUTEHEA Method to compute the HEA of the Site and its component
%buildings.
%   This method creates an HEA object for each of the component Buildings
%   using the HEA class static constructor. At the end, the HEA for the
%   Site itself is computed as the sum of each buildings' HEA results.

%% Argument Block
arguments
    % site: Self-referencing Site object.
    site (1,1) ece.Site
end %argblock

%% Prepare HEA for Site Level Computation
% Initialize the site-level HEA with a new empty KeyResults object.
site.HEA = ece.KeyResults;

% -- Prepare list of properties to sum.
% Extract all properties that would be summed up by Building. This
% corresponds to non-dependent properties.
metaHEA = ?ece.KeyResults;
props = metaHEA.PropertyList;
nonDepProps = props(~[props.Dependent]);
summableProps = string({nonDepProps.Name});

nonSummableProps = ["EUI" "UnitCostOfElectricity" "UnitCostOfGas" ...
    "UnitCostOfWater" "UnitCostOfOil" "UnitCostOfPropane" "Water_GPDBedroom" ...
    "SpaceHeat_kBtuFt2" "SpaceCool_kBtuFt2" "DHW_kBtuFt2" "ApplianceFuel_kBtuFt2"];
numProps2 = length(nonSummableProps);
summableProps = setdiff(summableProps, nonSummableProps);
numProps1 = length(summableProps);
sumAreaAllBldg = 0;
sumTotBRs = 0;
% Getting the total area of all the buildings
for bldgIdx = 1:site.NumBuildings
    sumAreaAllBldg = sumAreaAllBldg + site.Buildings(bldgIdx).GrossConditionedArea_ft2;
    sumTotBRs = sumTotBRs +sum(site.Buildings(bldgIdx).NumberOfBedroomUnits .* [1, 2, 3, 4]);
end % end for loop

%% Compute Each Building's HEA
% Run the method to calculate HEA for each Building.
for bldgIdx = 1:site.NumBuildings
    % Run HEA Calculation method.
    site.Buildings(bldgIdx).computeHEA();
    %getting number of bedroom units
    numBRs = sum(site.Buildings(bldgIdx).NumberOfBedroomUnits .* [1, 2, 3, 4]);
    % Iterate through each property of the Building's HEA and add to
    % Site's.
    % FIX THIS! Some properties are not added.
    for pIdx = 1:numProps1
        % Get property name to sum.
        propName = summableProps(pIdx);
        
        % Add Building's HEA property value to Site's same property.
        site.HEA.(propName) = site.HEA.(propName) + ...
            site.Buildings(bldgIdx).HEA.(propName);

    end %forloop
    % Iterate through each property of the Building's HEA and add to
    % Site's. for the non-summable properties
    for pIdx = 1:numProps2
        % Get property name to sum.
        propName = nonSummableProps(pIdx);
        % sorting Area weighted average properties
        if propName ~= "Water_GPDBedroom"
        % Add Building's HEA property value to Site's same property.
        site.HEA.(propName) = site.HEA.(propName) + ...
            (site.Buildings(bldgIdx).HEA.(propName) * site.Buildings(bldgIdx).GrossConditionedArea_ft2)/sumAreaAllBldg;
        else
        site.HEA.(propName) = site.HEA.(propName) + ...
            (site.Buildings(bldgIdx).HEA.(propName) * numBRs)/sumTotBRs;   
        end %end if

    end %forloop


end %forloop



end %function

