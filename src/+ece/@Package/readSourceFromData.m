function package = readSourceFromData(ecmFname,nameArray,pckgName)
%%%%TBD

%% Arguments Block
% Set input argument validation.
arguments
    % ecmArray: 
    ecmFname (:,:) string

    % nameArray: 
    nameArray (:,:) string

    % pckgName:
    pckgName (1,1) string
end %argblock

% Read from file
dt  = load(ecmFname);
ecmArray= dt.ecmdata;


% Return empty array if none exist.
emptyCheck = isempty(ecmArray) || isempty(nameArray);
if(emptyCheck)
    package = ece.Package.empty(0,1);
    return;
end %endif

% get Array height
hgt     = numel(nameArray);
allNames= [ecmArray.Name];
[~,eIdx]= intersect(allNames,nameArray,'stable');

%% Iterate through each ECM
package     = ece.Package;
package.Name= pckgName;

for idx = 1:hgt
    % update ECMs array in Package
    thsEcmTb= ecmArray(eIdx(idx)).Tbl;
    thisEcm = ece.ECM.readSourceFromTable(thsEcmTb,nameArray(idx));
    package.ECMs(idx) = thisEcm;
end %forloop (idx)

end %function
