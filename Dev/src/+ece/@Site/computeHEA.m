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
% Initialize the site-level HEA at zero.
site.HEA = ece.HEA;

% -- Prepare list of properties to sum.
% Extract all properties that would be summed up by Building. This
% corresponds to non-dependent properties.
metaHEA = ?ece.HEA;
props = metaHEA.PropertyList;
nonDepProps = props(~[props.Dependent]);
summableProps = string({nonDepProps.Name});
numProps = length(summableProps);


%% Compute Each Building's HEA
% Run the method to calculate HEA for each Building.
for bldgIdx = 1:site.NumBuildings
    % Run HEA Calculation method.
    site.Buildings(bldgIdx).computeHEA();

    % Iterate through each property of the Building's HEA and add to
    % Site's.
    for pIdx = 1:numProps
        % Get property name to sum.
        propName = summableProps(pIdx);

        % Add Building's HEA property value to Site's same property.
        site.HEA.(propName) = site.HEA.(propName) + ...
            site.Buildings(bldgIdx).HEA.(propName);

    end %forloop

end %forloop



end %function

