function applyPackages(obj,applyMethod)
%APPLYPACKAGES Method to apply the Packages within a Building to the
%Building to obtain the results.
%   This method takes in an input applyMethod and will use that to inform
%   how the collection of Packages in a Building is applied to it.

%% Arguments Block
arguments (Input)
    % obj: Self-referential Building object.
    obj (1,1) ece.Building

    % applyMethod: Method of applying packages to building.
    %   Defaults to sequential (interactive) apply.
    applyMethod (1,1) ece.enum.ApplyPackageMethod = ...
        ece.enum.ApplyPackageMethod.Interactive;

end %argblock

%% Apply Package Changes
% Switch between non-interactive/interactive mode to determine how new
% Buildings are created from the base Building.
% This portion of the method generates all the Buildings after Base that
% have the changes imparted by each Package>ECM. These are stored in
% a Building array within Package.

% Switch on Apply Method.
switch (applyMethod)
    case (ece.enum.ApplyPackageMethod.NonInteractive)
        % -- Apply Packages Non-Interactively
        % Non-Interactive Packages receive a copy of the base building to 
        % apply themselves to.

        % Iterate through each Package in the Building and provide
        % the copy of the base building for each package to generate a resultant
        % Building for.
        for packageIdx = 1:obj.NumPackages
            % Get Package Reference
            currentPackage = obj.Packages(packageIdx);

            % Clear Current ECM Buildings.
            currentPackage.ECMBuildings = ece.Building.empty(0,1);

            % Create copy of input Building.
            %   Note: Copy is necessary to break reference to base building. By
            %   copying the Building, it is now a distinct reference.
            inputBuilding = copy(obj);

            % Apply Package to Building
            currentPackage.applyPackage(inputBuilding);

        end %forloop


    case (ece.enum.ApplyPackageMethod.Interactive)
        % -- Apply Packages Interactively
        % Interactive Packages receive a copy of the base building at 
        % first, then each subsequent Package takes the previous Package's 
        % output Building.

        % Iterate through each Package in the Building and provide
        % the copy of the base building for each package to generate a
        % resultant Building.
        for packageIdx = 1:obj.NumPackages
            % Get Package Reference
            currentPackage = obj.Packages(packageIdx);

            % Clear Current ECM Buildings.
            currentPackage.ECMBuildings = ece.Building.empty(0,1);

            % -- Prepare Building Copy Input
            % Determine which Building to copy input for current Package.
            %   A copy is necessary to break reference to base building. By
            %   copying the Building, it is now a distinct reference.
            if (packageIdx == 1)
                % The first package uses a copy of the input base building.
                inputBuilding = copy(obj);
            else
                % All subsequent packages use previous package's output 
                % Building.
                prevPackage = obj.Packages(packageIdx - 1);
                inputBuilding = copy(prevPackage.ResultBuilding);
            end %endif

            % Apply Package to Building
            currentPackage.applyPackage(inputBuilding);

        end %forloop

    otherwise
        % -- Other Methods
        % Not possible to hit this; including for posterity.

end %switch/case

%% Compute Level 2 Results for all Buildings
% For each Package/ECM in the Building, run the Level 2 calculation code on
% the Buildings within to have LEvel2 KeyResults to compare.
for packageIdx = 1:obj.NumPackages
    % Extract Package
    currentPackage = obj.Packages(packageIdx);

    % Run Level2 Analysis on Each Package's Buildings
    for ecmIdx = 1:(currentPackage.NumECMs)
        % Run Level 2 Calc on Building
        currentPackage.ECMBuildings(ecmIdx).computeLevel2();
        disp(currentPackage.ResultBuilding.Level2.ResultsTable);
        
    end %forloop (ecms)

end %forloop (packages)


%% Create Package Summary Table
% Package Results Table is a table that shows the Base Level2 Results and
% each Package's Final Building Level 2 Results.
% Initialize Package Summary Table off of Level 2 Results
obj.PackageSummaryTable = obj.Level2.ResultsTable;
obj.PackageSummaryTable.Properties.VariableNames(2) = "Base";

