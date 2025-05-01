%function for finding utilization factors for internal and solar gains 
% for heating and utilization of losses for cooling

function [intGainsUtilHtg, solarGainsUtilHtg] = ...
calcHtgUtilFactors(obj, heatLoss12, intGainsHtgSeason12, solarGainsHtgSeason12)
  
%% Arguments Block
arguments
    % Obj - Self-referential building object.
    obj (1,1) ece.Building
    heatLoss12 (1,12)
    intGainsHtgSeason12 (1,12)
    solarGainsHtgSeason12  (1,12)
end %argblock

%%

% heating loads in kBtu. heat flow out is positive.
% cooling loads in kBtu. heat flow out is positive.
% heat loss coefficient (HLC) in Btu/hr-F
% all values are for month time periods. 
% the utilization factor method can be carried out for monthly or seasonal
% time periods. We are using the monthly method.

%%
%find length of heating season in days, to determine 
% average gains over season, to determine mass / gains ratio
   heatCoolDates = obj.HeatCoolSeasonStartEndDates;
   htgStrtDayNumber = day(heatCoolDates(1),'dayofyear');
   htgEndDayNumber = day(heatCoolDates(2),'dayofyear');
   lenHtgSeason = htgEndDayNumber + (365-htgStrtDayNumber);

%average internal and solar gains over the heating season, kBtu/hr
avgIntGainsHtg = sum(intGainsHtgSeason12) / (lenHtgSeason * 24);
avgSolarGainsHtg = sum(solarGainsHtgSeason12) / (lenHtgSeason * 24);

%building heat capacity in Btu/F per square foot of floor area
%from a table of standard values, could be adjusted for unusual
%constructions
ThermalCapTbl = ece.Reference.getThermalCapBldgTable(); % Getting the thermal mass capacity table from reference
bldgMassBtuF_ft2 = ...
    ThermalCapTbl.Thermal_capacity_Btu_F_ft2(ThermalCapTbl.Type == obj.ThermalMass);

%building thermal capacity in kBtu/F , taking the ICFA value for area
bldgHeatCap = bldgMassBtuF_ft2 * obj.BldgArea_ft2(3) / 1000;

%internal gains to heating load ratio (IGLRh) for each month
%this is the heat loss. solar gains are not considered
%dimensionless ratio. row vector with 12 columns.
IGLRh = intGainsHtgSeason12 ./ heatLoss12;

% set infinity or NaN to zero. This occurs in summer months which do not
% apply to the calculation
% IGLRh(isnan(IGLRh)) = 0; 
% IGLRh(isinf(IGLRh)) = 0; 

% Monthly internal gains utilization factors. from 
% Barakat and Sander  ASHRAE Transactions, 92, 1A, pp. 103-115, 1986

intGainsUtilHtg = zeros(1,12);
for n = 1:12
    if IGLRh(n) <= .7
        intGainsUtilHtg(n) = 1;
    elseif IGLRh(n) > .7 & IGLRh(n) <= 5
        intGainsUtilHtg(n) = (.675 + 2.358 * IGLRh(n)^2.342) / (1 + 2.358 * IGLRh(n)^(2.342+1));
    else 
        intGainsUtilHtg(n) = 1 / IGLRh(n);
    end
end

%mass/solar gain ratio (MSGR). units are kBtu/F divided by kBtu/hr = hours/F 
MSGR = bldgHeatCap / avgSolarGainsHtg;
%solar utilization curves based on heat capacity in hrs/K
MSGRK = MSGR * 1.8;

%solar gains to heating load ratio for each month (SGLRh)
%heating loads less useful internal gains for each month
netHtgLoadsMonthly = heatLoss12 - intGainsUtilHtg .* intGainsHtgSeason12;
SGLRh = solarGainsHtgSeason12 ./ netHtgLoadsMonthly;

% Solar gains utilization factors. curves from Barakat and Sander based on
% solar gains to load ratio for each month and different curves by MSGRK 
% We have 3 curves of polynomials for 3 values of MSGRK (for low, medium, 
% high mass to gains ratio, and interpolate between them.
% Barakat and Sander  ASHRAE Transactions, 89, 1A, pp. 12-22, 1983
solarGainsUtilHtg = zeros(1,12);
if MSGRK <= 1
     solarGainsUtilHtg = -1.3631*SGLRh.^6 + 6.7913*SGLRh.^5 - 13.056*SGLRh.^4 ...
     + 11.992*SGLRh.^3 - 4.9589*SGLRh.^2 + .0654*SGLRh + 1.0049;
    elseif MSGRK <= 3
        a = -1.3631*SGLRh.^6 + 6.7913*SGLRh.^5 - 13.056*SGLRh.^4 ...
        + 11.992*SGLRh.^3 - 4.9589*SGLRh.^2 + .0654*SGLRh +1.0049;
        b = -.1983*SGLRh.^4 + .7247*SGLRh.^3 - .7885*SGLRh.^2 - .1026*SGLRh + 1.0033;
        solarGainsUtilHtg = (3-MSGRK)/(3-1)*a + (MSGRK-1)/(3-1)*b;
    elseif MSGRK <= 7.5
        c = -.1983*SGLRh.^4 + .7247*SGLRh.^3 - .7885*SGLRh.^2 - .1026*SGLRh + 1.0033;
        d = .1488*SGLRh.^3 - .3919*SGLRh.^2 -.016*SGLRh + 1.0003;
        solarGainsUtilHtg = (7.5-MSGRK)/(7.5-3)*c + (MSGRK-3)/(7.5-3)*d;
    else 
        solarGainsUtilHtg = .1488*SGLRh.^3 - .3919*SGLRh.^2 -.016*SGLRh + 1.0003;
end  % if statement

%in certain cases, e.g. for heavily insulated buildings (high SGLRh), the 
% polynomials deliver a negative value. Also for some time periods the net
% heating load is zero or negative so there is nothing for solar gains to 
% contribute to. from the paper, the curves converge around .25 at high SGLRh
solarGainsUtilHtg = max(solarGainsUtilHtg, .25);

end   % function statement
