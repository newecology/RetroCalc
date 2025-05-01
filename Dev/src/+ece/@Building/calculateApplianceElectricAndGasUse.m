function calculateApplianceElectricAndGasUse(obj)
% Calculate appliance electric use for each appliance, and for all, 
% monthly and annual totals

% Method to compute this within a building object. 
% this function takes inputs from the appliance data table as well as from
% the plumbing fixtures data inputs which include appliances
% it calculates the monthly and annual electricity and gas usage for each appliance type 
% it also finds the monthly heat losses from the appliances that need to be counted
% as sensible and latent internal gains

%there is a calculation for each appliance type, then the results for each
%appliance are rolled up into a single 4x13 array with gas usage, electric
%usage, sensible internal gains, and latent internal gains, all by month.
%columns 1-12 are the months. column 13 is annual totals.
%row 1 is therms usage. row 2 is kWh usage. row 3 is sensible internal
%gains from both gas and electricity in kBtu. row 4 is latent internal gains in kBtu.
% the results for all appliances combined are in a 4x12 summaryResultsArray,
% rows are monthly usage and gains. therms, kWh, sensible kBtu, latent kBtu.
% There is also a table listing the appliance types and the energy usage and
% internal gains for each


%% Arguments Block
arguments
    % Obj - Self-referential building object.
    obj (1,1) ece.Building
end %argblock

%% Variables used in calculation

% number of appliance types
numApplTypes = height(obj.Appliances);

% building parameters
numUnits = obj.BldgNumberOfUnits;
numOcc = obj.BldgNumberOfOccupants;
numBedrms = sum(obj.BldgNumberOfBedrooms .* [1 2 3 4]);
avgNumBedrms = numBedrms / numUnits;
daysMonth = [31 28 31 30 31 30 31 31 30 31 30 31];

ApplianceDataTbl = ece.Reference.ApplianceDataTable;


%% Appliances

% output data are in a 4x13 array as explained above
% Gas usage is in therms. Electric usage in kWh. All internal gains are in kBtu.
% Gas appliances also use some electricity which is also tallied in this
% section.
% the appliance code is matched to the code in the appliance data table to
% extract the various parameters for annual usage
% there are 3 different methods for different appliances
% appliance energy use is assumed constant over the year

