# RetroCalc

> **An ASHRAE Level 2-compliant energy, water, and decarbonization model for multifamily buildings.**
> Built by [New Ecology, Inc.](https://newecology.org) to make rigorous retrofit analysis fast enough for real-world technical assistance.

![MATLAB](https://img.shields.io/badge/MATLAB-R2022b%2B-blue)
![License](https://img.shields.io/badge/license-see%20LICENSE.txt-lightgrey)
![ASHRAE](https://img.shields.io/badge/ASHRAE-Level%202-brightgreen)

This is the **open-source backend** of RetroCalc. There is also a desktop UI build distributed separately; this repo is the engine — everything the UI does is reachable from the MATLAB command line via a small number of well-documented classes and helpers.

---

## What you can do with it

- **Historical Energy Analysis (HEA)** — regress utility bills against degree days to split a building's actual use into heating / cooling / DHW / base load, per fuel.
-   **Level 2 model** — compute monthly space heating, cooling, DHW, lighting, equipment, fans, pumps, and appliance energy from component-level inputs (ASHRAE Level 2 depth).
-  **Calibrate** the model to real utility bills to tune mechanical efficiencies and schedules.
-  **Model ECMs and Packages** — define Energy Conservation Measures (efficiency upgrades, equipment swaps, setpoint changes, insulation, etc.) and see cumulative savings across electricity, gas, oil, propane, water, cost, and CO₂.
-  **Define ECMs entirely in Excel** — no MATLAB code required to author measures. Drop-in template with Excel dropdowns included.
-  **Export** per-ECM Level 2 breakdowns to a single Excel workbook for QC or deliverable-ready savings tables.

---

## Installation

### Requirements

| | |
|---|---|
| **MATLAB** | R2022b or later. Recent features (e.g. `dictionary`) are used. |
| **Toolboxes** | No extra toolboxes required for the HEA + Level 2 core. The weather / degree-day API calls use `webread` from base MATLAB. |
| **OS** | Windows, macOS, or Linux (anything MATLAB runs on). |

### Setup

```bash
git clone https://github.com/<org>/Retrocalc_openSource.git
cd Retrocalc_openSource/RetroCalc
```

Then in MATLAB:

1. Open `Retrocalc_openSource.prj` (double-click from File Explorer, or `openProject("Retrocalc_openSource.prj")` at the prompt). This adds `src/+ece`, `src/+util`, and `tests/+ecetest` to the path automatically.
2. Confirm it loaded correctly:
   ```matlab
   methods(?ece.Site)      % should list ~20 Site methods
   ```

### Optional — API keys for weather and solar data

Two features need API keys that you set as **environment variables before launching MATLAB**:

| Variable | Used by | Where to get it |
|---|---|---|
| `DEGREEDAYS_ACCOUNT_KEY` | Pulling historical HDD/CDD from the degreedays.net API | Free account at [degreedays.net](https://www.degreedays.net/api) |
| `DEGREEDAYS_SECURITY_KEY` | Same | Same |
| `NREL_API_KEY` | Fetching PVWatts solar/weather for Level 2 solar gains | Free, instant at [developer.nrel.gov/signup](https://developer.nrel.gov/signup/) |

**Windows**: open `cmd` and run `setx NREL_API_KEY "your-key"` (same for the two degreedays vars), then **restart MATLAB** so it picks up the new variables.
**macOS / Linux**: `export NREL_API_KEY="your-key"` in `~/.zshrc` or `~/.bashrc`, then open a new shell / restart MATLAB.

Without the degreedays keys, you can still load HDD/CDD from an Excel file manually. Without the NREL key, Level 2 will log a warning and fall back to zero solar gain per window.

---

## Quick start — 10-line full run

A minimal end-to-end run on the bundled test data:

```matlab
%% Build a Site from Excel input files
site = ece.Site.fromInputExcelFiles( ...
    "BuildingPath",       fullfile(ecetest.testDataRoot, "buildingInputs.xlsx"), ...
    "UtilityPath",        fullfile(ecetest.testDataRoot, "utilityInputs1.xlsx"), ...
    "HistDDPath",         fullfile(ecetest.testDataRoot, "historicalDDInputs.xlsx"), ...
    "WeatherDataPath",    fullfile(ecetest.testDataRoot, "weatherDataInputs.xlsx"), ...
    "SiteInputsDataPath", fullfile(ecetest.testDataRoot, "siteInputs.xlsx"));

%% HEA — split bills into end uses, per building, per fuel
site.computeBuildingUtilityUsages();
site.computeHEA();

%% Level 2 — compute an engineering model on Building 1
site.Buildings(1).importLevel2ObjectData( ...
    fullfile(ecetest.testDataRoot, "buildingL2Inputs.xlsx"));
site.Buildings(1).computeLevel2();

%% Look at results
disp(site.Buildings(1).HEA.ResultsTable);     % billing-derived
disp(site.Buildings(1).Level2.ResultsTable);  % engineering model
disp(site.Buildings(1).UsageComparisonTable); % side-by-side calibration view
```

Phases 1–3 above are the first half of **[`sandbox/runScripts/SiteFullRun.m`](sandbox/runScripts/SiteFullRun.m)** — a bundled end-to-end script that also runs calibration (Phase 4), applies the example ECM Packages (Phase 5), and exports a per-ECM diagnostics workbook. Run it directly to exercise the whole pipeline on the test data.

---

## The workflow

A full retrofit analysis is five phases. Each one maps to one or two method calls:

### 1️⃣ Load the building

Four or five Excel files describe the building: site geometry, utility bills, historical degree-days, weather (TMY3/TMYx), and the component-level Level 2 takeoff.

| File | Contents |
|---|---|
| `buildingInputs.xlsx` | One row per building: area, units, year built, orientation, climate. |
| `utilityInputs.xlsx` | One sheet per meter, one row per billing period. |
| `historicalDDInputs.xlsx` | Daily HDD65 / CDD70 history. |
| `weatherDataInputs.xlsx` | TMY3 / TMYx hourly weather for the site. |
| `buildingL2Inputs.xlsx` | Level 2 takeoff: walls, windows, HVAC, DHW, appliances, fixtures, spaces, pumps, fans. |

Template copies of all five live in `tests/testdata/`. Open them to see the exact column names and sheet layouts expected.

### 2️⃣ Historical Energy Analysis (HEA)

Regresses monthly billing data against degree-days to split actual use into heating / cooling / DHW / base load, per fuel. Weather-normalizes so results from different years are comparable.

```matlab
site.computeBuildingUtilityUsages();
site.computeHEA();
site.Buildings(1).HEA.ResultsTable       % per-fuel totals, costs, CO₂
site.Buildings(1).AnnualElectricUsageTable  % end-use split with annual and per-year rows
```

### 3️⃣ Level 2 engineering model

Builds a component-by-component monthly energy balance using the ISO 52016 / ASHRAE 90.1 heat-loss and utilization-factor method.

```matlab
site.Buildings(1).importLevel2ObjectData("buildingL2Inputs.xlsx");
site.Buildings(1).computeLevel2();
site.Buildings(1).Level2.ResultsTable
```

### 4️⃣ Calibrate

The calibration view shows HEA vs Level 2 side-by-side with per-metric deltas. Tune Level 2 inputs (mechanical efficiencies, DHW use per person, lighting hours) until the deltas are within ASHRAE Guideline 14's ±5% annual tolerance.

```matlab
disp(site.Buildings(1).UsageComparisonTable)
```

### 5️⃣ Apply ECMs and Packages

This is where RetroCalc's modular design pays off: **define measures in Excel, apply with one line of MATLAB**, see cumulative savings across electricity, gas, oil, propane, water, cost, and CO₂.

See the next section.

---

##  Defining ECMs and Packages in Excel (new!)

You do **not** need to write MATLAB code to author measures. Open `examples/example_ECM_Package.xlsx`, edit with Excel's built-in dropdowns, close the file, then:

```matlab
pkgs = util.applyPackagesFromWorkbook(site.Buildings(1), ...
            "examples/example_ECM_Package.xlsx");
site.Buildings(1).PackageSummaryTable    % per-package KeyResults deltas
site.Buildings(1).ECMSummaryTables       % per-ECM breakdown within each Package
```

The template ships with:
-  **Instructions sheet** — column reference, FilterCriteria DSL, Insert DSL, troubleshooting
-   **Packages sheet** — one row per `(Package, step)` — define which ECMs run in which order
-  **10 example ECM sheets** covering every operation pattern (update/add/multiply/replace, insert, delete, enum changes, indexed-array edits, filter-by-property, filter-by-index)
-   **Four dropdowns per ECM sheet**: Operation, ObjectOfReference, PropertyToChange (auto-updates to show only the chosen class's properties), UpdateType
-  **Labeled indexed entries** — `HeatCoolSetpoints(1) — HtgTP1 (day)` lets you target one element of a 1×6 array without replacing the whole vector

⚠️ **Close the workbook in Excel before running MATLAB.** Excel holds a file lock on an open workbook and `readtable` will error with "file is in use."

**Full guide**: [`documentation/ECM_Package_Workbook_Guide.md`](documentation/ECM_Package_Workbook_Guide.md)
**Every property on every class, every enum member**: [`documentation/ECM_Property_Reference.md`](documentation/ECM_Property_Reference.md)

---

## Export results to Excel

One call to dump the full Level 2 intermediate breakdown + per-ECM savings into a single workbook:

```matlab
site.Buildings(1).exportResultTables("output.xlsx");         % base Level 2
site.Buildings(1).exportECMDiagnostics("diagnostics.xlsx");  % per-ECM detail
```

`exportECMDiagnostics` writes one sheet per `(Package, ECM)` state with twelve stacked tables including monthly space-heating / cooling / DHW / electric end-use breakdowns, heat-loss components, solar gains by window, and a KeyResults summary. Useful when you need to justify where an ECM's savings came from.

---

## Repository layout

```
RetroCalc/
├── src/
│   ├── +ece/              # Core calculation engine (classes)
│   │   ├── @Site/           Top-level container; owns Buildings + utility meters
│   │   ├── @Building/       The central modeling object — all compute methods live here
│   │   ├── @HeatCool/       Heating/cooling systems
│   │   ├── @DHWsystem/      Water heaters
│   │   ├── @Appliance/      Stoves, dryers, dishwashers, fridges, custom
│   │   ├── @Glazing/        Windows, skylights
│   │   ├── @OpaqueSurface/  Walls, roofs
│   │   ├── @Package/        Ordered collections of ECMs
│   │   ├── @ECM/            Energy Conservation Measures
│   │   ├── @MeasureComponent/  Individual measure actions
│   │   ├── @KeyResults/     Result container (per-fuel energy, cost, CO₂)
│   │   ├── @Reference/      Static lookup tables (appliance data, HVAC curves)
│   │   └── +enum/           ApplianceType, SystemType, FuelType, …
│   └── +util/             # Small helpers: Excel ECM import, endpoint overrides, etc.
├── tests/
│   ├── testdata/            Template Excel files + a loaded_session.mat
│   ├── +ecetest/            Shared test fixtures (ecetest.testDataRoot)
│   ├── ECMPackage/          Example ECMs saved as .mat
│   └── Test*.m              Unit tests
├── examples/
│   ├── example_ECM_Package.xlsx   The Excel-ECM template referenced above
│   └── _build_example_ECM_workbook.py   Regenerator for that workbook
├── documentation/
│   ├── ECM_Package_Workbook_Guide.md    User guide for the Excel ECM workflow
│   ├── ECM_Property_Reference.md        Every editable property on every target class
│   ├── TECHNICAL_REFERENCE.md           Backend architecture deep-dive (for devs)
│   └── RetroCalc_User_Manual_v1.2.pdf   Full UI manual (also applies to the backend)
├── sandbox/runScripts/
│   ├── SiteFullRun.m          Full pipeline (HEA → L2 → calibrate → ECMs → export)
│   ├── SitePartialUtilitiesRun.m
│   └── SiteSetupExample.m
└── Retrocalc_openSource.prj # MATLAB project file — open this first
```

Only two folders are meant to be edited by a user: `tests/testdata/` (copy templates, swap in your project data) and `examples/` (edit the ECM workbook).

---

## Documentation

| Document | Audience | What it covers |
|---|---|---|
| **[RetroCalc_User_Manual_v1.2.pdf](documentation/RetroCalc_User_Manual_v1.2.pdf)** | End users | Full workflow walkthrough. Mostly describes the UI build but every concept applies to the backend. |
| **[ECM_Package_Workbook_Guide.md](documentation/ECM_Package_Workbook_Guide.md)** | ECM authors | Workbook schema, FilterCriteria DSL, Insert DSL, troubleshooting. |
| **[ECM_Property_Reference.md](documentation/ECM_Property_Reference.md)** | ECM authors | Every editable property on every target class, labeled array indices, every enum's members. **Auto-generated from source.** |
| **[TECHNICAL_REFERENCE.md](documentation/TECHNICAL_REFERENCE.md)** | Contributors | Class-by-class architecture, calculation algorithms, data structures. |

---

## Example: full retrofit analysis end-to-end

**[`sandbox/runScripts/SiteFullRun.m`](sandbox/runScripts/SiteFullRun.m)** is the canonical copy. Open it in MATLAB and hit Run — you'll get:

- All five workflow phases above, in order
- Console prints of `HEA.ResultsTable`, `Level2.ResultsTable`, `UsageComparisonTable`, `PackageSummaryTable`, and per-Package `ECMSummaryTables`
- An `ECM_Diagnostics.xlsx` written to `%TEMP%\RetroCalc_output\` with one sheet per `(Package, ECM)` state, each stacking twelve breakdown tables so you can trace exactly where every kWh / therm / gallon / dollar came from and went

Swap the five input paths at the top for your own project's Excel files to make it a real analysis.

---

## Contributing

Pull requests welcome. For architecture background, start with **[documentation/TECHNICAL_REFERENCE.md](documentation/TECHNICAL_REFERENCE.md)** — it walks through the class hierarchy, the compute pipeline, and the data structures that connect them.

Unit tests live under `tests/`. Run them with:

```matlab
runtests("tests/")
```

---

## Credits & License

Developed by [New Ecology, Inc.](https://newecology.org). ASHRAE Level 2-compliant outputs vetted and approved by **National Grid** and **Eversource** for use in Massachusetts multifamily rebate programs.

See [LICENSE.txt](LICENSE.txt) for licensing terms.

---

## Troubleshooting quickies

| Symptom | Cause | Fix |
|---|---|---|
| `"file is in use"` when reading an Excel file | Workbook is still open in Excel | Close the workbook before running MATLAB |
| `"API credentials not found in environment variables"` | Missing degreedays.net keys | See "API keys" section above — set `DEGREEDAYS_ACCOUNT_KEY` and `DEGREEDAYS_SECURITY_KEY`, restart MATLAB |
| Solar gains all zero + HTTP 403 warning | Missing NREL API key | See "API keys" section — set `NREL_API_KEY`, restart MATLAB |
| `ece:insufficientHistoricalDD` | Historical degree-day file doesn't cover enough years | Extend the file or lower `site.NumPastYearsToAverage` |
| ECM runs but nothing changes in results | Operation or UpdateType typo in Excel workbook | Check MATLAB warnings — each skipped row names the sheet + row number |
| `"openProject: ... not found"` | Not in the repo root | `cd` to the folder containing `Retrocalc_openSource.prj` |
