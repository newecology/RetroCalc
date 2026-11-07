# RetroCalc — Technical Reference

> This document covers the full backend/application architecture, class properties, key workflows, data structures, and object relationships. It is intended for developers and for AI-assisted development sessions. See `REVIEW_NOTES.md` for high-level strategic notes.

---

## Table of Contents

1. [Architecture Overview](#1-architecture-overview)
2. [Package Structure](#2-package-structure)
3. [Backend — Core Classes (`+ece`)](#3-backend--core-classes)
   - [ece.Site](#ecsite)
   - [ece.Building](#ecebuilding)
   - [ece.Location](#ecelocation)
   - [ece.KeyResults](#ecekeyresults)
   - [ece.ECM](#eceecm)
   - [ece.MeasureComponent](#ecemeasurecomponent)
   - [ece.Package](#ecepackage)
   - [Utility Classes (abstract + subtypes)](#utility-classes)
   - [Building Component Classes](#building-component-classes)
   - [ece.Reference](#ecereference)
4. [Enumerations (`+ece/+enum`)](#4-enumerations)
5. [Utility Functions (`+util`)](#5-utility-functions)
6. [Key Workflows & Pipelines](#6-key-workflows--pipelines)
   - [A. Site & Building Initialization](#a-site--building-initialization)
   - [B. Utility Usage Computation](#b-utility-usage-computation)
   - [C. HEA Computation](#c-hea-computation)
   - [D. Level2 Computation](#d-level2-computation)
   - [E. ECM Creation & Validation](#e-ecm-creation--validation)
   - [F. ECM/Package Application Pipeline](#f-ecmpackage-application-pipeline)
7. [Calculation Algorithms](#7-calculation-algorithms)
8. [Data Structures Reference](#8-data-structures-reference)
9. [Application Layer (`+application`)](#9-application-layer)
   - [application.Session](#applicationsession)
   - [Panel Hierarchy](#panel-hierarchy)
   - [ECMCreationPanel Detail](#ecmcreationpanel-detail)
10. [Object Ownership & Relationships](#10-object-ownership--relationships)
11. [Event & Listener System](#11-event--listener-system)
12. [Reference Data Files](#12-reference-data-files)

---

## 1. Architecture Overview

RetroCalc has a clean two-layer structure:

```
┌───────────────────────────────────────────────────────┐
│  APPLICATION LAYER  (+application)                    │
│  MLAPP panels (ComponentContainer/uifigure)           │
│  Session object — owns Site, ECMs, Packages           │
│  Panels observe Session/Site; call backend methods    │
└───────────────────────┬───────────────────────────────┘
                        │ calls methods on
┌───────────────────────▼───────────────────────────────┐
│  BACKEND  (+ece)                                      │
│  Site → Buildings → Components                        │
│  Utility meters → analyzeX() → usage tables           │
│  Building.computeHEA() / computeLevel2()              │
│  Package → ECM → MeasureComponent → applyMeasure()    │
│  KeyResults — value object for all result metrics     │
└───────────────────────────────────────────────────────┘
                        │ reads
┌───────────────────────▼───────────────────────────────┐
│  REFERENCE DATA  (ece.Reference + Location)           │
│  Appliance tables, HVAC tables, weather/DD data       │
│  TMY3 weather, historical degree days                 │
└───────────────────────────────────────────────────────┘
```

The backend has no dependency on the application layer. All computation is triggered by calling methods on `ece.Site` or `ece.Building` directly.

---

## 2. Package Structure

```
src/
├── +ece/                   # Core calculation engine
│   ├── @Building/          # Building object + all analysis methods
│   ├── @Site/              # Site object + orchestration methods
│   ├── @Location/          # Weather & degree-day data
│   ├── @ECM/               # Energy Conservation Measure
│   ├── @MeasureComponent/  # Individual measure within ECM
│   ├── @Package/           # Ordered collection of ECMs
│   ├── @KeyResults/        # Value class holding all result metrics
│   ├── @Utility/           # Abstract base for all meter types
│   ├── @Electricity/       # Electric meter
│   ├── @Gas/               # Gas meter
│   ├── @Water/             # Water meter
│   ├── @Oil/               # Oil meter
│   ├── @Propane/           # Propane meter
│   ├── @Reference/         # Static reference tables (appliances, HVAC, etc.)
│   ├── @Appliance/
│   ├── @OpaqueSurface/
│   ├── @Glazing/
│   ├── @BelowGradeSurface/
│   ├── @SlabOnGrade/
│   ├── @Space/
│   ├── @HeatCool/
│   ├── @DHWsystem/
│   ├── @DHWtanks/
│   ├── @DHWpipesMechRoom/
│   ├── @Pump/
│   ├── @Airmovers/
│   ├── @PlumbingFixture/
│   ├── @Solar/
│   └── +enum/              # All enumeration classes
│
├── +application/           # UI application layer
│   ├── @Session/           # Session state (owns Site, ECMs, Packages)
│   ├── +setup/             # Site/Building/Utilities setup panels
│   ├── +hea/               # HEA results display panels
│   ├── +level2/            # Level2 component input + results panels
│   ├── +packecm/           # ECM & Package creation panels
│   └── +analysis/          # Package analysis & comparison panels
│
├── +util/                  # Standalone helper functions
└── @RetroCalcApp/          # Compiled main app entry point
```

---

## 3. Backend — Core Classes

### ece.Site

**Type:** `handle`  
**Role:** Top-level container for a project. Owns all buildings and utility meters. Orchestrates analysis.

#### Properties

| Property | Type | Access | Notes |
|---|---|---|---|
| Name | string | Public | Site identifier |
| Location | ece.Location | Public, Observable | Weather and DD data |
| NumPastYearsToAverage | double | Public, Observable | Default 5; controls how many years of billing data are averaged |
| CarbonEqValue* | double | Public | Carbon factors for Electricity, Gas, Oil, Propane (kg/unit) |
| HeatingShoulderMonths | Nx1 double | Public | Month indices with heating/cooling overlap |
| CoolingShoulderMonths | Nx1 double | Public | |
| Buildings | Nx1 ece.Building | Private Set, Observable | Managed via addBuildings/removeBuildings |
| ElectricMeters | Nx1 ece.Electricity | Private Set, Observable | |
| GasMeters | Nx1 ece.Gas | Private Set, Observable | |
| WaterMeters | Nx1 ece.Water | Private Set, Observable | |
| OilMeters | Nx1 ece.Oil | Private Set, Observable | |
| PropaneMeters | Nx1 ece.Propane | Private Set, Observable | |
| HEA | ece.KeyResults | Private Set, Observable | Site-level aggregated HEA results |
| UserDefinedBuilding*Ratios | MxN double | Private, Observable | User-defined meter-to-building proportions |

**Dependent properties (computed on read):**

| Property | Notes |
|---|---|
| BuildingElecRatios | Computed from area proportions, or user-defined if set |
| BuildingGas/Water/Oil/PropaneRatios | Same pattern |
| NumBuildings / NumMeters | Counts |
| HasBuildings / HasMeters | Logical flags |
| UtilityMeters | Heterogeneous array of all meter types |
| Area | Sum of all building GrossArea_ft2 |
| UnitCostOf* | $/unit for each fuel type, derived from most recent meter data |

**Key methods:**

| Method | Description |
|---|---|
| `addBuildings(bldgs)` | Appends to Buildings, attaches listeners |
| `removeBuildings(idx)` | Removes by index |
| `addUtilities(meters)` | Appends to appropriate meter array |
| `removeUtilities(idx)` | Removes by index |
| `computeBuildingUtilityUsages()` | **Main orchestration** — runs all utility analyses |
| `computeHEA()` | Calls computeHEA on each Building, aggregates to Site.HEA |
| `computeLevel2()` | Calls computeLevel2 on each Building |
| `importUtilities()` | Import from Excel |
| `importBuildings()` | Import from Excel |
| `importSiteInputsData()` | Import site-level config |
| `importHistoricalDegreeDays()` | Load DD data |
| `fromInputExcelFiles()` *(static)* | Create fully populated Site from file set |

**Events:** `PropertyChanged` — fired when any Observable property changes.

---

### ece.Building

**Type:** `handle & matlab.mixin.Copyable`  
**Role:** The central computational object. Owns all Level2 components, analysis results, and applied packages.

#### Properties — Building Characteristics

| Property | Type | Notes |
|---|---|---|
| Name | string | |
| Location | ece.Location | Reference to Site's Location |
| GrossArea_ft2 | double | Total building area |
| GrossConditionedArea_ft2 | double | Used for EUI normalization |
| IntConditionedArea_ft2 | double | |
| PercentCondAreaCooled | double | 0–100 |
| NumberOfUnits | double | Dwelling units |
| NumberOfBedroomUnits | 1x4 double | [1BR, 2BR, 3BR, 4BR] unit counts |
| NumberOfOccupants | double | |
| PopulationType | ece.enum.PopulationType | |
| NumberOfStories | double | |
| YearOfConstruction | double | |
| ThermalMass | ece.enum.ThermalMassType | Light / Medium / Heavy |
| IntVolume_ft3 | double | |
| AirLeakageRate_cfm50perFt2 | double | |
| ShieldingClass | double | 1–5 |
| EffectiveLeakFactor | double | Default 0.055 |
| HeatCoolSeasonStartEndDates | 1x4 datetime | [HtgStart, HtgEnd, ClgStart, ClgEnd] |
| HVACStartEndTimePeriod1 | 1x2 double | Military time (e.g. [8, 18]) |
| HeatCoolSetpoints | 1x6 double | [HtgTP1, HtgTP2, ClgTP1, ClgTP2, ClgRH, HtgRH] |
| EnergySourceForDHW | ece.enum.EnergySourceType | |
| CarbonEqValue* | double | Per-building carbon factors |
| BuildingEnvelopeArea | double | Calculated from envelope components |
| TotalSolarGains | 12x1 double | Monthly solar gains kBtu |
| WeatherMonthly | 6x24 double | Monthly weather matrix [HDD, CDD, enthalpy, etc.] |

#### Properties — Utility Usage Tables (Private Set, Observable)

| Property | Description |
|---|---|
| AnnualElectricUsageTable | See §8 for columns |
| MonthlyElectricProfile | 13 rows (12 months + annual) |
| AnnualGasUsageTable | |
| MonthlyGasProfile | |
| AnnualWaterUsageTable | |
| MonthlyWaterProfile | |
| AnnualOilUsageTable | |
| MonthlyOilProfile | |
| AnnualPropaneUsageTable | |
| MonthlyPropaneProfile | |

#### Properties — Analysis Results (Private Set)

| Property | Type | Description |
|---|---|---|
| HEA | ece.KeyResults | HEA analysis results |
| Level2 | ece.KeyResults | Level2 modeled results |
| HasHEAResults | logical | Flag |
| HasLevel2Results | logical | Flag |
| RunStatsTable | table | Level2 detailed output |
| SpaceHeatingTable_kBtu | 13x16 table | Monthly heating by component |
| SpaceCoolingTable_kBtu | 13x16 table | Monthly cooling by component |
| SpaceCoolingTable_kWh | 13x16 table | |
| ElectricUsageTable | 13xN table | Monthly electric by category |
| HeatFuelTable | 13xN table | Monthly fuel by source |
| InternalGainsTable | 13xN table | Monthly internal gains |
| InternalGainsArray_kBtu | 24x3 double | [Sensible, Cooling, Latent] × 12 months |
| HeatLossComponentsTable | table | Heat loss per component |
| ApplianceResultsTable | table | Appliance energy breakdown |
| DHWenergyUsageTable | table | DHW energy consumption |
| DHWfuelTable | table | DHW fuel by source |

#### Properties — Level2 Component Collections

| Property | Type |
|---|---|
| Appliances | Nx1 ece.Appliance |
| OpaqueSurfaces | Nx1 ece.OpaqueSurface |
| GlazedSurfaces | Nx1 ece.Glazing |
| BelowGradeSurfaces | Nx1 ece.BelowGradeSurface |
| SlabOnGrade | Nx1 ece.SlabOnGrade |
| Spaces | Nx1 ece.Space |
| HeatCool | Nx1 ece.HeatCool |
| DHWsystems | Nx1 ece.DHWsystem |
| DHWtanks | Nx1 ece.DHWtanks |
| DHWpipesMechRoom | Nx1 ece.DHWpipesMechRoom |
| Pump | Nx1 ece.Pump |
| Airmovers | Nx1 ece.Airmovers |
| PlumbingFixtures | Nx1 ece.PlumbingFixture |
| Packages | Nx1 ece.Package |

#### Dependent Properties

| Property | Notes |
|---|---|
| CanUndergoHEA | True when all Annual*UsageTables are populated |
| NumPackages | Count of Packages |
| UsageComparisonTable | HEA vs Level2 side-by-side with deltas |
| PackageSummaryTable | Aggregated impact across all packages |
| DisplayPackageSummaryTable | String-formatted version |

#### Key Methods

| Method | Description |
|---|---|
| `computeHEA()` | Reads utility tables → populates Building.HEA |
| `computeLevel2()` | Full monthly energy balance → RunStatsTable + Level2 results |
| `analyzeElectricity(meters, ratios, DDtbl, numYears)` | Populates AnnualElectricUsageTable + MonthlyElectricProfile |
| `analyzeGas(...)` | Same pattern for gas |
| `analyzeWater(...)` | Same for water |
| `analyzeOil(...)` | Same for oil |
| `analyzePropane(...)` | Same for propane |
| `calculateEnvelopeArea()` | Sums all surface areas |
| `calculateSolarGains()` | Monthly solar through glazing |
| `calculateEnergyUsage()` | Top-level Level2 driver |
| `calculateSpaceHeatingEnergy()` | Monthly space heating loads |
| `calculateSpaceCoolingEnergy()` | Monthly space cooling loads |
| `applyPackages(pkgs)` | Applies packages sequentially, stores results |
| `addPackages(pkgs)` | Adds to Packages collection |
| `removePackages(idx)` | Removes by index |
| `addLevel2Objects(objs)` | Adds components to appropriate collection |
| `removeLevel2Objects(type, idx)` | Removes by type and index |
| `clearBuildingLevel2Objects()` | Clears all Level2 component arrays |
| `importLevel2ObjectData()` | Loads from Excel |
| `exportResultTables()` | Writes results to Excel |
| `fromBuildingExcelFile()` *(static)* | Create Building from Excel |

---

### ece.Location

**Type:** `handle & matlab.mixin.Copyable`  
**Role:** Holds weather and degree-day data. Shared between Site and all its Buildings.

| Property | Type | Notes |
|---|---|---|
| City | string | Default "Boston" |
| State | string | 2-letter, default "MA" |
| Latitude | double | Constrained [18.9, 71.39] |
| Longitude | double | Constrained [−180, −66.9] |
| WeatherDataTable | table | Hourly TMY3/TMY3x data (private set) |
| HistoricalDDTable | table | Columns: Date, HDD65, CDD70 (private set) |

**Dependent:**

| Property | Notes |
|---|---|
| GroundSurfaceTempAmplitude_F | From reference table, by lat/lon |
| GroundMeanAnnualTemp_F | From reference table |
| CDD_monthly | Monthly CDD by year (table) |
| HDD_monthly | Monthly HDD by year (table) |

**Key methods:** `importLocation()`, `importWeatherData()`, `importHistoricalDDTable()`, `importHistoricalDDTable_API()`

---

### ece.KeyResults

**Type:** Value class (not a handle).  
**Role:** Holds all summary metrics for one analysis run (HEA or Level2). Assigned to `Building.HEA`, `Building.Level2`, `Site.HEA`.

Because it's a value class, assigning it copies it — Building.HEA is independent from Site.HEA.

#### All Properties (double, public get/set)

| Property | Units |
|---|---|
| Electricity_kWh | kWh/year |
| Gas_therms | therms/year |
| Water_gallons | gallons/year |
| Oil_gallons | gallons/year |
| Propane_gallons | gallons/year |
| EUI | kBtu/ft²/year |
| AnnualCostOfElectricity | $/year |
| UnitCostOfElectricity | $/kWh |
| AnnualCostOfGas | $/year |
| UnitCostOfGas | $/therm |
| AnnualCostOfWater | $/year |
| UnitCostOfWater | $/gallon |
| AnnualCostOfOil | $/year |
| UnitCostOfOil | $/gallon |
| AnnualCostOfPropane | $/year |
| UnitCostOfPropane | $/gallon |
| AnnualCostTotal | $/year |
| CO2e | kg/ft²/year |
| WaterResidential_gallons | gallons/year |
| WaterNonResidential_gallons | gallons/year |
| Water_GPDBedroom | gallons/day/bedroom |
| SpaceHeat_kWh | kWh/year |
| SpaceHeatGas_therms | therms/year |
| SpaceHeatOil_kBtu | kBtu/year |
| SpaceHeatPropane_gallons | gallons/year |
| SpaceHeat_kBtuFt2 | kBtu/ft²/year |
| SpaceCool_kWh | kWh/year |
| SpaceCool_kBtuFt2 | kBtu/ft²/year |
| DHW_kWh | kWh/year |
| DHWGas_therms | therms/year |
| DHWOil_kBtu | kBtu/year |
| DHWPropane_gallons | gallons/year |
| DHW_kBtuFt2 | kBtu/ft²/year |
| NonHVACelec_kBtuFt2 | kBtu/ft²/year |
| NonHVACelec_kWh | kWh/year |
| ApplianceFuel_Therms | therms/year |
| ApplianceFuel_kBtuFt2 | kBtu/ft²/year |

**Dependent:** `ResultsTable` (single-row table of all above), `DisplayResultsTable` (string-formatted).

---

### ece.ECM

**Type:** `handle & matlab.mixin.Copyable`  
**Role:** Represents one Energy Conservation Measure — a named set of MeasureComponents applied sequentially.

| Property | Type | Notes |
|---|---|---|
| Name | string | ECM identifier |
| Description | string | |
| MeasureComponents | Nx1 ece.MeasureComponent | Ordered list of measures |
| ImpactOnBuilding | struct | Computed impact after application |

**Dependent:** `NumComponents`

**Key methods:**
- `applyECM(baseBldg)` — copies baseBldg, applies each MeasureComponent in sequence, returns updated building
- `readSourceFromFile(file, sheet)` *(static)* — creates ECM from Excel
- `readSourceFromTable(tbl, name)` *(static)*

---

### ece.MeasureComponent

**Type:** `handle`  
**Role:** The atomic unit of an ECM. Describes one specific change to one property on one class of building objects.

| Property | Type | Notes |
|---|---|---|
| ObjectOfReference | string | Target class (e.g., `"ece.Appliance"`) |
| ObjectVarName | string | Variable name within object |
| Operation | string | `"INSERT"` / `"UPDATE"` / `"DELETE"` |
| PropertyToChange | string | Property name on the target object |
| ValueForChange | any | New value (type depends on property) |
| UpdateType | string | `"REPLACE"` / `"ADD"` / `"MULTIPLY"` |
| FilterCriteria | string | Expression to match which objects are targeted |
| InsertQuantity | double | Number of objects to insert (INSERT only) |
| InsertedProperty | string | Serialized property string for inserted object |

**Key method:** `applyMeasure(bldg)` — finds matching objects via FilterCriteria, applies Operation + UpdateType logic.

---

### ece.Package

**Type:** `handle & matlab.mixin.Copyable`  
**Role:** An ordered collection of ECMs applied sequentially to a building.

| Property | Type | Notes |
|---|---|---|
| Name | string | |
| Description | string | |
| ECMs | Nx1 ece.ECM | Ordered list |
| ECMBuildings | Nx1 ece.Building | Transient; building state after each ECM |

**Dependent:** `NumECMs`, `ResultBuilding` (= ECMBuildings(end))

**Key methods:**
- `applyPackage(baseBldg)` — applies each ECM sequentially, stores intermediate buildings in ECMBuildings
- `addECMs(ecms)`, `removeECMS(idx)`
- `readSourceFromData(ecmArray, nameArray, pkgName)` *(static)*
- `readSourceFromFile(fileArray, sheetArray, pkgName)` *(static)*

---

### Utility Classes

**Abstract base:** `ece.Utility` (`handle & matlab.mixin.Heterogeneous`)

All meter classes inherit from `ece.Utility`. This allows `Site.UtilityMeters` to hold a mixed array via Heterogeneous.

#### Common Utility Properties

| Property | Type | Notes |
|---|---|---|
| Name | string | Meter identifier |
| NumberOfYears | double | Years of billing data |
| UtilityPayerType | ece.enum.UtilityPayerType | Who pays |
| UtilityServiceType | ece.enum.UtilityServiceType | What it serves |
| RealEstateType | ece.enum.RealEstateType | |
| RawUsageTable | table | Columns: StartDate, EndDate, Usage, Cost |
| AdjustedUsageTable | table | Billing-corrected version of RawUsageTable |

**Abstract properties (subclass must implement):** `AnnualUsageTable`, `MonthlyProfile`, `Cost`

**Sealed method:** `doBilling()` — calls the subclass `correctBilling()` on each element in an array.

#### ece.Electricity (additional properties)

| Property | Notes |
|---|---|
| IsBaseLoad / IsSpaceHeat / IsCooling / IsDHW | End-use flags |
| ElecBaseAdj | Base load adjustment |
| BaseElecAmplitude | Seasonal amplitude of base load |
| SeasonalAmpDHWUse | DHW seasonal amplitude |
| HeatFractionLimitsTable | 12x3 [Month, MinHeating%, MaxHeating%] |
| AccountNumber | double |

**Key method:** `createAnalysisTable(histDDTable)` — takes raw billing, corrects periods, creates AdjustedUsageTable with HDD/CDD alignment.

#### ece.Gas (additional properties)

| Property | Notes |
|---|---|
| IsSpaceHeat / IsDHW / IsCooking / IsInUnitClothesDryer / IsCommonAreaClothesDryer | End-use flags |
| SeasonalAmpDHWUse | |
| AccountNumber | |

**Key method:** `createAnalysisTable(histDDTable)`

#### ece.Water (additional properties)

| Property | Notes |
|---|---|
| IsResidential / IsBaseLoad / IsIrrigation / IsCoolingTower / IsOther | End-use flags |
| IrrigationGal / CoolingTowerGal / OtherGal | Known non-residential volumes |
| SummerWaterDist | 12x1 monthly irrigation distribution |
| AccountNumber | |

**Key method:** `updateAdjustedUsageTable()` (no DD correction needed for water)

#### ece.Oil, ece.Propane

Similar to Gas. Both use `createAnalysisTable(histDDTable)`.

---

### Building Component Classes

All are `handle & matlab.mixin.Copyable`. This allows Building to be deep-copied when ECMs are applied. Each has a `readSourceData()` static method to load from Excel/reference tables.

#### ece.Appliance

| Property | Type | Notes |
|---|---|---|
| Name | string | |
| ApplianceType | ece.enum.ApplianceType | 13 types (stoves, dishwashers, dryers, refrigerators, etc.) |
| SubType | string | Variant (front-load, etc.) |
| EfficiencyLevel | double | 1=Standard, 2=EnergyStar; volume (cu.ft.) for refrigerators |
| Quantity | double | |
| FracUnitsServed | double | 0–1 |
| resultsArray | 4x13 double | [GasTherms, EleckWh, SensibleGains, LatentGains] × [12 months + annual] |

**Dependent:** `Code`, `SelectableSubtypes`, `EffLevelDescriptor`, `ApplianceCategory`

#### ece.OpaqueSurface

| Property | Type | Notes |
|---|---|---|
| Name | string | |
| OpaqueSurfaceType | ece.enum.OpaqueSurfaceType | Wall, Roof, AtticFloor, Door, etc. |
| Area_ft2 | double | |
| RValue | double | hr·ft²·°F/Btu |
| SurfaceEmittance | double | |
| Azimuth_deg | double | 0=North |
| Tilt_deg | double | 90=vertical |
| ShadingMonthly | 12x1 double | Monthly shading factors (0–1) |

**Dependent:** `HeatLossCoeff` (= Area/RValue), `ShadingTable`

#### ece.Glazing

| Property | Type | Notes |
|---|---|---|
| Name | string | |
| GlazingType | ece.enum.GlazingType | Window, Skylight, CurtainWall |
| Quantity | double | Number of windows |
| Width_in / Height_in / FrameWidth_in | double | Frame default 2 in |
| Uvalue | double | Btu/hr·ft²·°F |
| SHGC | double | Solar heat gain coefficient |
| Azimuth_deg / Tilt_deg | double | |
| ShadingMonthly | 12x1 double | |

**Dependent:** `GlazedArea`, `HeatLossCoeff` (= Area × Uvalue), `ShadingTable`

#### ece.Space

| Property | Type | Notes |
|---|---|---|
| Name | string | |
| SpaceType | ece.enum.SpaceType | Residential, Corridor, Commercial, etc. |
| Area_ft2 | double | |
| LPD_Wft2 | double | Lighting power density W/ft² |
| EPD_Wft2 | double | Equipment power density W/ft² |
| SensGain_BtuHrPerson | double | Sensible heat gain per person |
| LatGain_BtuHrPerson | double | Latent heat gain per person |
| LgtEFLHday / EquipEFLHday / PeopleEFLHday | double | Full-load hours per day |
| Ft2person | double | Area per person |

#### ece.HeatCool

| Property | Type | Notes |
|---|---|---|
| Name | string | |
| SystemType | ece.enum.SystemType | e.g., condGasBoilerOAreset, heatPumpElectric |
| SystemFunction | ece.enum.SystemFunction | HeatingOnly / CoolingOnly / Both |
| EnergySource | ece.enum.EnergySourceType | |
| Quantity | double | |
| HeatCapacityEach / CoolCapacityEach | double | |
| HeatCapUnits / CoolCapUnits | enum | |
| HeatFrac / CoolFrac | double | Fraction of building served |
| ControlskW | double | Controls electricity draw |
| DistEffHtg / DistEffClg | double | Distribution efficiency |
| HeatEff / CoolEff | double | System efficiency |
| HeatEffUnits / CoolEffUnits | enum | AFUE, COP, EER, SEER, etc. |

**Dependent:** `HeatingEfficiencyCurve`, `CoolingEfficiencyCurve` (1x5 polynomial curve fits)

#### ece.BelowGradeSurface

Basement and crawlspace surfaces. Properties include area, perimeter, depth, wall R-value, floor R-value, soil conductivity.

#### ece.SlabOnGrade

Grade-level slabs. Properties include area, perimeter, insulation R-value, insulation depth.

#### ece.DHWsystem

| Property | Notes |
|---|---|
| SystemType | ece.enum.DHWSystemType |
| EnergySource | ece.enum.EnergySourceType |
| Efficiency | Thermal or EF |
| EfficiencyUnits | ece.enum.DHWEfficiencyUnits |
| Quantity | Number of systems |
| FracUnitsServed | |

#### ece.DHWtanks

Tank storage. Properties: volume, standby loss, insulation R-value, location (heated/unheated space).

#### ece.DHWpipesMechRoom

Mechanical room pipe distribution losses. Properties: pipe type, diameter, length, insulation.

#### ece.Pump, ece.Airmovers

Circulation pumps and ventilation systems. Properties include motor power, flow rates, schedule.

#### ece.PlumbingFixture

| Property | Notes |
|---|---|
| FixtureType | ece.enum.PlumbingFixtureType (Lavatory, Toilet, Shower, Tub, Kitchen) |
| FlowRate_GPM | |
| TemperatureOfUse_F | |
| MinutesPerUsePerDay | |
| FracUnitsServed | |
| Quantity | |

---

### ece.Reference

**Type:** Static-only class (all Constant properties, all Static methods).  
**Role:** Central lookup for all reference tables used in calculations.

Key tables (loaded at class instantiation from Excel/CSV files):

| Constant | Description |
|---|---|
| ApplianceDataTable | Energy use by appliance type, subtype, efficiency level |
| HeatSysData | Heating system efficiency curves by SystemType |
| CoolSysData | Cooling system efficiency curves by SystemType |
| SpaceTypeDataTable | LPD, EPD, occupancy defaults by SpaceType |
| StoveDataTbl / DryerDataTbl | Gas stove and dryer energy data |
| StackMatrix / ShieldMatrix | Infiltration calculation matrices |
| AirLeakageRateTable | Air leakage by building type |
| ThermalCapBldgTable | Thermal capacitance by ThermalMassType |
| PipeHeatLoss140FTable | DHW pipe heat loss |
| SummerPeakWaterMonthDistTable | Seasonal water distribution profile |
| GroundSurfaceTempAmpTable | Ground temp amplitude by region |
| SoilConductivityTable | Soil thermal conductivity |
| OilTypekBtuTable | kBtu per gallon by oil type |
| WeatherCityData | City coordinates for weather station matching |

---

## 4. Enumerations

All enumerations live in `+ece/+enum/` and inherit from `ece.enum.BaseList` (abstract).

| Enum Class | Key Members | Used By |
|---|---|---|
| ApplianceType | InUnitGasStoves, InUnitElectricStoves, InUnitDishwashers, InUnitClotheswashers, InUnitGas/ElectricClothesDryers, Refrigerators, CommonAreaClotheswashers, CommonAreaGas/ElectricClothesDryers, CommercialDishwashers, CommercialOvenElectric, CommercialGriddleElectric | Appliance.ApplianceType |
| ApplianceCategory | Stove, Dishwasher, Clotheswasher, Dryer, Refrigerator, None | Appliance.ApplianceCategory (dependent) |
| SpaceType | Residential, Corridor, Commercial, etc. | Space.SpaceType |
| OpaqueSurfaceType | Wall, Roof, AtticFloor, Door, OverhangingFloor, Adiabatic | OpaqueSurface.OpaqueSurfaceType |
| GlazingType | Window, Skylight, CurtainWall | Glazing.GlazingType |
| ThermalMassType | Light, Medium, Heavy | Building.ThermalMass |
| PopulationType | Residential, Commercial, Mixed, etc. | Building.PopulationType |
| SystemType | condGasBoilerOAreset, heatPumpElectric, … (30+ types) | HeatCool.SystemType |
| SystemFunction | HeatingOnly, CoolingOnly, BothHeatingAndCooling | HeatCool.SystemFunction |
| EnergySourceType | Electricity, Gas, Oil, Propane, DistrictSteam, etc. | HeatCool, DHWsystem, Building |
| UtilityPayerType | Tenant, Landlord, Mixed, etc. | All Utility subclasses |
| UtilityServiceType | WholeBuilding, CommonArea, IndividualUnit, etc. | All Utility subclasses |
| RealEstateType | Residential, Commercial, Mixed, etc. | All Utility subclasses |
| HeatCapUnits | kBtuPerHour, Watts, BTU_hr, etc. | HeatCool |
| CoolCapUnits | kBtuPerHour, Tons, Watts, etc. | HeatCool |
| HeatingEfficiencyUnits | ThermalEfficiency, AFUE, COP, etc. | HeatCool |
| CoolingEfficiencyUnits | EER, SEER, COP, etc. | HeatCool |
| ApplyPackageMethod | Sequential, Simultaneous, Other | Package |
| OilType | Type1, Type2, Type4, Type6 | Oil meter |
| PlumbingFixtureType | Lavatory, Toilet, Shower, Tub, Kitchen | PlumbingFixture |
| PipeType | CopperTubePipe, PEXTubePipe, etc. | DHWpipesMechRoom |
| PipeDiameter | Half_inch, ThreeQuarter_inch, etc. | DHWpipesMechRoom |
| RecircLoopType | None, TankHeater, Pump | DHWsystem |
| RefrigeratorVintage | Pre1990, 1990_1999, 2000_2009, 2010_Present | Appliance (refrigerators) |

---

## 5. Utility Functions

All in `src/+util/`. Called as `util.functionName(...)`.

| Function | Signature | Purpose |
|---|---|---|
| `calcImpactOnBuilding` | `impact = calcImpactOnBuilding(baseBldg, updatedBldg)` | Runs Level2 on both buildings, returns struct with `difference` and `percentage` tables. Core of ECM impact calculation. |
| `convertMonthsToVector` | `vec = convertMonthsToVector(months)` | Converts month data to consistent vector format. |
| `lookupPropertyDataType` | `propDataType = lookupPropertyDataType(mainObjectTbl, objName, propName)` | Returns MATLAB class name of a property from the ECMCreationPanel's MainObjectTbl. Returns `""` if not found. |
| `setValueColumnFormat` | `setValueColumnFormat(tblObj, colIdx, propDataType)` | Switches a uitable column to an enum dropdown (if propDataType is an enum class) or plain char input. Must be called before the cell editor opens (from CellSelectionCallback). |
| `validateMeasureComponentValue` | `[isValid, normalizedValue, message] = validateMeasureComponentValue(propDataType, rawValue)` | Validates a raw user-typed value against the property's type. Handles enums (case-insensitive match), numeric, string/char. Returns normalized value on success. |
| `nanSum` | `s = nanSum(x)` | Sum ignoring NaN values. |
| `setDropDownItemsData` | `setDropDownItemsData(dropdown, items)` | Populates a dropdown component with items. |

---

## 6. Key Workflows & Pipelines

### A. Site & Building Initialization

```
User Action (Setup panels)
  │
  ▼
application.Session
  └── Session.Site = ece.Site()
        │
        ├── Site.Location = ece.Location()
        │     Location.importLocation(city, state)
        │     Location.importWeatherData()
        │     Location.importHistoricalDDTable()  ← or API
        │
        ├── Site.addBuildings([ece.Building, ...])
        │     Building properties set (area, occupants, etc.)
        │     Building.Location = Site.Location  (shared reference)
        │
        └── Site.addUtilities([ece.Electricity, ece.Gas, ...])
              Utility.RawUsageTable populated from Excel import
              BuildingXRatios set (area-proportion or user-defined)
```

### B. Utility Usage Computation

Entry point: `Site.computeBuildingUtilityUsages()`

```
For each ElectricMeter:
    ElectricMeter.createAnalysisTable(Site.Location.HistoricalDDTable)
    ┌─ Corrects uneven billing periods
    └─ Creates AdjustedUsageTable with HDD/CDD alignment

For each Building (vectorized call):
    Building.analyzeElectricity(
        ElectricMeters, BuildingElecRatios, HistDDTable, NumPastYearsToAverage)
    ┌─ Allocates each meter's usage to this building via ratios
    ├─ Splits usage: Base, DHW, Heat, Cool (regression on DD)
    ├─ Populates Building.AnnualElectricUsageTable
    └─ Populates Building.MonthlyElectricProfile

Repeat pattern for Gas, Oil, Propane (with DD-based splitting)
Repeat for Water (no DD correction; residential/nonresidential split)
```

**After this method completes**, every Building has populated Annual*UsageTables and `Building.CanUndergoHEA` returns `true`.

### C. HEA Computation

Entry point: `Site.computeHEA()` → `Building.computeHEA()`

```
Building.computeHEA():
  1. Guard: if ~Building.CanUndergoHEA → set default HEA, warn, return
  2. Extract from AnnualElectricUsageTable row 1:
       Electricity_kWh, SpaceHeat_kWh, SpaceCool_kWh, DHW_kWh, NonHVAC
  3. Extract from AnnualGasUsageTable row 1:
       Gas_therms, SpaceHeatGas_therms, DHWGas_therms, StoveDryer
  4. Extract from AnnualWaterUsageTable row 1:
       Water_gallons, ResidentialGals
  5. Similar for Oil and Propane
  6. Compute EUI: sum all fuels converted to kBtu / GrossConditionedArea
  7. Compute AnnualCost* from table row 1 Cost column
  8. Compute UnitCost* = Cost(end) / Usage(end) [most recent year]
  9. Compute CO2e: usage × carbon rates / GrossConditionedArea
  10. Compute Water metrics (GPD/bedroom)
  11. Compute SpaceHeat_kBtuFt2, SpaceCool_kBtuFt2, DHW_kBtuFt2
  12. Set Building.HEA = hea (KeyResults)
  13. Set Building.HasHEAResults = true

Site.computeHEA():
  for each Building: Building.computeHEA()
  Aggregate summable properties across buildings
  Area-weight EUI and intensity metrics
  Set Site.HEA
```

**Note on empty utility tables:** `computeHEA` initializes empty utility tables (6-row default) for any fuel not present, so downstream code reading row 1 or row `end` doesn't error on missing utilities.

### D. Level2 Computation

Entry point: `Building.computeLevel2()`

```
For each month 1–12 (+ annual summary in row 13):

  1. Weather:
       HDD65, CDD70 from HistoricalDDTable
       Temperature, wind speed, enthalpy from WeatherDataTable

  2. Solar gains (Glazing):
       For each GlazedSurface:
         SolarGain = SolarRadiation(azimuth, tilt, month) × Area × SHGC × ShadingFactor
       TotalSolarGains(month) = sum across all glazing

  3. Internal gains (Spaces, Appliances):
       Lighting: Area × LPD × LgtEFLHday
       Equipment: Area × EPD × EquipEFLHday
       People: (Area/Ft2person) × SensGain × PeopleEFLHday
       Appliances: Appliance.resultsArray columns 3-4 (sensible, latent)

  4. Heat loss:
       Opaque: sum(Area_i / RValue_i) × ΔT
       Glazing: sum(Area_i × Uvalue_i) × ΔT
       Infiltration: ACH × Volume × 0.018 × ΔT
       Below-grade: perimeter/slab losses
       Total HeatLoss coefficient H [Btu/hr/°F]

  5. Heating utilization factor (γ_h):
       Ratio of heat gains to heat loss
       Applies ASHRAE-style formula with thermal mass correction

  6. Space heating load:
       Load = (H × HDD × 24) - γ_h × (SolarGains + IntGains)
       Applied only during heating season hours

  7. Space cooling load:
       Similar with CDD and cooling utilization factor

  8. System energy:
       SpaceHeat fuel = Load / HeatEff  (by energy source)
       SpaceCool elec = Load / CoolEff
       DHW: tank standby + pipe losses + fixture demand
       Non-HVAC: appliance + lighting electricity

  9. Aggregate into RunStatsTable, SpaceHeatingTable, etc.
  10. Populate Building.Level2 (KeyResults) from RunStatsTable
  11. Set Building.HasLevel2Results = true
```

### E. ECM Creation & Validation

Entry point: `+application/+packecm/ECMCreationPanel.mlapp`

```
UI: ECMCreationPanel
  │
  ├── MeasureComponentsUITable: rows = MeasureComponents
  │     Columns: Operation | ObjectClass | Property | Criteria | UpdateType | Value
  │
  ├── InsertUITable: shows properties of selected MeasureComponent
  │     Column 1 (read-only): property name
  │     Column 2 (editable): value
  │     CellSelectionCallback → InsertUITableCellSelection
  │       → util.lookupPropertyDataType(MainObjectTbl, objName, propName)
  │       → util.setValueColumnFormat(InsertUITable, 2, propDataType)
  │         Sets column 2 to enum dropdown OR 'char' text input
  │
  ├── On value edit → InsertUITableCellEdit
  │       → util.validateMeasureComponentValue(propDataType, rawValue)
  │         Returns: isValid, normalizedValue, message
  │       → If valid: store normalizedValue in MeasureComponent
  │       → If invalid: show error, revert cell
  │
  └── MainObjectTbl: table with columns [Classes, PropertyName, DataType]
        Built at startup from ECM object metadata
        Used by lookupPropertyDataType to resolve property types
```

### F. ECM/Package Application Pipeline

```
Package.applyPackage(baseBldg):
  currentBldg = copy(baseBldg)     ← deep copy via Copyable
  
  for each ECM in Package.ECMs:
    ECM.applyECM(currentBldg):
      updatedBldg = copy(currentBldg)
      
      for each MC in ECM.MeasureComponents:
        MC.applyMeasure(updatedBldg):
          
          if INSERT:
            newObj = create instance of MC.ObjectOfReference
            parse MC.InsertedProperty → set object properties
            add newObj to updatedBldg.[collection] (MC.InsertQuantity times)
          
          if UPDATE:
            targets = find objects in updatedBldg matching MC.FilterCriteria
            for each target:
              if REPLACE: target.(MC.PropertyToChange) = MC.ValueForChange
              if ADD:     target.(MC.PropertyToChange) += MC.ValueForChange
              if MULTIPLY: target.(MC.PropertyToChange) *= MC.ValueForChange
          
          if DELETE:
            targets = find objects matching MC.FilterCriteria
            remove targets from updatedBldg.[collection]
    
    Package.ECMBuildings(end+1) = updatedBldg
    currentBldg = updatedBldg
  
  Package.ResultBuilding = Package.ECMBuildings(end)

Impact calculation (util.calcImpactOnBuilding):
  if ~baseBldg.HasLevel2Results: baseBldg.computeLevel2()
  updatedBldg.computeLevel2()
  difference = baseBldg.RunStatsTable - updatedBldg.RunStatsTable
  percentage = 100 × difference ./ baseBldg.RunStatsTable
  → stored in Building.ECMSummaryTables, Building.PackageSummaryTable
```

---

## 7. Calculation Algorithms

### HEA End-Use Splitting

Utility billing data is split into end-use categories using degree-day regression:

**Electricity:**
- Regression of monthly kWh vs HDD and CDD to separate heating, cooling, and base load
- Base = intercept term (lighting, plug loads, appliances)
- Heat = coefficient × HDD
- Cool = coefficient × CDD
- BasePlusDHW = Base when DHW is electric (no seasonal separation)
- `HeatFractionLimitsTable` constrains the heating fraction per month (prevents negative or >100% allocations)

**Gas:**
- Regression of monthly therms vs HDD
- SpaceHeat = HDD component
- StoveDryer = constant fraction of non-heating gas (based on meter flags)
- DHW = remainder

**Water:**
- No DD regression; split by meter flags and `SummerWaterDist` profile
- Irrigation separated by known monthly pattern

### Level2 Space Heating Load

Based on a monthly energy balance with a utilization factor:

```
H = Σ(A_i/R_i) + Σ(A_i × U_i) + ACH × Vol × 0.018   [Btu/hr/°F]

Gains = SolarGains + InternalGains   [kBtu/month]

γ = f(Gains / (H × HDD × 24))    [utilization factor, 0–1]

HeatingLoad = H × HDD × 24 - γ × Gains   [kBtu/month]
HeatingFuel = HeatingLoad / (HeatEff × DistEffHtg)
```

ThermalMass affects γ via the ratio parameter in the utilization function.

### Level2 DHW Load

```
FixtureLoad = Σ Quantity_i × FlowRate_i × MinutesPerUsePerDay × ΔT × density × FracUnitsServed
TankStandbyLoss = function of tank volume, insulation, and ambient temperature
PipeLoss = function of pipe length, diameter, insulation, temperature differential
TotalDHW = FixtureLoad + TankStandbyLoss + PipeLoss
DHWFuel = TotalDHW / SystemEfficiency
```

### ECM Impact

```
SavingsAbsolute = BaseBldg.RunStatsTable - UpdatedBldg.RunStatsTable
SavingsPercent = 100 × SavingsAbsolute ./ BaseBldg.RunStatsTable

NaN handling: if base value is 0, percentage = NaN (no division by zero)
```

---

## 8. Data Structures Reference

### AnnualElectricUsageTable

Rows represent different aggregation periods (row 1 = averaged annual, row 2 = HDD-adjusted, row 3 = normalized per area, rows 4–6 = individual years).

| Column | Type | Description |
|---|---|---|
| Property | string/cell | Row label (e.g., "Average Annual") |
| MeterCount | double | Number of meters contributing |
| HDD65 | double | Heating degree days for this period |
| CDD70 | double | Cooling degree days for this period |
| TotalkWh | double | Total electricity use |
| Base | double | Non-HVAC, non-DHW electricity |
| DHW | double | Domestic hot water electricity |
| Heat | double | Space heating electricity |
| Cool | double | Space cooling electricity |
| BasePlusDHW | double | Base + DHW (when DHW cannot be separated) |
| Cost | double | Total cost $ |
| HeatSlope | double | Regression coefficient (kWh/HDD) |
| CoolSlope | double | Regression coefficient (kWh/CDD) |

### AnnualGasUsageTable

| Column | Type | Description |
|---|---|---|
| Property | string/cell | Row label |
| MeterCount | double | |
| HDD65 | double | |
| TotalTherms | double | Total gas use |
| StoveDryerTherms | double | Cooking and clothes drying |
| DHWTherms | double | Domestic hot water |
| SpaceHeatTherms | double | Space heating |
| Cost | double | |
| HeatSlope | double | Regression coefficient (therms/HDD) |

### AnnualWaterUsageTable

| Column | Type | Description |
|---|---|---|
| Property | string/cell | |
| MeterCount | double | |
| Gallons | double | Total water use |
| AdjGallons | double | Adjusted (non-irrigation) gallons |
| ResidentialGals | double | Residential portion |
| Cost | double | |

### AnnualOilUsageTable

| Column | Description |
|---|---|
| Property | Row label |
| MeterCount | |
| HDD65 | |
| TotalGallons | |
| DHWGallons | |
| SpaceHeatGallons | |
| DHWkBtu | DHW in kBtu |
| SpaceHeatkBtu | Space heating in kBtu |
| Cost | |
| HeatSlope | |

### AnnualPropaneUsageTable

| Column | Description |
|---|---|
| Property | |
| MeterCount | |
| HDD65 | |
| TotalGallons | |
| StoveDryerGallons | |
| DHWGallons | |
| SpaceHeatGallons | |
| Cost | |
| HeatSlope | |

### Location.HistoricalDDTable

| Column | Type | Description |
|---|---|---|
| Date | datetime | Start of billing period |
| HDD65 | double | Heating degree days (base 65°F) |
| CDD70 | double | Cooling degree days (base 70°F) |

### ECMCreationPanel.MainObjectTbl

| Column | Type | Description |
|---|---|---|
| Classes | string | MATLAB class name (e.g., "ece.Appliance") |
| PropertyName | cell of string arrays | All settable property names for that class |
| DataType | cell of string arrays | MATLAB class of each property |

Used by `util.lookupPropertyDataType` to resolve a property's type at ECM creation time.

---

## 9. Application Layer

### application.Session

**Type:** `handle`  
**Role:** Singleton-like owner of the entire application state. Created once by the main app; all panels receive a reference to it.

| Property | Type | Notes |
|---|---|---|
| Site | ece.Site | The active site |
| Packages | Nx1 ece.Package | Library of available packages |
| ECMs | Nx1 ece.ECM | Library of available ECMs |

**Dependent:** `NumPackages`, `NumECMs`

**Key methods:** `saveSession()`, `loadSession()`, `addPackages()`, `removePackages()`, `addECMs()`, `removeECMs()`

---

### Panel Hierarchy

```
RetroCalcApp (main app, @RetroCalcApp)
├── Setup Tab
│   ├── MainSetupPanel
│   │   ├── SiteSetupPanel
│   │   ├── BuildingSetupOrganizerPanel
│   │   │   └── BuildingSetupPropertiesPanel
│   │   └── UtilitiesSetupOrganizerPanel
│   │       ├── ElectricUtilityPropertiesPanel
│   │       ├── GasUtilityPropertiesPanel
│   │       ├── WaterUtilityPropertiesPanel
│   │       ├── OilUtilityPropertiesPanel
│   │       └── PropaneUtilityPropertiesPanel
│
├── HEA Tab
│   └── MainHEAPanel
│       ├── BuildingHEAOrganizerPanel
│       ├── BuildingHEAResultsPanel
│       └── SiteHEAResultsPanel
│
├── Level2 Tab
│   └── MainLevel2CalibrationPanel
│       ├── Level2ObjectOrganizerPanel
│       │   (manages Building component collections)
│       ├── BuildingLevel2PropertiesPanel
│       ├── AppliancePropertiesPanel
│       ├── SpacePropertiesPanel
│       ├── OpaqueSurfacePropertiesPanel
│       ├── GlazingPropertiesPanel
│       ├── BelowGradeSurfacePropertiesPanel
│       ├── SlabOnGradePropertiesPanel
│       ├── HeatCoolPropertiesPanel
│       ├── DHWSystemPropertiesPanel
│       ├── DHWTankPropertiesPanel
│       ├── DHWPipesMechRoomPropertiesPanel
│       ├── PumpPropertiesPanel
│       ├── AirMoversPropertiesPanel
│       ├── PlumbingFixturePropertiesPanel
│       └── Level2CalibrationResultsPanel
│
├── ECM/Package Tab
│   └── MainECMPackagePanel
│       ├── ECMOrganizerPanel
│       ├── ECMCreationPanel          ← see detail below
│       ├── PackageOrganizerPanel
│       └── PackageCreationPanel
│
└── Analysis Tab
    └── MainPackageAnalysisPanel
        ├── PackageAssignmentPanel
        ├── PackageSummaryPanel
        └── ECMSummaryPanel
```

---

### ECMCreationPanel Detail

**File:** `src/+application/+packecm/ECMCreationPanel.mlapp`  
**Type:** `matlab.ui.componentcontainer.ComponentContainer`

This is the most complex panel. It manages the creation and editing of ECM MeasureComponents.

#### Key UI Components

| Component | Role |
|---|---|
| `MeasureComponentsUITable` | Main table — one row per MeasureComponent. Columns: Operation, ObjectClass, Property, FilterCriteria, UpdateType, Value |
| `InsertUITable` | Secondary table showing all settable properties of the currently-selected MeasureComponent's target object. Column 1 = property name (read-only), Column 2 = value (editable) |
| `FilterCriteriaUITable` | Table for defining filter expressions to target specific objects |
| `ObjectIndexDropDown` | Selects which object within the building to view/insert |
| `ViewObjectUITable` | Shows current property values of the selected object in the building |
| `PropHelperTable` | Displays valid enum values when an enum property is selected in Edit/Delete tab |

#### Key Internal State

| Property | Type | Description |
|---|---|---|
| InputBuilding | ece.Building | The building being used to construct the ECM |
| ECM | ece.ECM | The ECM being created/edited |
| MainObjectTbl | table | [Classes, PropertyName, DataType] — drives property lookups |
| ObjectList | categorical | List of available object classes |
| SelectedMCRow | double | Currently selected MeasureComponent row index |

#### Key Callbacks & Data Flow

```
User selects row in MeasureComponentsUITable
  → MeasureComponentsUITableCellSelection callback
  → updateInsertUITableForSelectedMC()
      → populate InsertUITable with properties of MC.ObjectOfReference
      → set InsertUITable.ColumnFormat = {'char', 'char'}  (default)

User clicks cell in InsertUITable
  → InsertUITableCellSelection callback
  → util.lookupPropertyDataType(MainObjectTbl, objName, propName)
  → util.setValueColumnFormat(InsertUITable, 2, propDataType)
      if enum: column 2 → dropdown of enum member names
      if double/string: column 2 → 'char' text input

User edits value in InsertUITable column 2
  → InsertUITableCellEdit callback
  → util.validateMeasureComponentValue(propDataType, rawValue)
      → returns [isValid, normalizedValue, message]
  → if valid: update MeasureComponent.ValueForChange = normalizedValue
  → if invalid: revert cell, show warning dialog
```

#### Persistence Issue (known)

`.mlapp` files are ZIP archives containing `matlab/document.xml` (class code) and `appdesigner/appModel.mat` (App Designer internal model). App Designer regenerates `document.xml` from `appModel.mat` on save, stripping any code not registered in the model.

The three methods involved in the Insert table dropdown (`InsertUITableCellSelection`, and the now-external `util.lookupPropertyDataType`, `util.setValueColumnFormat`) were previously vulnerable to being erased on App Designer save. The current architecture keeps only `InsertUITableCellSelection` inside the mlapp (registered as a proper callback), while the two utility functions live in `+util` as plain `.m` files immune to App Designer's save cycle.

If the mlapp is ever re-saved in App Designer and the dropdown stops working, check that `InsertUITableCellSelection` is still present in the class code and that `InsertUITable.ColumnFormat = {'char', 'char'}` is still in `postSetupFcn`.

---

## 10. Object Ownership & Relationships

```
application.Session (1 per app instance)
  ├── Site (ece.Site)                            [owned]
  │   ├── Location (ece.Location)                [owned]
  │   ├── Buildings[] (ece.Building)             [owned]
  │   │   ├── Location                           [shared ref → Site.Location]
  │   │   │
  │   │   ├── Level2 Components:
  │   │   │   ├── Appliances[]
  │   │   │   ├── OpaqueSurfaces[]
  │   │   │   ├── GlazedSurfaces[]
  │   │   │   ├── BelowGradeSurfaces[]
  │   │   │   ├── SlabOnGrade[]
  │   │   │   ├── Spaces[]
  │   │   │   ├── HeatCool[]
  │   │   │   ├── DHWsystems[]
  │   │   │   ├── DHWtanks[]
  │   │   │   ├── DHWpipesMechRoom[]
  │   │   │   ├── Pump[]
  │   │   │   ├── Airmovers[]
  │   │   │   └── PlumbingFixtures[]
  │   │   │
  │   │   ├── Packages[] (ece.Package)           [owned]
  │   │   │   └── ECMs[] (ece.ECM)               [owned]
  │   │   │       └── MeasureComponents[]        [owned]
  │   │   │
  │   │   ├── HEA (ece.KeyResults)               [value, owned]
  │   │   └── Level2 (ece.KeyResults)            [value, owned]
  │   │
  │   ├── ElectricMeters[] (ece.Electricity)     [owned]
  │   ├── GasMeters[] (ece.Gas)                  [owned]
  │   ├── WaterMeters[] (ece.Water)              [owned]
  │   ├── OilMeters[] (ece.Oil)                  [owned]
  │   ├── PropaneMeters[] (ece.Propane)          [owned]
  │   └── HEA (ece.KeyResults)                   [value, aggregated from Buildings]
  │
  ├── Packages[] (ece.Package)                   [library reference]
  └── ECMs[] (ece.ECM)                           [library reference]
```

**Copy semantics:**
- `ece.Building`, all component classes, `ece.Package`, `ece.ECM` are `Copyable` → deep copy when ECMs are applied
- `ece.KeyResults` is a value class → assignment always copies
- `ece.Location` is a handle → `Building.Location` is a shared reference to `Site.Location`

---

## 11. Event & Listener System

Observable properties fire `PropertyChanged` events. The listener chain is:

```
ece.Utility (each meter)
  → fires PropertyChanged when any Observable property changes
  → Site listens: Site.onInternalPropertiesChanged()
      → propagates Site.PropertyChanged

ece.Building (each building)
  → fires PropertyChanged when any Observable property changes
  → Site listens: Site.onInternalPropertiesChanged()
      → propagates Site.PropertyChanged

ece.Site
  → fires PropertyChanged
  → application.Session (and UI panels) listen
      → triggers UI refresh for changed data
```

**Listener setup:** `Site.updateObjectArrayListeners()` is called whenever buildings or meters are added/removed. It attaches `proplistener` objects to each element. Listeners stored in `Site.BuildingPropsChangedListeners`, `Site.ElectricUtilityPropsChangedListeners`, etc.

**Purpose:** Panels subscribe to `Site.PropertyChanged` rather than polling; any backend property change automatically propagates to the UI without explicit coupling between specific backend properties and specific UI panels.

---

## 12. Reference Data Files

All stored in `src/+ece/@Reference/` as Excel or CSV:

| File | Purpose |
|---|---|
| `ApplianceData.xlsx` | Energy use, internal gains by ApplianceType + EfficiencyLevel |
| `HeatSystemData.xlsx` | Heating system efficiency curves, fuel mapping by SystemType |
| `CoolSystemData.xlsx` | Cooling system efficiency curves by SystemType |
| `SpaceTypeData.xlsx` | LPD, EPD, occupancy defaults by SpaceType |
| `StoveDataTbl.xlsx` | Gas stove therms and electric stove kWh by SubType |
| `DryerDataTbl.xlsx` | Dryer energy by SubType |
| `AirLeakageRates.xlsx` | Air leakage rate by building type |
| `ThermalCapBldg.xlsx` | Thermal capacitance by ThermalMassType |
| `PipeHeatLoss140F.xlsx` | DHW pipe heat loss by PipeType + diameter |
| `StackMatrix.xlsx` | Stack infiltration matrix |
| `ShieldMatrix.xlsx` | Wind shielding matrix |
| `SummerPeakingWaterMonthlyDistribution.xlsx` | Seasonal irrigation water profile |
| `GroundSurfaceTemp.xlsx` | Ground surface temp amplitude by region |
| `SoilThermalConductivity.xlsx` | Soil thermal conductivity |
| `OilTypeThermsTable.csv` | kBtu per gallon by OilType |
| `WeatherCityData.csv` | Weather station coordinates for city lookup |

Weather data (TMY3/TMY3x) is imported separately via `Location.importWeatherData()` and stored in `Location.WeatherDataTable`.
