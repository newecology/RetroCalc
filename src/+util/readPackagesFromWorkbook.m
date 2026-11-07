function packages = readPackagesFromWorkbook(workbookPath)
%READPACKAGESFROMWORKBOOK Read every ECM Package defined in an Excel workbook.
%
%   packages = util.readPackagesFromWorkbook("MyECMs.xlsx")
%
%   Returns an ece.Package array suitable for passing to
%   Building.applyPackages.
%
%   Workbook layout:
%     - Optional "Packages" index sheet with columns:
%         PackageName | ECMOrder | ECMSheet
%       Each row maps a package to one of its ECMs. Rows are grouped by
%       PackageName and ordered by ECMOrder (integer, 1-based). The same
%       ECM sheet can appear in multiple packages.
%
%     - One sheet per ECM. The sheet columns are those read by
%       ece.ECM.readSourceFromTable: Operation, ObjectOfReference,
%       FilterCriteria, PropertyToChange, UpdateType, ValueForChange,
%       InsertQuantity, InsertedProperty.
%
%   Fallback: if the workbook has no "Packages" sheet, every other sheet
%   is treated as a single-ECM package named after the sheet. This lets
%   a user with a handful of standalone ECMs skip the index sheet.
%
%   Sheets named "Instructions", "README", "Notes", or starting with "_"
%   are ignored by the fallback path.

arguments
    workbookPath (1,1) string
end

if ~isfile(workbookPath)
    error("util:WorkbookNotFound", ...
        "ECM workbook not found: %s", workbookPath);
end

allSheets = string(sheetnames(workbookPath));
hasPackages = any(lower(allSheets) == "packages");

if hasPackages
    packages = readFromPackageIndex(workbookPath, allSheets);
else
    packages = readFlat(workbookPath, allSheets);
end

end %function


function packages = readFromPackageIndex(workbookPath, allSheets)
%READFROMPACKAGEINDEX The normal path: a "Packages" index sheet defines
%  one row per (package, ECM order, ECM sheet name).

sheetName = allSheets(lower(allSheets) == "packages");
sheetName = sheetName(1);   % first match

idxTbl = readtable(workbookPath, "Sheet", sheetName, "TextType", "string");
if isempty(idxTbl)
    packages = ece.Package.empty(0,1);
    return;
end

origNames = string(idxTbl.Properties.VariableNames);
lcNames   = lower(origNames);
required  = ["packagename"; "ecmorder"; "ecmsheet"];
missing   = required(~ismember(required, lcNames));
if ~isempty(missing)
    error("util:MissingColumn", ...
        "Packages sheet is missing column(s): %s. Found: %s", ...
        strjoin(missing, ", "), strjoin(origNames, ", "));
end

nameCol  = idxTbl.(origNames(lcNames == "packagename"));
orderCol = idxTbl.(origNames(lcNames == "ecmorder"));
sheetCol = idxTbl.(origNames(lcNames == "ecmsheet"));

% Drop blank rows (common in Excel — trailing empties).
keep = ~ismissing(nameCol) & strlength(string(nameCol)) > 0 & ...
       ~ismissing(sheetCol) & strlength(string(sheetCol)) > 0;
nameCol  = string(nameCol(keep));
orderCol = double(orderCol(keep));
sheetCol = string(sheetCol(keep));

if isempty(nameCol)
    packages = ece.Package.empty(0,1);
    return;
end

% Validate referenced sheets exist.
lcAll = lower(allSheets);
for i = 1:numel(sheetCol)
    if ~any(lcAll == lower(sheetCol(i)))
        error("util:MissingECMSheet", ...
            "Packages sheet row %d references ECM sheet '%s' which does not exist in the workbook. Available sheets: %s", ...
            i, sheetCol(i), strjoin(allSheets, ", "));
    end
end

% Group by package name, preserving the first-seen order of packages so
% the output array is reproducible.
[uniqNames, ~, grpIdx] = unique(nameCol, "stable");
packages = ece.Package.empty(0,1);
for g = 1:numel(uniqNames)
    mask       = (grpIdx == g);
    groupOrder = orderCol(mask);
    groupSheet = sheetCol(mask);

    % Detect duplicate ECMOrder within a package — likely a copy/paste bug.
    [sortedOrder, sortIdx] = sort(groupOrder);
    if numel(sortedOrder) > 1 && any(diff(sortedOrder) == 0)
        dup = sortedOrder(find(diff(sortedOrder) == 0, 1));
        error("util:DuplicateECMOrder", ...
            "Package '%s' has duplicate ECMOrder value %d. Each ECM step must have a unique order.", ...
            uniqNames(g), dup);
    end
    sortedSheets = groupSheet(sortIdx);

    pkg = ece.Package.readSourceFromFile(workbookPath, sortedSheets, uniqNames(g));
    packages(end+1,1) = pkg; %#ok<AGROW>
end

end %function


function packages = readFlat(workbookPath, allSheets)
%READFLAT Fallback: no Packages index — treat each non-reserved sheet as
%  a single-ECM package named after the sheet.

reserved = ["instructions"; "readme"; "notes"];
keep = true(size(allSheets));
for i = 1:numel(allSheets)
    s = lower(allSheets(i));
    if any(reserved == s) || startsWith(s, "_")
        keep(i) = false;
    end
end
usable = allSheets(keep);

if isempty(usable)
    packages = ece.Package.empty(0,1);
    return;
end

packages = ece.Package.empty(0,1);
for i = 1:numel(usable)
    pkg = ece.Package.readSourceFromFile(workbookPath, usable(i), usable(i));
    packages(end+1,1) = pkg; %#ok<AGROW>
end

end %function
