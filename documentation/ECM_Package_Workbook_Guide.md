# RetroCalc — ECM / Package Workbook Guide

For users of the open-source (no-UI) variant: how to define Energy
Conservation Measures (ECMs) and Packages in a single Excel workbook
and apply them to a Building from the MATLAB command line.

Companion documents:

- `examples/example_ECM_Package.xlsx` — filled-in template with
  Excel dropdowns on Operation, ObjectOfReference, PropertyToChange
  (dependent — picks are filtered by ObjectOfReference), and UpdateType.
- `documentation/ECM_Property_Reference.md` — every editable property
  on every target class, indexed-array semantics, and enum member
  names (regenerated from source via
  `_build_ecm_property_reference.py`).

---

## 1. Workbook layout

One workbook defines one or more Packages and all of the ECMs they
reference. The minimum structure:

```
MyECMs.xlsx
├── Packages        ← index: PackageName → ordered list of ECM sheets
├── <ECM sheet 1>   ← one sheet per ECM
├── <ECM sheet 2>
└── ...
```

Optional helper sheets (`Instructions`, `README`, `Notes`, anything
starting with `_`) are ignored by the reader.

**Fallback mode**: if the workbook has no `Packages` sheet, every
non-reserved sheet is treated as a single-ECM package named after the
sheet. Convenient for a handful of standalone ECMs.

---

## 2. Packages sheet

Three columns, one row per `(Package, step)`:

| PackageName    | ECMOrder | ECMSheet            |
|----------------|----------|---------------------|
| Light Retrofit | 1        | BoilerTuneUp        |
| Light Retrofit | 2        | SetpointReduction   |
| Deep Retrofit  | 1        | BoilerTuneUp        |
| Deep Retrofit  | 2        | SetpointReduction   |
| Deep Retrofit  | 3        | WindowUpgrade       |

- Rows with the same `PackageName` are grouped together.
- Within a group, rows are sorted by `ECMOrder` (integer, 1-based).
- The same ECM sheet can appear in multiple packages — no duplication.
- Duplicate `ECMOrder` within a package is a hard error (prevents
  copy-paste mistakes).
- Blank rows at the bottom are ignored.

---

## 3. ECM sheets

Each ECM sheet has eight columns (case-insensitive headers; extra
columns are ignored):

| Column              | Required for | Meaning |
|---------------------|--------------|---------|
| `Operation`         | all          | `insert` \| `update` (alias `edit`) \| `delete` |
| `ObjectOfReference` | all          | Singular class name (`HeatCool`, `Glazing`, `Appliance`, …). Use `Building` to target properties on the Building itself. |
| `FilterCriteria`    | update, delete | Filter expression (see §5). Blank = match all. |
| `PropertyToChange`  | update       | Property name. For arrays, use indexed form `Name(k)` (see §6). |
| `UpdateType`        | update       | `add` \| `multiply` \| `replace` (alias `direct`). |
| `ValueForChange`    | update       | Scalar; vectors allowed in text form like `[2 0 0 0 0 0]`. |
| `InsertQuantity`    | insert       | Integer ≥ 1. |
| `InsertedProperty`  | insert       | Property-assignment DSL (see §7). |

Rows with an unknown Operation or UpdateType are **skipped with a
warning** that names the sheet and row.

---

## 4. Operations in detail

### Insert
Add a new component to one of the Building's collections.

```
Operation | ObjectOfReference | InsertQuantity | InsertedProperty
insert    | Glazing           | 1              | Name="New Skylight"; GlazingType="Skylight"; Quantity=[1]; Width_in=[36]; Height_in=[36]; Uvalue=[0.30]; SHGC=[0.35]; Azimuth_deg=[0]; Tilt_deg=[0];
```

`InsertQuantity` controls how many copies of the object are added.

### Update (also "edit")
Change one property on components that match `FilterCriteria`.

```
Operation | ObjectOfReference | FilterCriteria              | PropertyToChange | UpdateType | ValueForChange
update    | HeatCool          | SystemType == "GasBoiler"   | HeatEff          | multiply   | 1.05
update    | Building          |                             | HeatCoolSetpoints(1) | add    | -2
```

`UpdateType` chooses how `ValueForChange` combines with the current
value:

- `add`       → `new = current + ValueForChange`
- `multiply`  → `new = current × ValueForChange`
- `replace`   → `new = ValueForChange`  (stored as `direct` internally)

Multiple rows run in order — you can stack several updates in one ECM.

### Delete
Remove every component matching `FilterCriteria`.

```
Operation | ObjectOfReference | FilterCriteria
delete    | Appliance         | ApplianceCategory == "Refrigerator" AND EfficiencyLevel < 15
```

A blank `FilterCriteria` on a Delete row is refused (would wipe the
entire collection) — the `applyMeasure` guard emits a warning and
skips the row.

---

## 5. FilterCriteria DSL

Two forms are accepted.

**Property expression** (preferred — survives re-ordering of the
underlying collection):

```
SystemType == "GasBoiler"
HeatEff < 0.85 AND Quantity > 0
ApplianceCategory == "Refrigerator"
GlazedArea > 20 OR Uvalue > 0.5
```

- Comparison operators: `==`, `~=`, `<`, `<=`, `>`, `>=`.
- Combinators: `AND`, `OR` (keywords, uppercase).
- Enum values must be quoted strings.
- Property names are case-sensitive.