for n = 1:numApplTypes
    % set local variables to zero each time
    index1 = 0; index2 = 0; index3 = 0; index4 = 0;
    const = 0; numBRmult = 0; annlEnergy = 0; annlTherms = 0; annlkWh = 0;
    loadsWeekApartment = 0; machineEnergyLoad_kWh = 0; 
    refrigeratorAnnual_kWh = 0; annlElectricity_kWh = 0;
    
    % 1st method. stoves and dryers have a common calculation method, 
    % can be gas or electric. Index 1 is the appliance code.
    % Note index1 is a (1,2) vector. Two codes for each appliance type.
    % If the appliance uses both gas and electricity, the codes are
    % different. If the appliance uses only gas or only electricity, the
    % two codes are the same.

    if obj.Appliances(n).ApplianceCategory ==  "Stove" | ...
            obj.Appliances(n).ApplianceCategory == "Dryer"
        index1 = matches(ApplianceDataTbl.Code, obj.Appliances(n).Code);
        const = ApplianceDataTbl.Constant(index1);
        numBRmult = ApplianceDataTbl.AvgNumBRmult(index1);
        annlEnergy = numUnits * obj.Appliances(n).FracUnitsServed * ...
            (const + avgNumBedrms * numBRmult);
        % annlEnergy is a (1,2) vector.

        % case for electric stoves/dryers that only use electricity
        % populate the results array and table with energy and internal gains
        if sum(index1) == 1
            annlTherms = 0;
            annlkWh = annlEnergy;
            obj.Appliances(n).resultsArray(1,13) = annlTherms;
            obj.Appliances(n).resultsArray(2,13)  = annlkWh;
            obj.Appliances(n).resultsArray(1,1:12) = annlTherms / 365 * daysMonth;
            obj.Appliances(n).resultsArray(2,1:12) = annlkWh / 365 * daysMonth;
            obj.Appliances(n).resultsArray(3,:) = ...
                obj.Appliances(n).resultsArray(2,:) ...
                * 3413 / 1000 * ApplianceDataTbl.IntGainsSensFrac(index1);
            obj.Appliances(n).resultsArray(4,:) = ...
                obj.Appliances(n).resultsArray(2,:) ...
                * 3413 / 1000 * ApplianceDataTbl.IntGainsLatFrac(index1);

            % case for gas stoves/dryers that use gas and a bit of electrical energy
            % there are two rows of data table values for the gas use and the
            % electrical use of each appliance type
        else annlTherms = annlEnergy(1);
            annlkWh = annlEnergy(2);
            obj.Appliances(n).resultsArray(1,13) = annlTherms;
            obj.Appliances(n).resultsArray(2,13)  = annlkWh;
            obj.Appliances(n).resultsArray(1,1:12) = annlTherms / 365 * daysMonth;
            obj.Appliances(n).resultsArray(2,1:12) = annlkWh / 365 * daysMonth;
            intGainsSensFrac = ApplianceDataTbl.IntGainsSensFrac(index1);
            intGainsSensFracGas = intGainsSensFrac(1);
            intGainsSensFracElec = intGainsSensFrac(2);
            intGainsLatFrac = ApplianceDataTbl.IntGainsLatFrac(index1);
            intGainsLatFracGas = intGainsLatFrac(1);
            intGainsLatFracElec =  intGainsLatFrac(2);
            obj.Appliances(n).resultsArray(3,:) = ...
                obj.Appliances(n).resultsArray(1,:) * 100 * ...
                intGainsSensFracGas + obj.Appliances(n).resultsArray(2,:) ...
                * 3413 / 1000 * intGainsSensFracElec;
            obj.Appliances(n).resultsArray(4,:) = ...
                obj.Appliances(n).resultsArray(1,:) * 100 * ...
                intGainsLatFracGas + obj.Appliances(n).resultsArray(2,:) ...
                * 3413 / 1000 * intGainsLatFracElec;

        end % nested if statement for gas or electric appliance

    end % outer if statement for is it stove or clothes dryer

    % 2nd method. dishwashers and clothes washers have a common calculation method
    % they use water as well as electricity. values for uses per week are from the plumbing
    % fixtures class
    if obj.Appliances(n).ApplianceCategory == "Dishwasher" | ...
            obj.Appliances(n).ApplianceCategory == "Clotheswasher"
        % for these appliances, cross reference the plumbing fixture inputs
        % for number of loads per week per apartment
        if obj.Appliances(n).ApplianceType == "InUnitDishwashers"
            index2 = matches(string([obj.PlumbingFixtures.PlumbingFixtureType]), ...
                "InUnitDishwasher");
        elseif obj.Appliances(n).ApplianceType == "CommercialDishwashers"
            index2 = matches(string([obj.PlumbingFixtures.PlumbingFixtureType]), ...
                "CommercialDishwasher");
        elseif obj.Appliances(n).ApplianceType == "InUnitClotheswashers"
            index2 = matches(string([obj.PlumbingFixtures.PlumbingFixtureType]), ...
                "InUnitClotheswasher");
        elseif obj.Appliances(n).ApplianceType == "CommonAreaClotheswashers"
            index2 = matches(string([obj.PlumbingFixtures.PlumbingFixtureType]), ...
                "CommonAreaClotheswasher");
        end % if statements for finding loads/week per apartment
        loadsWeekApartment = obj.PlumbingFixtures(index2).Uses;

        % knowing loads/week per apartment, match the appliance code to the
        % data table to find electric use per load, and calculate annual kWh
        index3 = matches(ApplianceDataTbl.Code, obj.Appliances(n).Code);
        machineEnergyLoad_kWh = ApplianceDataTbl.MachineEnergyLoad_kWh(index3);
        annlElectricity_kWh = numUnits * obj.Appliances(n).FracUnitsServed * ...
            loadsWeekApartment * machineEnergyLoad_kWh * 52;
        % construct the 4x13 results array
        obj.Appliances(n).resultsArray(1:13) = zeros(1,13);
        obj.Appliances(n).resultsArray(2,13)  = annlElectricity_kWh;
        obj.Appliances(n).resultsArray(2,1:12) = annlElectricity_kWh / 365 * daysMonth;
        obj.Appliances(n).resultsArray(3,:) = ...
                obj.Appliances(n).resultsArray(2,:) ...
                * 3413 / 1000 * ApplianceDataTbl.IntGainsSensFrac(index3);    
        obj.Appliances(n).resultsArray(4,:) = ...
                obj.Appliances(n).resultsArray(2,:) ...
                * 3413 / 1000 * ApplianceDataTbl.IntGainsLatFrac(index3);
    end % if statement for dishwashers and clothes washers