% For each package in Building, gather Level 2 Results Column
for packageIdx = 1:obj.NumPackages
    % Extract current package. Level2 Results Table
    currentPackage = obj.Packages(packageIdx);
    
    % Extract Package's ResultBuilding's Level2 ResultsTable.
    pkgResultTable = currentPackage.ResultBuilding.Level2.ResultsTable;

    % Update Column Name
    pkgResultTable.Properties.VariableNames(2) = ...
        "Package " + packageIdx; % +  ": " + currentPackage.Name;

    % InnerJoin Tables
    [obj.PackageSummaryTable, sortIdx] = innerjoin(...
        obj.PackageSummaryTable,pkgResultTable,...
        "Keys","Property");

    % Restore Original Sort Order
    [~,x] = sort(sortIdx);
    obj.PackageSummaryTable = obj.PackageSummaryTable(x,:);

end %forloop



%% Create ECM Summary Tables
% ECM Summary Tables are a collection of tables (one for each package) that
% Result SummaryTable Cell for Building
obj.ECMSummaryTables = cell(obj.NumPackages,1);

% For each package in Building, create the ECMTable.
for packageIdx = 1:obj.NumPackages
    % Extract current package. Level2 Results Table
    currentPackage = obj.Packages(packageIdx);

    % -- Setup Reference Base Building
    % Instantiate New Table based on ApplyMethod
    switch (applyMethod)
        case (ece.enum.ApplyPackageMethod.Interactive)
            % -- Interactive
            % The initial table is made from either the base building OR
            % the previous's Package's Final ECM building.
            if (packageIdx == 1)
                ecmPkgTable = obj.Level2.ResultsTable;
            else
                % Get Previous Package's ResultBuilding's Table.
                ecmPkgTable = ...
                    obj.Packages(packageIdx-1).ResultBuilding.Level2.ResultsTable;
            end %endif

        otherwise
            % -- Otherwise (Non-Interactive)
            % The initial table is always made from the Base Building.
            ecmPkgTable = obj.Level2.ResultsTable;

    end %switch/Block

    % -- Create ECM Table
    % Iterate through each ECM
    for ecmIdx = 1:currentPackage.NumECMs
        % Get ECM and ECMBuilding Reference
        currentECM = currentPackage.ECMs(ecmIdx);
        currentECMBldg = currentPackage.ECMBuildings(ecmIdx);

        % Extract ECM Level2 Results Table
        currentECMResultsTable = currentECMBldg.Level2.ResultsTable;
       
        % InnerJoin tables together on Property Column Key
        [ecmPkgTable, sortIdx] = innerjoin(...
            ecmPkgTable,currentECMResultsTable,...
            "Keys","Property");


        % Restore Original Sort Order
        [~,x] = sort(sortIdx);
        ecmPkgTable = ecmPkgTable(x,:);

    end %forloop (ecm)

    % -- Create Difference Table
    % Create a table of column difference for all numeric values.
    ecmPkgTable = [ecmPkgTable(:,1),...
        diff(ecmPkgTable(:,2:end),1,2)];

    % Transpose Table - Rows are now ECMs
    ecmPkgTable = rows2vars(ecmPkgTable,...
        "VariableNamesSource","Property",...
        "VariableNamingRule","preserve");

    % Rename 1st Column to ECM # and Fill with ID
    ecmPkgTable.Properties.VariableNames(1) = "ECM";
    ecmPkgTable.ECM = (1:currentPackage.NumECMs)';

    % Add ECM Name Column to Table
    ecmPkgTable = addvars(ecmPkgTable,...
        [currentPackage.ECMs.Name]',...
        [currentPackage.ECMs.Description]',...
        'NewVariableNames',["Name","Description"],...
        'After',1);
    
    % Store Completed Package Table in Cell
    obj.ECMSummaryTables{packageIdx,1} = ecmPkgTable;

end %forloop

%% Set Building Apply Flag
% Dummy: Set flag that says the packages were applied.
obj.HasAppliedPackages = true;


end %function