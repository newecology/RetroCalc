%% Site Full Run — end-to-end example: HEA, Level 2, and ECM Packages
%
% Runs the full RetroCalc pipeline on the bundled test data:
%
%   Phase 1   Build a Site from Excel input files
%   Phase 2   Historical Energy Analysis  (bills → per-fuel end-use split)
%   Phase 3   Level 2 engineering model   (component-level monthly energy balance)
%   Phase 4   Calibration view            (HEA vs Level 2 side-by-side)
%   Phase 5   Apply ECM Packages          (measures defined in Excel)
%   Phase 5b  Export per-ECM diagnostics  (one workbook with all breakdowns)
%
% Prerequisites
%   - MATLAB R2022b+
%   - Open  Retrocalc_openSource.prj  first so the src and tests paths are active
%   - Optional: set the NREL_API_KEY and DEGREEDAYS_*_KEY environment variables
%     BEFORE launching MATLAB so Level 2 solar gains and historical DD API
%     pulls work. See README.md > "API keys" for setup details.
%
% Edit `examples/example_ECM_Package.xlsx` to author your own ECMs. Close
% the workbook in Excel before running this script — Excel's file lock
% will crash readtable on an open workbook.

%% =====================================================================
%% Phase 1 — Build a Site from Excel input files
%% =====================================================================
buildingDataPath    = fullfile(ecetest.testDataRoot, "buildingInputs.xlsx");
utilityDataPath     = fullfile(ecetest.testDataRoot, "utilityInputs1.xlsx");
hddDataPath         = fullfile(ecetest.testDataRoot, "historicalDDInputs.xlsx");
weatherDataPath     = fullfile(ecetest.testDataRoot, "weatherDataInputs.xlsx");
siteInputsDataPath  = fullfile(ecetest.testDataRoot, "siteInputs.xlsx");

site = ece.Site.fromInputExcelFiles( ...
    "BuildingPath",       buildingDataPath, ...
    "UtilityPath",        utilityDataPath, ...
    "HistDDPath",         hddDataPath, ...
    "WeatherDataPath",    weatherDataPath, ...
    "SiteInputsDataPath", siteInputsDataPath);

fprintf("Site loaded: %d building(s), %d electric / %d gas / %d water meter(s).\n", ...
    numel(site.Buildings), numel(site.ElectricMeters), ...
    numel(site.GasMeters),  numel(site.WaterMeters));

%% =====================================================================
%% Phase 2 — Historical Energy Analysis (HEA)
%% =====================================================================
% Regress monthly billing data against degree-days, split into end uses
% (heating / cooling / DHW / base load), weather-normalize against the
% historical DD table.
site.computeBuildingUtilityUsages();
site.computeHEA();

fprintf("\n=== HEA results — Building 1 ===\n");
disp(site.Buildings(1).HEA.ResultsTable);

%% =====================================================================
%% Phase 3 — Level 2 engineering model on Building 1
%% =====================================================================
% Build a component-level monthly energy balance using ISO 52016 / ASHRAE
% 90.1-style heat loss, utilization factors, DHW, lighting, and plug loads.
buildingLevel2DataPath = fullfile(ecetest.testDataRoot, "buildingL2Inputs.xlsx");
site.Buildings(1).importLevel2ObjectData(buildingLevel2DataPath);
site.Buildings(1).computeLevel2();

fprintf("\n=== Level 2 results — Building 1 ===\n");
disp(site.Buildings(1).Level2.ResultsTable);

%% =====================================================================
%% Phase 4 — Calibration view (HEA vs Level 2 side-by-side)
%% =====================================================================
% Tune Level 2 inputs (mechanical efficiencies, hot-water use per person,
% lighting hours, etc.) until all per-fuel |%Delta| values stay within
% ASHRAE Guideline 14's +/- 5% annual threshold.
fprintf("\n=== Calibration view — Building 1 ===\n");
disp(site.Buildings(1).UsageComparisonTable);

%% =====================================================================
%% Phase 5 — Apply ECM Packages defined in Excel
%% =====================================================================
% The bundled example workbook defines 5 retrofit packages composed from
% 10 ECM sheets, covering every pattern (update/add/multiply/replace,
% insert, delete, enum changes, indexed-array edits, filter-by-property,
% filter-by-index). Edit the workbook to author your own measures.
%
% The sheet 'Instructions' inside the workbook has full documentation.
scriptDir   = fileparts(mfilename("fullpath"));
projectRoot = fileparts(fileparts(scriptDir));   % up two levels: runScripts/ → sandbox/ → RetroCalc/
ecmWorkbook = fullfile(projectRoot, "examples", "example_ECM_Package.xlsx");

if ~isfile(ecmWorkbook)
    warning("SiteFullRun:MissingECMWorkbook", ...
        "ECM workbook not found at %s. Skipping Phases 5 and 5b.", ecmWorkbook);
    return;
end

fprintf("\nApplying ECM Packages from %s ...\n", ecmWorkbook);
packages = util.applyPackagesFromWorkbook(site.Buildings(1), ecmWorkbook);

fprintf("\n=== Package summary — Building 1 ===\n");
disp(site.Buildings(1).PackageSummaryTable);

fprintf("\n=== Per-ECM summary — Building 1 ===\n");
for p = 1:numel(site.Buildings(1).ECMSummaryTables)
    fprintf("  Package %d (%s):\n", p, site.Buildings(1).Packages(p).Name);
    disp(site.Buildings(1).ECMSummaryTables{p});
end

%% =====================================================================
%% Phase 5b — Export per-ECM diagnostics to Excel
%% =====================================================================
% Writes a single workbook with one sheet per (Package, ECM) state. Each
% sheet stacks twelve tables (RunStats, SpaceHeating_kBtu, SpaceCooling,
% ElectricUsage, HeatFuel, InternalGains, HeatLoss/HeatGain components,
% SolarGains, ApplianceResults, DHW energy/fuel, KeyResults) so you can
% trace exactly where each ECM's savings came from.
outDir = fullfile(tempdir, "RetroCalc_output");
if ~isfolder(outDir)
    mkdir(outDir);
end
diagnosticsPath = fullfile(outDir, "ECM_Diagnostics.xlsx");
site.Buildings(1).exportECMDiagnostics(diagnosticsPath);
fprintf("\nWrote per-ECM diagnostics to:\n  %s\n", diagnosticsPath);
