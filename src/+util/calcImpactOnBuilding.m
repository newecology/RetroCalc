function impact = calcImpactOnBuilding(baseBldg,updatedBldg)
%CALCIMPACTONBUILDING Method calculates level2 for updated building and
%compare it with the base-building's L2 result for calculating the impacts

%% Arguments
% Ensure inputs are the correct size and type.
arguments
    % building: base Building object (before applying the ECM).
    baseBldg (1,1) ece.Building

    % building: updated Building object (after applying the ECM).
    updatedBldg (1,1) ece.Building

end %argblock

% For base building check if base building already has calculated HEA 
% if not, run computeLevel2() for base building
if isempty(baseBldg.RunStatsTable)
    baseBldg.computeLevel2();
end

% Calculate Level2 for updated Building object
updatedBldg.computeLevel2();

% Caclulate Impact
impact = calcImpactOnStats(baseBldg.RunStatsTable,updatedBldg.RunStatsTable);

end

% Compare two HEA and calculate the differences between some select items
function impct = calcImpactOnStats(tbl1,tbl2)
% Difference (Table)
impct.difference= tbl1 - tbl2;

% percentage change (Table)
impct.percentage= impct.difference;
prc = 100*(tbl1{:,:} - tbl2{:,:})./tbl1{:,:};

% Process results with NaN
for k = 1 : numel(prc)
    if isnan(prc(k))
        if tbl2{k,1} ~= 0
            prc(k)  = 100;
        else
            prc(k)  = 0;
        end
    end
end

impct.percentage{:,:} = prc;

end