% 3rd method. refrigerators (and freezers when added) have a third method of finding
% annual energy use which is electricity only
    if obj.Appliances(n).ApplianceCategory == "Refrigerator"
        index4 = matches(ApplianceDataTbl.Code, obj.Appliances(n).Code);
        refrigeratorAnnual_kWh = ApplianceDataTbl.kWhAnnual(index4);
        annlElectricity_kWh = numUnits * obj.Appliances(n).FracUnitsServed * ...
            refrigeratorAnnual_kWh;
        obj.Appliances(n).resultsArray(1:13) = zeros(1,13);
        obj.Appliances(n).resultsArray(2,13)  = annlElectricity_kWh;
        obj.Appliances(n).resultsArray(2,1:12) = annlElectricity_kWh / 365 * daysMonth;
        obj.Appliances(n).resultsArray(3,:) = ...
                obj.Appliances(n).resultsArray(2,:) ...
                * 3413 / 1000 * ApplianceDataTbl.IntGainsSensFrac(index4);    
        obj.Appliances(n).resultsArray(4,:) = ...
                obj.Appliances(n).resultsArray(2,:) ...
                * 3413 / 1000 * ApplianceDataTbl.IntGainsLatFrac(index4);
    end % if statement for refrigerators

end % for loop appliance types

% combine the usage for all the appliances into a summary table and results array

gasUse_therms = zeros(13,1);
elecUse_kWh = zeros(13,1);
intGainsSens_kBtu = zeros(13,1); 
intGainsLat_kBtu = zeros(13,1); 

applianceTypeList = [obj.Appliances.ApplianceType]';
applianceType = [string(applianceTypeList);  "Totals"];
subType = [obj.Appliances.SubType]';
subType = [subType; ""];
allResults = [obj.Appliances.resultsArray];
gasUse_therms = allResults(1,13:13:end)';
gasUse_therms(end+1) = sum(gasUse_therms);
elecUse_kWh = allResults(2,13:13:end)';
elecUse_kWh(end+1) = sum(elecUse_kWh);
intGainsSens_kBtu = allResults(3,13:13:end)';
intGainsSens_kBtu(end+1) = sum(intGainsSens_kBtu);
intGainsLat_kBtu = allResults(4,13:13:end)';
intGainsLat_kBtu(end+1) = sum(intGainsLat_kBtu);
fractionUnitsServed = [obj.Appliances.FracUnitsServed]';
fractionUnitsServed(end+1) = NaN; 

% table to show annual total energy use for each appliance
obj.ApplianceResultsTable = table(applianceType, subType, fractionUnitsServed, gasUse_therms, ...
    elecUse_kWh, intGainsSens_kBtu, intGainsLat_kBtu);

% appliance results table to show monthly energy use and internal 
% gains for all appliances combined for use in calculations
% use a for loop with iterative summing because there can be multiple lines
% with the same appliance type (for example a building has some efficient
% refrigerators and some older inefficient ones)
% same format: 4 rows for gas therms, electric kWh, sensible internal gains
% kBtu, and latent internal gains kBtu. 12 columns for 12 months
ApplianceSummaryResultsArray = zeros(4, 12);
electricMonthly_kWh = zeros(1,12);
gasMonthly_therms = zeros(1,12);
intGainsSensMonthly_kBtu = zeros(1,12);
intGainsLatMonthly_kBtu = zeros(1,12);

% Iterative summing -- possibly more than one type or subtype each appliance.
for n = 1:numApplTypes
    gasMonthly_therms = gasMonthly_therms + obj.Appliances(n).resultsArray(1,1:12);
    electricMonthly_kWh = electricMonthly_kWh + obj.Appliances(n).resultsArray(2,1:12);
    intGainsSensMonthly_kBtu = intGainsSensMonthly_kBtu + obj.Appliances(n).resultsArray(3,1:12);
    intGainsLatMonthly_kBtu = intGainsLatMonthly_kBtu + obj.Appliances(n).resultsArray(4,1:12);
end  % for loop for monthly results

ApplianceSummaryResultsArray = [electricMonthly_kWh; gasMonthly_therms;  ...
    intGainsSensMonthly_kBtu; intGainsLatMonthly_kBtu];
ApplianceEnergyTable12 = array2table(ApplianceSummaryResultsArray, ...
    'VariableNames', {'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', ...
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'}, 'RowNames', ...
    {'Electric_kWh'; 'Gas_therms'; 'SensibleGains_kBtu'; 'LatentGains_kBtu'});
ApplianceEnergyTable12.Properties.Description = "Appliance usage by energy type and internal gains";

obj.ApplianceEnergyTable12 = ApplianceEnergyTable12;


end %function

