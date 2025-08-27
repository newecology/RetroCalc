function package = readSourceFromFile(fnmArray, shnArray, pckgName)
%fineName to provide excel file path for calcInputs file
%sheetname to provide sheet name that corresponds to this particular ECM
%   This method will output an array of Airmovers objects, one per the row

%% Arguments Block
% Set input argument validation.
arguments
    % fnmArray: 
    fnmArray (:,:) string

    % shnArray: 
    shnArray (:,:) string

    % pckgName:
    pckgName (1,1) string
end %argblock

% Return empty array if none exist.
emptyCheck = isempty(fnmArray) || isempty(shnArray);
if(emptyCheck)
    package = ece.Package.empty(0,1);
    return;
end %endif

%
if numel(shnArray) > 1 && numel(shnArray) ~= numel(fnmArray)
    return
end

% get Array height
hgt = numel(ecmArray);
if isscalar(shnArray)
    shnArray = repmat(shnArray,hgt,1);
end

%% Iterate through each ECM
package     = ece.Package;
package.Name= pckgName;

for idx = 1:hgt
    % create ECM object from the file/sheet names
    thisECM = ece.ECM.ReadSourceFromFile(fnmArray(idx), shnArray(idx));

    % update ECMs array in Package
    package.ECMs(idx) = thisECM;

end %forloop (idx)

end %function