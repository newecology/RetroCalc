function packages = applyPackagesFromWorkbook(bldg, workbookPath, opts)
%APPLYPACKAGESFROMWORKBOOK One-call read-and-apply for Excel-defined ECMs.
%
%   packages = util.applyPackagesFromWorkbook(bldg, "MyECMs.xlsx")
%   packages = util.applyPackagesFromWorkbook(bldg, "MyECMs.xlsx", ...
%                 ApplyMethod="NonInteractive")
%
%   Reads every Package defined in the workbook (via
%   util.readPackagesFromWorkbook), applies them to the Building, and
%   returns the Package array for further inspection.
%
%   Name-value arguments:
%     ApplyMethod - How packages combine when there are 2+:
%                   "Interactive"    (default) packages chain — package k
%                                    starts from package k-1's result.
%                                    Use when you want cumulative savings.
%                   "NonInteractive" every package applied independently
%                                    to a fresh copy of the base building.
%                                    Use when packages are mutually-
%                                    exclusive alternatives to compare
%                                    side-by-side.
%
%   After this call completes, results live on bldg:
%     bldg.PackageSummaryTable   - per-package KeyResults deltas
%     bldg.ECMSummaryTables      - per-ECM-within-package deltas (cell)
%     bldg.Packages              - the applied Packages (with ECMBuildings
%                                  populated this session)

arguments
    bldg (1,1) ece.Building
    workbookPath (1,1) string
    opts.ApplyMethod (1,1) ece.enum.ApplyPackageMethod = ...
        ece.enum.ApplyPackageMethod.Interactive
end

packages = util.readPackagesFromWorkbook(workbookPath);
if isempty(packages)
    warning("util:NoPackagesFound", ...
        "No ECM Packages found in %s. Nothing to apply.", workbookPath);
    return;
end

% Attach packages to the Building (addPackages dedups on identity), then
% run the apply pipeline. applyPackages consumes whatever is in
% bldg.Packages — it does not take a package array argument.
bldg.addPackages(packages);
bldg.applyPackages(opts.ApplyMethod);

end %function
