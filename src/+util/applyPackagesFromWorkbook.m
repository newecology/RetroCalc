function packages = applyPackagesFromWorkbook(bldg, workbookPath)
%APPLYPACKAGESFROMWORKBOOK One-call read-and-apply for Excel-defined ECMs.
%
%   packages = util.applyPackagesFromWorkbook(bldg, "MyECMs.xlsx")
%
%   Reads every Package defined in the workbook (via
%   util.readPackagesFromWorkbook), applies them to the Building, and
%   returns the Package array for further inspection.
%
%   After this call completes, results live on bldg:
%     bldg.PackageSummaryTable   - per-package KeyResults deltas
%     bldg.ECMSummaryTables      - per-ECM-within-package deltas (cell)
%     bldg.Packages              - the applied Packages (with ECMBuildings
%                                  populated this session)
%
%   This is a convenience wrapper. If you need to build packages once
%   and apply to many buildings, call util.readPackagesFromWorkbook
%   directly and loop.

arguments
    bldg (1,1) ece.Building
    workbookPath (1,1) string
end

packages = util.readPackagesFromWorkbook(workbookPath);
if isempty(packages)
    warning("util:NoPackagesFound", ...
        "No ECM Packages found in %s. Nothing to apply.", workbookPath);
    return;
end

% Attach packages to the Building (dedup on identity happens inside
% addPackages), then run the apply pipeline. applyPackages consumes
% whatever is in bldg.Packages — it does not take a package array
% argument. Use the default Interactive mode (sequential per-ECM copy).
bldg.addPackages(packages);
bldg.applyPackages();

end %function