**Index form** (if you know exactly which items by position):

```
Object#: 1,3,5
```

Caveats on the index form: positions are evaluated against the
collection as it exists when the measure runs, *after* any earlier
measures in the same ECM have reshaped it. The UI build pipeline
snapshots indexes at ECM entry; the Excel path does not. If you need
"the same physical object regardless of upstream deletes", use the
property-expression form.

---

## 6. Indexed array properties

Some Building / component properties are multi-element numeric arrays.
For example `Building.HeatCoolSetpoints` is a 1×6 vector:

```
[HtgTP1, HtgTP2, ClgTP1, ClgTP2, ClgRH, HtgRH]
  day     night   day     night   —      —
```

To change just one slot without replacing the whole vector, use
indexed form in `PropertyToChange`:

```
PropertyToChange = HeatCoolSetpoints(1)      # daytime heating setpoint
UpdateType       = add
ValueForChange   = -2
```

Result: `HeatCoolSetpoints(1)` goes down by 2 °F, the other five
elements are unchanged.

---

## 7. InsertedProperty DSL

A semicolon-separated list of `Name=Value` pairs. Strings in double
quotes, numerics in square brackets:

```
Name="South Window"; Area_ft2=[30]; Uvalue=[0.25]; SHGC=[0.4]; Azimuth_deg=[180]; Tilt_deg=[90];
```

- Every name=value pair ends with a semicolon, including the last.
- No internal double quotes or semicolons in string values.
- Enum-typed properties take string values: `SystemType="GasBoiler"`.
- The property names must match exactly (`Area_ft2`, not `area` or
  `Area`); the engine looks them up on the target class.

---

## 8. Using the workbook from MATLAB

```matlab
%% 1. Build a site as usual.
site = ece.Site();
site.importSiteInputsData('MyProject_Site.xlsx');
site.Location.importHistoricalDDTable('MyProject_DD.xlsx');
site.ElectricMeters(1).importUsageTable('MyProject_Utility.xlsx', 'Elec_Meter1');
site.computeBuildingUtilityUsages();

%% 2. Run Level 2 so there is a baseline for comparison.
site.Buildings(1).computeLevel2();

%% 3. Apply the Excel-defined packages.
packages = util.applyPackagesFromWorkbook(site.Buildings(1), 'MyECMs.xlsx');

%% 4. Inspect results.
site.Buildings(1).PackageSummaryTable         % per-package KeyResults deltas
site.Buildings(1).ECMSummaryTables            % per-ECM-within-package deltas
site.Buildings(1).Packages(1).ResultBuilding  % final state after Package 1
```

To read packages without applying (e.g. to inspect before running):

```matlab
packages = util.readPackagesFromWorkbook('MyECMs.xlsx');
packages(1).Name
packages(1).ECMs(1).MeasureComponents
```

If you prefer to attach packages manually (so you can inspect
`bldg.Packages` before running the apply pipeline):

```matlab
packages = util.readPackagesFromWorkbook('MyECMs.xlsx');
bldg.addPackages(packages);
bldg.applyPackages();          % defaults to Interactive sequential apply
```

Note: `bldg.applyPackages(...)` takes an `ece.enum.ApplyPackageMethod`
value as its only argument (`Interactive` or `NonInteractive`), **not**
a package array — the packages are read off `bldg.Packages`.

---

## 9. Troubleshooting

| Error / symptom | Likely cause |
|---|---|
| `ece:MissingColumn: ECM '…' is missing required column(s): operation` | ECM sheet header row typo — column names are case-insensitive but the exact words must be present. |
| `util:MissingColumn: Packages sheet is missing column(s): ecmorder` | Packages index sheet header mismatch. Use `PackageName`, `ECMOrder`, `ECMSheet`. |
| `util:MissingECMSheet: Packages sheet row N references ECM sheet 'X'` | `ECMSheet` cell refers to a sheet that doesn't exist in the workbook. |
| `util:DuplicateECMOrder` | Two rows in Packages share the same `PackageName` + `ECMOrder`. |
| `Warning: ece:UnknownOperation: ECM '…', row N: unknown Operation 'foo'` | Typo in Operation cell. Valid: `insert`, `update` / `edit`, `delete`. |
| `Warning: applyMeasure: Operation=Delete but empty FilterCriteria; skipping` | A Delete row with a blank `FilterCriteria` is refused to prevent wiping the entire collection. Fill in criteria. |
| `Warning: ece:negativeHeatSlope` after apply | Unrelated — produced by `analyzeElectricity` regression, not by your ECM. |
| No packages found but the workbook has sheets | Your workbook has a sheet named `Packages` but all data rows have blank `PackageName` or `ECMSheet` cells. Blank rows are silently dropped. |

---

## 10. Limits of the Excel path

- **No live property-picker.** The UI shows you the valid properties
  for each class and their types. In Excel you need the name right.
  See the technical reference for each class's property list.
- **No snapshot semantics for `Object#` filters.** The UI resolves
  Object# to concrete handles at ECM entry; the Excel path evaluates
  the position against the live (possibly shifted) collection at each
  measure. Prefer property-expression filters if upstream measures
  reshape the collection.
- **Internal workbook validation is at import time only.** An ECM
  that references a property that doesn't exist on the target class
  won't fail until `applyMeasure` runs it. The error there names the
  property and target.
