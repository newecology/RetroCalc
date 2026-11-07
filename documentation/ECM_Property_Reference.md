# RetroCalc — ECM Property Reference

Auto-generated from `src/+ece/` class source. Re-run `documentation/_build_ecm_property_reference.py` after adding or renaming properties.

This document enumerates every user-targetable property for every ECM `ObjectOfReference` and every enum you might need to type as a `ValueForChange`.

For the workbook schema (columns, filter DSL, insert DSL), see **ECM_Package_Workbook_Guide.md**.

---

## 1. Target classes

Pick one of these names in the `ObjectOfReference` column of an ECM sheet:

- `Building`  → acts on the Building itself
- `Airmovers`  → acts on `Building.Airmovers`
- `Appliance`  → acts on `Building.Appliances`
- `BelowGradeSurface`  → acts on `Building.BelowGradeSurfaces`
- `DHWpipesMechRoom`  → acts on `Building.DHWpipesMechRoom`
- `DHWsystem`  → acts on `Building.DHWsystems`
- `DHWtanks`  → acts on `Building.DHWtanks`
- `Glazing`  → acts on `Building.GlazedSurfaces`
- `HeatCool`  → acts on `Building.HeatCool`
- `OpaqueSurface`  → acts on `Building.OpaqueSurfaces`
- `PlumbingFixture`  → acts on `Building.PlumbingFixtures`
- `Pump`  → acts on `Building.Pumps`
- `SlabOnGrade`  → acts on `Building.SlabOnGrade`
- `Space`  → acts on `Building.Spaces`

---

## 2. Editable properties by class

### `Building`

| Property | Size | Type | Default | Description |
|----------|------|------|---------|-------------|
| `Name` | `(1,1)` | `string` | `"Default Building"` | Name: Building name. Can be the actual building name or just a string identifier for the building. |
| `GrossArea_ft2` | `(1,1)` | `double` | — | building areas (gross area, gross conditioned area, interior conditioned area) |
| `GrossConditionedArea_ft2` | `(1,1)` | `double` | — | GrossConditionedArea_ft2: Building conditioned area in square feet. |
| `IntConditionedArea_ft2` | `(1,1)` | `double` | — | InteriorConditionedArea_ft2: Interior building conditioned area in square feet. |
| `PercentCondAreaCooled` | `(1,1)` | `double` | — | PercentConditionedArea: Percent of conditioned area that is cooled, 0 to 100 |
| `NumberOfUnits` | `(1,1)` | `double` | — | NumberOfUnits: Number of units in building. MW_MISU: Will this need to be pulled out and become a dependent property on the NumberOfBedroomUnits? |
| `NumberOfBedroomUnits` | `(1,4)` | `double` | `[0, 0, 0, 0]` | NumberOfBedroomUnits: Number of units with X bedrooms. Example: [number of 1 bedroom units, 2 bedroomm units, 3 bedroom units, 4 bedroom units] |
| `NumberOfOccupants` | `(1,1)` | `double` | — | NumberOfOccupants: Number of building occupants. |
| `PopulationType` | `(1,1)` | enum `ece.enum.PopulationType` | `ece.enum.PopulationType.Mixed` | PopulationType: Type of population residing in building. |
| `NumberOfStories` | `(1,1)` | `double` | — | NumberOfStories: Number of stories (floors) of building. |
| `YearOfConstruction` | `(1,1)` | `double` | — | YearOfConstruction: Year building was constructed. |
| `ThermalMass` | `(1,1)` | enum `ece.enum.ThermalMassType` | `ece.enum.ThermalMassType.Light` | ThermalMass: Thermal mass type of building. |
| `IntVolume_ft3` | `(1,1)` | `double` | `0` | IntVolume_ft3: Interior building volume in cubic feet. |
| `AirLeakageRate_cfm50perFt2` | `(1,1)` | `double` | `0` | AirLeakageRate_cfm50perFt2: Air leakage rate for building. |
| `ShieldingClass` | `(1,1)` | `double` | `3` | SheildingClass: Class of sheilding of Building. Must be a value between one and 5. |
| `EffectiveLeakFactor` | `(1,1)` | `double` | `.055` | EffectiveLeakFactor: Defines. an effective leakage factor with default value of .055. |
| `HeatCoolSeasonStartEndDates` | `(1,4)` | `datetime` | `datetime(["01-Oct-2024", "15-May-2024",  "15-May-2024", "15-Oct-2024"])` | HeatCoolSeasonStartEndData: Array of heat/cool start and end heating season start date, heating season end date, cooling season start date, cooling season end date |
| `HVACStartEndTimePeriod1` | `(1,2)` | `double` | `[6, 18]` | HVACStartEndTimePeriod1: Start and end times for HVAC time period 1, represented in military integers. Integer 8 = 8am. Integer 18 = 6pm. Note: Time period 2 is all other times. |
| `HeatCoolSetpoints` | `(1,6)` | `double` | `[72, 72, 74, 74, 60, 40]` | HeatCoolSetpoints: Set points for heating and cooling. Heating time period 1, heating time period 2, and cooling time period 1, cooling time period 2, and cooling RH, heating RH. |
| `EnergySourceForDHW` | `(1,1)` | enum `ece.enum.EnergySourceType` | `ece.enum.EnergySourceType.Gas` | EnergySourceForDHW |
| `CarbonEqValueElectricity_kgPerkWh` | `(1,1)` | `double` | `0` | CarbonEqValueElectricity_kgPerkWh: Carbon equivalent of Electricity, in units of kg per kilowatt-hour. |
| `CarbonEqValueGas_kgPerTherm` | `(1,1)` | `double` | `0` | CarbonEqValueGas_kgPerTherm: Carbon equivalent of Gas, in units of kg per therm. |
| `CarbonEqValueOil_kgPerGallon` | `(1,1)` | `double` | `0` | CarbonEqValueOil_kgPerTherm: Carbon equivalent of Oil, in units of kg per therm. |
| `CarbonEqValuePropane_kgPerGallon` | `(1,1)` | `double` | `0` | CarbonEqValuePropane_kgPerTherm: Carbon equivalent of Propane, in units of kg per therm. |

### `Airmovers` (Building collection: `Airmovers`)

| Property | Size | Type | Default | Description |
|----------|------|------|---------|-------------|
| `Name` | `(1,1)` | `string` | `"Default Air Mover"` | — |
| `Type` | `(1,1)` | enum `ece.enum.VentilationType` | `ece.enum.VentilationType.ExhaustFan` | Type of Airmovers |
| `Quantity` | `(1,1)` | `double` | `0` | Quantity |
| `DesignCFMperUnit` | `(1,1)` | `double` | `0` | the design flow in cubic feet per minute CFM |
| `FractionVentilation` | — | `double` | `0` | fraction of total flow that is ventilation flow (moves air in or out of the building). fraction 0 to 1 |
| `AverageSpeed` | `(1,2)` | `double` | `[0,0]` | Average speed of the fan as a fraction of 0 to 1. If fan is variable speed, estimate average speed of fan when running. Allows variable fan speed for two periods of the day, time1 and time2. |
| `OperationHoursPerDay` | `(1,2)` | `double` | `[0,0]` | Hours of operation per day in time periods 1 and 2 |
| `HeatingSensibleEfficiency` | — | `double` | `0` | ERV efficiencies |
| `CoolingTotalEfficiency` | — | `double` | `0` | — |
| `MotorHP` | `(1,1)` | `double` | `0` | MotorHP - Motor Horsepower (HP) of Fan. Not used in calculation, but can be used in validation. |
| `FractionConditioned` | `(1,1)` | `double` | `0` | FracConditioned - Fraction of motor heat that contributes to heating the building. |
| `CalcMethod` | `(1,1)` | enum `ece.enum.CalculationMethod` | `ece.enum.CalculationMethod.ComputeMotorPower` | CalcMethod - Enumeration type for method of calculation to perform when computing the result. (KWH?) |
| `TotalStaticPressure_inch` | `(1,1)` | `double` | `0` | TotalStaticPressure_inch - Total static pressure on the fan in inches of water gauge. |
| `FanEfficiency` | `(1,1)` | `double` | `0` | FanEfficiency - Fan efficiency. |
| `MotorEfficiency` | `(1,1)` | `double` | `0` | MotorEfficiency - Motor Efficiency |
| `MotorPowerDraw_kW` | `(1,1)` | `double` | `0` | MotorPowerDraw_kW - Motor input power draw in kiloWatts (kW), if it is known. In this case select CalcMethod = 2. If motor power is not known, but the flow and static pressure are known, select CalcMethod = 1 and do not enter any value for MotorPowerDraw. |
| `OperationMonths` | `(1,2)` | `double` | `[1,12]` | OperationMonthRange - Range of months fan is in operation, given as a 2-element array of month indices (eg., Nov to Feb would be given as [11,2], May to Aug would be [5, 8]) |

### `Appliance` (Building collection: `Appliances`)

| Property | Size | Type | Default | Description |
|----------|------|------|---------|-------------|
| `Name` | `(1,1)` | `string` | `"Default Appliance"` | Name: String name for labeling an instance of the object. |
| `ApplianceType` | `(1,1)` | enum `ece.enum.ApplianceType` | `ece.enum.ApplianceType.InUnitGasStoves` | ApplianceType - Enumeration for specific type of appliance, such as a specific kind of stove, dishwasher, refrigerator, etc. |
| `SubType` | `(1,1)` | `string` | `"no subtype"` | SubType: Additional description used for refrigerators and clothes dryers. i.e. front or top loading. Selection depends on the Category of Appliance. |
| `EfficiencyLevel` | `(1,1)` | `double` | `1` | EfficiencyLevel: For now this is 1 standard or 2 Energy Star except that for refrigerators, this is volume in ft3 |
| `Quantity` | `(1,1)` | `double` | `0` | Quantity: How many of this type of appliance exists. |
| `FracUnitsServed` | `(1,1)` | `double` | `0` | FracUnitsServed: Fraction of dwelling units served. EX: If half the dryers are electric and half are gas, the option to define two instances with fraction of dwelling units served by each. |
| `UserAnnual_kWh` | `(1,1)` | `double` | `0` | UserAnnual_kWh: User-supplied annual electricity use (kWh/year) per appliance. Only used when ApplianceType == CustomAppliance. Can be zero (e.g., a gas-only custom appliance). |
| `UserAnnual_therms` | `(1,1)` | `double` | `0` | UserAnnual_therms: User-supplied annual gas use (therms/year) per appliance. Only used when ApplianceType == CustomAppliance. Can be zero (e.g., an electric-only custom appliance). |
| `SensibleGainFrac` | `(1,1)` | `double` | `0.9` | SensibleGainFrac: Fraction of total energy use (converted to kBtu) that becomes sensible internal gain in conditioned space. Default 0.9 assumes an electric appliance located in the conditioned space (nearly all input becomes sensible heat). Gas in-space unvented ~0.4; any vented appliance ~0.05. Only used when ApplianceType == CustomAppliance. |
| `LatentGainFrac` | `(1,1)` | `double` | `0.0` | LatentGainFrac: Fraction of total energy use (converted to kBtu) that becomes latent internal gain (moisture). Default 0 assumes electric. Gas in-space unvented ~0.3; vented ~0. Only used when ApplianceType == CustomAppliance. |

### `BelowGradeSurface` (Building collection: `BelowGradeSurfaces`)

| Property | Size | Type | Default | Description |
|----------|------|------|---------|-------------|
| `Name` | `(1,1)` | `string` | `"Default Below Grade Surface"` | Name: String name for labeling an instance of the object. |
| `BGwallArea_ft2` | `(1,1)` | `double` | `0` | Area of below grade wall in square feet |
| `BGwallInsulR` | `(1,1)` | `double` | `0` | R value of below grade wall insulation if any in hr-ft2-F/Btu The insulation if any starts at grade level and extends down to WallInsulDepthBelowGrade |
| `WallInsulDepthBelowGrade_ft` | `(1,1)` | `double` | `0` | Wall insulation depth below grade in feet (if any wall insulation) |
| `BGfloorArea_ft2` | `(1,1)` | `double` | `0` | Area of below grade floor in square feet |
| `BGfloorInsulR` | `(1,1)` | `double` | `0` | R value of below grade floor insulation if any in hr-ft2-F/Btu |
| `BasementDepthBelowGrade_ft` | `(1,1)` | `double` | `0` | Basement or crawl space floor depth below grade in feet |
| `BasementTemp_F` | `(1,1)` | `double` | `0` | Basement or crawl space temperature in °F |
| `BasementPerimeter_ft` | `(1,1)` | `double` | `0` | Basement or crawl space perimeter in feet |
| `BasementMinDimension_ft` | `(1,1)` | `double` | `0` | Basement or crawl space minimum dimension in feet For a rectangular space, this is just the shortest side. |
| `BaseSlabR` | `(1,1)` | `double` | `1.47` | R value of a standard uninsulated concrete foundation wall with the interior air film only |
| `SoilThermalConductivity` | `(1,1)` | `double` | `0.8` | Soil thermal conductivity in Btu/hr-ft-°F |
| `PhaseConstantForTimeLag_days` | `(1,1)` | `double` | `35` | Phase constant for time lag in days for the location |

### `DHWpipesMechRoom` (Building collection: `DHWpipesMechRoom`)

| Property | Size | Type | Default | Description |
|----------|------|------|---------|-------------|
| `Name` | `(1,1)` | `string` | `"Default DHW PipesMechRoom"` | Name: String name for labeling an instance of the object. |
| `PipeDiameter_inch` | `(1,1)` | `double` | `0.750` | Nominal diameter of pipe in inches Default of .75 inch is to avoid error message (also reasonable default) |
| `PipeType` | `(1,1)` | enum `ece.enum.PipeType` | `ece.enum.PipeType.CopperBare` | linear feet of uninsulated or bare pipe, copper or steel (4 options) |
| `HoursHot` | `(1,1)` | `double` | `8760` | hours per year that this pipe is hot. default is all hours. |
| `Length_ft` | `(1,1)` | `double` | `0` | length of pipe section of this diameter in feet |

### `DHWsystem` (Building collection: `DHWsystems`)

| Property | Size | Type | Default | Description |
|----------|------|------|---------|-------------|
| `Name` | `(1,1)` | `string` | `"Default DHW System"` | Name: String name for labeling an instance of the object. |
| `WaterHeaterType` | `(1,1)` | enum `ece.enum.WaterHeaterType` | `ece.enum.WaterHeaterType.GasFiredHeaterWithIndirectTank` | Type - Enumeration for domestic hot water system type. gas-fired heater with indirect tank, gas-fired tank demand gas, electric tank, demand electric, heat pump water heater |
| `DHWrecirculation` | `(1,1)` | `logical` | `true` | does the DHW system have recirculation? 0 = no, 1 = yes |
| `RecircLoopType` | `(1,1)` | enum `ece.enum.RecircLoopType` | `ece.enum.RecircLoopType.Average` | recirculation loop type or quality compact insulated, average, long runs poorly insulated |
| `ColdWaterMinTempFeb_F` | `(1,1)` | `double` | `44` | minimum temperature of cold water from the plumbing mains which usually occurs in February (northern hemisphere). °F |
| `ColdWaterMaxTempAug_F` | `(1,1)` | `double` | `66` | maximum temperature of cold water from the plumbing mains which usually occurs in August (northern hemisphere). °F |
| `HeaterOutputTemp_F` | `(1,1)` | `double` | `125` | outlet temperature of a water heater serving residences. °F |
| `HeaterOutputTempCommlKitchen_F` | `(1,1)` | `double` | `140` | outlet temperature of a commercial kitchen water heater. °F |
| `SteadyStateEfficiency` | `(1,1)` | `double` | `0` | efficiency of the water heater at steady state |
| `EfficiencySeasonalAmplitude` | `(1,1)` | `double` | `0` | seasonal variation of the heater efficiency if any, expressed as the amplitude of a sin wave |
| `CircLossesJulyFracOfLoad` | `(1,1)` | `double` | `0.2` | heat losses from the circulation piping as a fraction of the fixture load. in July when losses are presumed at a minimum. |
| `CircLossesSeasonalAmplitude` | `(1,1)` | `double` | `0.1` | seasonal variation of the circulation losses if any, expressed as the amplitude of a sin wave |
| `CircLossesFracCond` | `(1,1)` | `double` | `0.75` | fraction of heat loss from heater that enters conditioned space |
| `ControlskW` | `(1,1)` | `double` | `0.02` | controls kW. power draw of any on-board controls or pump default 50 Watts. this energy does not heat the water. |
| `FractionBuildingLoadServed` | `(1,1)` | `double` | `0` | fraction of the building load served by this water heater |

### `DHWtanks` (Building collection: `DHWtanks`)

| Property | Size | Type | Default | Description |
|----------|------|------|---------|-------------|
| `Name` | `(1,1)` | `string` | `"Default DHW Tank"` | Name: String name for labeling an instance of the object. |
| `Quantity` | `(1,1)` | `double` | `1` | Quantity: How many tanks of this type |
| `Volume_gal` | `(1,1)` | `double` | `0` | Volume in gallons of each tank |
| `TankTemp_F` | `(1,1)` | `double` | `130` | Tank temperature °F |
| `RefTemp_F` | `(1,1)` | `double` | `70` | reference temperature (temperature of room the tank is in) °F |
| `PercentLossHr` | `(1,1)` | `double` | `1` | heat loss per hour as a percent of energy in the tank relative to the reference temperature |
| `HoursHot` | `(1,1)` | `double` | `8760` | hours per year that the tank is hot (if always = 8760 hours) |
| `FracCond` | `(1,1)` | `double` | `0.5` | fraction of heat loss in conditioned space and that contributes to heating the building |
| `ControlskW` | `(1,1)` | `double` | `0` | controls kW. power draw of any on-board controls or pump default 50 Watts |

### `Glazing` (Building collection: `GlazedSurfaces`)

| Property | Size | Type | Default | Description |
|----------|------|------|---------|-------------|
| `Name` | `(1,1)` | `string` | `"Default Glazing"` | Name: String name for labeling an instance of the object. |
| `GlazingType` | `(1,1)` | enum `ece.enum.GlazingType` | `ece.enum.GlazingType.Window` | Type - Enumeration for glazing type. Can be window, skylight, or curtainwall. |
| `Quantity` | `(1,1)` | `double` | `0` | NumWindows - Number of windows tracked by this set of properties. |
| `Width_in` | `(1,1)` | `double` | `0` | Width_in - Width of glazing unit in inches. |
| `Height_in` | `(1,1)` | `double` | `0` | Height_in - Height of glazing unit in inches. |
| `FrameWidth_in` | `(1,1)` | `double` | `2.0` | FrameWidth_in - Width of frame in inches. |
| `Uvalue` | `(1,1)` | `double` | `0` | UValue - Insulation factor for the window, in Btu/hr*ft^2*F |
| `SHGC` | `(1,1)` | `double` | `0` | SHGC - Solar heat gain coefficient |
| `Azimuth_deg` | `(1,1)` | `double` | `0` | Azimuth_deg - Angular facing of glazing in degrees (North = 0) |
| `Tilt_deg` | `(1,1)` | `double` | `0` | Tilt_deg - Tilt angle for glazings. 90 = vertical, 0 = horizontal |
| `ShadingMonthly` | `(12,1)` | `double` | `zeros(12,1)` | ShadingMontly - 1x12 array (1 per month) of proportional shading on the Glazing. 0 = full shade, 1 = full exposure. Ex: [.9,.9,.9,.9,.8,.7,.7,.7,.7,.8,.9,.9] |
| `Location` | `(1,1)` | `string` | `""` | Location - string name for the city, state or weather location of the glazing. |

### `HeatCool` (Building collection: `HeatCool`)

| Property | Size | Type | Default | Description |
|----------|------|------|---------|-------------|
| `Name` | `(1,1)` | `string` | `"Default HeatCool System"` | Name: String name for labeling an instance of the object. |
| `SystemType` | `(1,1)` | enum `ece.enum.SystemType` | `ece.enum.SystemType.condGasBoilerOAreset` | SystemType: Type of Heat/Cool System this object belongs to. |
| `SystemFunction` | `(1,1)` | enum `ece.enum.SystemFunction` | `ece.enum.SystemFunction.HeatingOnly` | SystemFunction: Type of function this Heat/Cool System performs. |
| `EnergySource` | `(1,1)` | enum `ece.enum.EnergySourceType` | `ece.enum.EnergySourceType.Electricity` | EnergySource: Source of energy that powers the Heat/Cool System. |
| `Quantity` | `(1,1)` | `double` | `0` | Quantity: Amount of individual objects in System to evaluate. Acts as multiplier. |
| `HeatCapacityEach` | `(1,1)` | `double` | `0` | HeatCapacityEach |
| `CoolCapacityEach` | `(1,1)` | `double` | `0` | CoolCapacityEach |
| `HeatCapUnits` | `(1,1)` | enum `ece.enum.HeatCapUnits` | `ece.enum.HeatCapUnits.kBtuPerHour` | HeatCapUnits: Units of Heat Capacity. |
| `CoolCapUnits` | `(1,1)` | enum `ece.enum.CoolCapUnits` | `ece.enum.CoolCapUnits.kBtuPerHour` | CoolCapUnits: Units of Cooling capacity. |
| `HeatFrac` | `(1,1)` | `double` | `0` | Heat Frac: Fraction of object used for Heating. |
| `CoolFrac` | `(1,1)` | `double` | `0` | Cool Frac: Fraction of object used for Cooling. |
| `ControlskW` | `(1,1)` | `double` | `0` | — |
| `DistEffHtg` | `(1,1)` | `double` | `0` | Efficiency Values |
| `DistEffClg` | `(1,1)` | `double` | `0` | — |
| `HeatEff` | `(1,1)` | `double` | `0` | — |
| `CoolEff` | `(1,1)` | `double` | `0` | — |
| `HeatEffUnits` | `(1,1)` | enum `ece.enum.HeatingEfficiencyUnits` | `ece.enum.HeatingEfficiencyUnits.ThermalEfficiency` | Heat/CoolEffUnits: Units of Heating/Coolin efficiency. |
| `CoolEffUnits` | `(1,1)` | enum `ece.enum.CoolingEfficiencyUnits` | `ece.enum.CoolingEfficiencyUnits.EER` | — |

### `OpaqueSurface` (Building collection: `OpaqueSurfaces`)

| Property | Size | Type | Default | Description |
|----------|------|------|---------|-------------|
| `Name` | `(1,1)` | `string` | `"Default Opaque Surface"` | Name: String name for labeling an instance of this object. i.e., "South Wall". |
| `OpaqueSurfaceType` | `(1,1)` | enum `ece.enum.OpaqueSurfaceType` | `ece.enum.OpaqueSurfaceType.Wall` | Type - Enumeration for opaque surface type. Can be wall, roof, attic floor, door, overhanging floor, or adiabatic. |
| `Area_ft2` | `(1,1)` | `double` | `0` | Area_ft2 - area of the opaque surface in square feet. |
| `RValue` | `(1,1)` | `double` | `0` | RValue - Insulation factor for the opaque surface, in hr*ft^2*F/Btu |
| `SurfaceEmittance` | `(1,1)` | `double` | `0` | SurfaceEmittance - emittance of the surface. For future use. |
| `Azimuth_deg` | `(1,1)` | `double` | `0` | Azimuth_deg - Angular facing of surface in degrees (North = 0) Not relevant for horizontal surfaces. |
| `Tilt_deg` | `(1,1)` | `double` | `0` | Tilt_deg - Tilt angle for glazings. 90 = vertical, 0 = horizontal. Walls and doors are 90 deg; flat roofs, attic floors, and overhangs are 0 deg; enter tilt of sloped roofs. |
| `ShadingMonthly` | `(12,1)` | `double` | `zeros(12,1)` | ShadingMontly - 1x12 array (1 per month) of proportional shading on the surface. 0 = full shade, 1 = full exposure. Ex: [.9,.9,.9,.9,.8,.7,.7,.7,.7,.8,.9,.9] |

### `PlumbingFixture` (Building collection: `PlumbingFixtures`)

| Property | Size | Type | Default | Description |
|----------|------|------|---------|-------------|
| `Name` | `(1,1)` | `string` | `"Default Plumbing Fixture"` | Name: String name for ilabeling an instance of the object. |
| `PlumbingFixtureType` | `(1,1)` | enum `ece.enum.PlumbingFixtureType` | `ece.enum.PlumbingFixtureType.Toilets` | Type - Enumeration for plumbing fixture type or water end use. Toilet, urinal, bathroom sink, shower, irrigation, cooling tower, etc. |
| `Gallons` | `(1,1)` | `double` | `0` | Gallons - fixture usage in gallons, but units vary |
| `GallonUnits` | `(1,1)` | `string` | `"Gallons/Use"` | GallonUnits: Unit Type for Gallons. |
| `Uses` | `(1,1)` | `double` | `0` | Uses: Number of uses for the Uses per X. |
| `UsesUnits` | `(1,1)` | `string` | `"Use/time/entity"` | UsesUnits: Unit Type for Uses per X. Replaces "per X". |
| `UseTemp_F` | `(1,1)` | `double` | `0` | temperature at point of use. °F |
| `FractionTotal` | `(1,1)` | `double` | `0` | Fraction of total fixtures of that type. If half the showers are 1 gpm, and half are 2 gpm, each of 2 shower objects will have .5 for FractionTotal |

### `Pump` (Building collection: `Pumps`)

| Property | Size | Type | Default | Description |
|----------|------|------|---------|-------------|
| `Name` | `(1,1)` | `string` | `"Default Pump"` | Name: String name for labeling an instance of the object. |
| `Quantity` | `(1,1)` | `double` | `0` | Quantity - Number of this pump that exist for calculation purposes. |
| `MotorHP` | `(1,1)` | `double` | `0` | MotorHP - Motor Horsepower (HP) of pump. Not used in calculation, but can be used in validation. |
| `FracConditioned` | `(1,1)` | `double` | `0` | FracConditioned - Fraction of motor heat that contributes to heating the building. |
| `CalcMethod` | `(1,1)` | enum `ece.enum.CalculationMethod` | `ece.enum.CalculationMethod.ComputeMotorPower` | CalcMethod - Enumeration type for method of calculation to perform when computing the result. (KWH?) |
| `Flow_gpm` | `(1,1)` | `double` | `0` | Flow_Gallons/ming - Fluid flow in Gallons Per Minute. |
| `HeadPressure_feet` | `(1,1)` | `double` | `0` | TotalStaticPressure_inch - Total static pressure on the pump in inches of water gauge. |
| `PumpEfficiency` | `(1,1)` | `double` | `0` | pumpEfficiency - pump efficiency. |
| `MotorEfficiency` | `(1,1)` | `double` | `0` | MotorEfficiency - Motor Efficiency |
| `MotorPowerDraw_kW` | `(1,1)` | `double` | `0` | MotorPowerDraw_kW - Motor input power draw in kiloWatts (kW), if it is known. In this case select CalcMethod = 2. If motor power is not known, but the flow and static pressure are known, select CalcMethod = 1 and do not enter any value for MotorPowerDraw. |
| `AvgSpeed` | `(1,1)` | `double` | `0` | AvgSpeed - Average speed of the pump as a fraction 0 to 1. If pump is variable speed, input average speed of pump when running. |
| `OperationHoursPerDay` | `(1,1)` | `double` | `0` | OperationHoursPerDay - Hours per day the pump is in operation. |
| `OperationMonths` | `(1,2)` | `double` | `[1,12]` | OperationMonthRange - Range of months pump is in operation, given as a 2-element array of month indices (eg., Nov to Feb would be given as [11,2], May to Aug would be [5, 8]) |

### `SlabOnGrade` (Building collection: `SlabOnGrade`)

| Property | Size | Type | Default | Description |
|----------|------|------|---------|-------------|
| `Name` | `(1,1)` | `string` | `"Default Slab on Grade"` | Name: String name for labeling an instance of the object. |
| `Perimeter_ft` | `(1,1)` | `double` | `0` | Perimeter of slab in feet |
| `Area_ft2` | `(1,1)` | `double` | `0` | Area_ft2 - area of the slab surface in square feet. This is not used for slab heat loss, but is used to determine the shell area of the building. |
| `Ffactor` | `(1,1)` | `double` | `0` | F factor - Heat loss factor for the slab on grade, from ASHRAE 90.1 or the ASHRAE Fundamentals handbook. Btu/hr-F per linear foot |

### `Space` (Building collection: `Spaces`)

| Property | Size | Type | Default | Description |
|----------|------|------|---------|-------------|
| `Name` | `(1,1)` | `string` | `"Default Space"` | Name: String name for labeling an instance of the object. |
| `SpaceType` | `(1,1)` | enum `ece.enum.SpaceType` | `ece.enum.SpaceType.Residential` | Type - Enumeration for space type. |
| `Area_ft2` | `(1,1)` | `double` | `0` | Area_ft2 - area of the opaque surface in square feet. |
| `LPD_Wft2` | `(1,1)` | `double` | `0` | lighting power density in W/m2 |
| `EPD_Wft2` | `(1,1)` | `double` | `0` | equipment power density in W/m2 |
| `SensGain_BtuHrPerson` | `(1,1)` | `double` | `0` | sensible gains from people in Btu/hr per person |
| `LatGain_BtuHrPerson` | `(1,1)` | `double` | `0` | latent gains from people in Btu/hr per person |
| `LgtEFLHday` | `(1,1)` | `double` | `0` | lighting equivalent full load hours per day |
| `EquipEFLHday` | `(1,1)` | `double` | `0` | miscellaneous equipment equivalent full load hours per day |
| `PeopleEFLHday` | `(1,1)` | `double` | `0` | people equipment equivalent full load hours per day |
| `Ft2person` | `(1,1)` | `double` | `0` | square feet per person for the space |

---

## 3. Indexed array properties

For these properties you can target a single element with `Name(k)` in `PropertyToChange`. Other elements keep their base-building values.

| Property | Element count | Typical semantics |
|----------|---------------|-------------------|
| `Building.NumberOfBedroomUnits(1..4)` | 4 | 1=1BR, 2=2BR, 3=3BR, 4=4BR |
| `Building.HVACStartEndTimePeriod1(1..2)` | 2 | 1=Period 1 start hour, 2=Period 1 end hour |
| `Building.HeatCoolSetpoints(1..6)` | 6 | 1=HtgTP1 day, 2=HtgTP2 night, 3=ClgTP1 day, 4=ClgTP2 night, 5=ClgRH, 6=HtgRH |
| `Airmovers.AverageSpeed(1..2)` | 2 | 1=Period 1 (day), 2=Period 2 (night) |
| `Airmovers.OperationHoursPerDay(1..2)` | 2 | 1=Period 1 (day), 2=Period 2 (night) |
| `Airmovers.OperationMonths(1..2)` | 2 | 1=Start month, 2=End month |
| `Glazing.ShadingMonthly(1..12)` | 12 | 1=Jan … 12=Dec |
| `OpaqueSurface.ShadingMonthly(1..12)` | 12 | 1=Jan … 12=Dec |
| `Pump.OperationMonths(1..2)` | 2 | 1=Start month, 2=End month |

---

## 4. Enum reference

When `ValueForChange` or a `FilterCriteria` expression targets an enum-typed property, use the member name (the left column below), not the display string.

### `ece.enum.ApplianceCategory`

| Member | Display name |
|--------|--------------|
| `Dishwasher` | Dishwasher |
| `Clotheswasher` | Clotheswasher |
| `Dryer` | Dryer |
| `Refrigerator` | Refrigerator |
| `Custom` | Custom |
| `None` | None |

### `ece.enum.ApplianceType`

| Member | Display name |
|--------|--------------|
| `InUnitGasStoves` | In-Unit Gas Stoves |
| `InUnitElectricStoves` | In-Unit Electric Stoves |
| `InUnitDishwashers` | In-Unit Dishwashers |
| `InUnitClotheswashers` | In-Unit Clotheswashers |
| `InUnitGasClothesDryers` | In-Unit Gas Clothes Dryers |
| `InUnitElectricClothesDryers` | In-Unit Electric Clothes Dryers |
| `Refrigerators` | Refrigerators |
| `CommonAreaClotheswashers` | Common Area Clotheswashers |
| `CommonAreaGasClothesDryers` | Common Area Gas Clothes Dryers |
| `CommonAreaElectricClothesDryers` | Common Area Electric Clothes Dryers |
| `CommercialDishwashers` | Commercial Dishwashers |
| `CommercialOvenElectric` | Commercial Oven Electric |
| `CommercialGriddleElectric` | Commercial Griddle Electric |
| `CustomAppliance` | Custom Appliance |

### `ece.enum.ApplyPackageMethod`

| Member | Display name |
|--------|--------------|
| `Interactive` | Interactive |
| `NonInteractive` | Non-Interactive |

### `ece.enum.CalculationMethod`

| Member | Display name |
|--------|--------------|
| `ComputeMotorPower` | Calculate Motor Power |
| `InputMotorPower` | Input Motor Power |

### `ece.enum.CoolCapUnits`

| Member | Display name |
|--------|--------------|
| `kBtuPerHour` | kBtu/hr |
| `tons` | Tons |
| `NA` | N/A |

### `ece.enum.CoolingEfficiencyUnits`

| Member | Display name |
|--------|--------------|
| `EER` | Energy Efficiency Ratio - 95Fdb |
| `EER2` | Energy Efficiency Ratio 2 - 95Fdb |
| `SEER` | Seasonal Energy Efficiency Ratio |
| `SEER2` | Seasonal Energy Efficiency Ratio 2 |
| `IEER` | Integrated Energy Efficiency Ratio |
| `IPLV` | Integrated Part Load Value as COP |
| `averageCOP` | Seasonal Average COP |
| `ASHP_COP95F` | COP at 95F Drybulb Outdoor Air Temperature |
| `NA` | N/A |

### `ece.enum.EnergySourceType`

| Member | Display name |
|--------|--------------|
| `Electricity` | Electricity |
| `Gas` | Gas |
| `Propane` | Propane |
| `HeatingOil` | Heating Oil |
| `None` | None |

### `ece.enum.GlazingType`

| Member | Display name |
|--------|--------------|
| `Window` | Window |
| `Skylight` | Skylight |
| `Curtainwall` | Curtain Wall |

### `ece.enum.HEAPlotType`

| Member | Display name |
|--------|--------------|
| `TotalMonthlyGasUsage` | Total Monthly Gas Usage |
| `TotalMonthlyElectricUsage` | Total Monthly Electric Usage |
| `TotalMonthlyWaterUsage` | Total Monthly Water Usage |
| `TotalMonthlyOilUsage` | Total Monthly Oil Usage |
| `TotalMonthlyPropaneUsage` | Total Monthly Propane Usage |
| `TotalBaseloadUsage` | Total Baseload Usage |
| `GasUsageBreakdown` | Gas Usage by Component |
| `ElectricUsageBreakdown` | Electric Usage by Component |
| `WaterUsageBreakdown` | Water Usage by Component |
| `OilUsageBreakdown` | Oil Usage by Component |
| `PropaneUsageBreakdown` | Propane Usage by Component |

### `ece.enum.HeatCapUnits`

| Member | Display name |
|--------|--------------|
| `kBtuPerHour` | kBtu/hr |
| `NA` | N/A |

### `ece.enum.HeatingEfficiencyUnits`

| Member | Display name |
|--------|--------------|
| `ThermalEfficiency` | Thermal Efficiency |
| `AFUE` | AFUE - Annual Fuel Utilization Efficiency |
| `ASHP_COP47F` | Air Source Heat Pump COP at 47F |
| `ASHP_HSPF` | Air Source Heat Pump Heating Season Performance Factor |
| `averageCOP` | Seasonal Average COP |
| `NA` | N/A |

### `ece.enum.InUnitClothesWasherType`

| Member | Display name |
|--------|--------------|
| `FrontLoadingLessThan2_5cubicFeet` | front loading less than 2.5 cubic feet |
| `FrontLoadingGreaterThan2_5cubicFeet` | front loading greater than 2.5 cubic feet |
| `TopLoading` | top loading |

### `ece.enum.Level2ObjectType`

| Member | Display name |
|--------|--------------|
| `AirMover` | Air Mover |
| `Appliance` | Appliance |
| `BelowGradeSurface` | Below Grade Surface |
| `DHWPipesMechRoom` | DHW Pipes Mech Room |
| `DHWSystem` | DHW System |
| `DHWTank` | DHW Tank |
| `Glazing` | Glazing |
| `HeatCool` | Heat/Cool |
| `OpaqueSurface` | Opaque Surface |
| `PlumbingFixture` | Plumbing Fixture |
| `Pump` | Pump |
| `SlabOnGrade` | Slab On Grade |
| `Space` | Space |

### `ece.enum.Level2PlotType`

| Member | Display name |
|--------|--------------|
| `ActualVsModelGasUsage` | Comparative Gas Usage |
| `ActualVsModelElectricUsage` | Comparative Electric Usage |
| `ActualVsModelWaterUsage` | Comparative Water Usage |
| `ActualVsModelOilUsage` | Comparative Oil Usage |
| `ActualVsModelPropaneUsage` | Comparative Propane Usage |
| `ElectricComponentContribution` | Electric Contribution |
| `GasComponentContribution` | Gas Contribution |
| `BuildingEnvelopeHeatLoss` | Building Envelope Heat Loss |
| `InternalGainsBreakdown` | Internal Gains Breakdown |

### `ece.enum.MeterType`

| Member | Display name |
|--------|--------------|
| `Tenant` | Tenant |
| `Building` | Building |

### `ece.enum.OilType`

| Member | Display name |
|--------|--------------|
| `Number2` | Number2 |
| `Number4` | Number4 |
| `Number6` | Number6 |

### `ece.enum.OpaqueSurfaceType`

| Member | Display name |
|--------|--------------|
| `Wall` | Wall |
| `Roof` | Roof |
| `AtticFloor` | AtticFloor |
| `Door` | Door |
| `OverhangingFloor` | OverhangingFloor |
| `Adiabatic` | Adiabatic |

### `ece.enum.PipeType`

| Member | Display name |
|--------|--------------|
| `CopperBare` | Copper (Bare) |
| `CopperInsul` | Copper (Insulated) |
| `SteelBare` | Steel (Bare) |
| `SteelInsul` | Steel (Insulated) |

### `ece.enum.PlumbingFixtureType`

| Member | Display name |
|--------|--------------|
| `Toilets` | Toilets |
| `Urinals` | Urinals |
| `BathroomSink` | Bathroom Sink |
| `KitchenSink` | Kitchen Sink |
| `Shower` | Shower |
| `InUnitDishwasher` | In-Unit Dishwasher |
| `InUnitClotheswasher` | In-Unit Clothes Washer |
| `CommonAreaClotheswasher` | Common Area Clothes Washer |
| `CommercialKitchenSink` | Commercial Kitchen Sink |
| `CommercialDishwasher` | Commercial Dishwasher |
| `Irrigation` | Irrigation |
| `CoolingTower` | Cooling Tower |
| `Other` | Other |
| `None` | None |

### `ece.enum.PopulationType`

| Member | Display name |
|--------|--------------|
| `Mixed` | Mixed |
| `Elderly` | Elderly |
| `Families` | Families |

### `ece.enum.RealEstateType`

| Member | Display name |
|--------|--------------|
| `Residential` | Residential |
| `Commercial` | Commercial |

### `ece.enum.RecircLoopType`

| Member | Display name |
|--------|--------------|
| `CompactInsulated` | Compact (Insulated) |
| `Average` | Average |
| `LongRunsPoorlyInsulated` | Long Runs (Poorly Insulated) |

### `ece.enum.RefrigeratorVintage`

| Member | Display name |
|--------|--------------|
| `Pre1976` | Pre1976 |
| `from1976to1986` | from1976to1986 |
| `from1987to1989` | from1987to1989 |
| `from1990to1992` | from1990to1992 |
| `from1993to2000` | from1993to2000 |
| `year2001andLater` | year2001andLater |
| `from2001to2004EnergyStar` | from2001to2004EnergyStar |
| `from2004to2008EnergyStar` | from2004to2008EnergyStar |
| `from2008toi2010EnergyStar` | from2008to2010EnergyStar |
| `CEEtier3` | CEEtier3 |

### `ece.enum.SpaceType`

| Member | Display name |
|--------|--------------|
| `Residential` | Residential |
| `Corridor` | Corridor |
| `Stairwell_Elevator` | Stairwell_Elevator |
| `CommonArea` | CommonArea |
| `Mechanical` | Mechanical |
| `Office_Lounge` | Office_Lounge |
| `Laundry` | Laundry |
| `Restroom` | Restroom |
| `Fitness` | Fitness |
| `Retail` | Retail |
| `Restaurant` | Restaurant |
| `Theater` | Theater |
| `School` | School |
| `Storage` | Storage |
| `Unconditioned` | Unconditioned |
| `Other` | Other |

### `ece.enum.SystemFunction`

| Member | Display name |
|--------|--------------|
| `HeatingOnly` | Heating Only |
| `CoolingOnly` | Cooling Only |
| `BothHeatingAndCooling` | Both Heating and Cooling |

### `ece.enum.SystemType`

| Member | Display name |
|--------|--------------|
| `condGasBoilerOAreset` | Condensing Gas Boiler with Outdoor Air Reset |
| `nonCondGasOrOilBoilerNoOAreset` | Non-condensing Gas/Oil Boiler with No Outdoor Air Reset |
| `windowAirConditioner` | Window Air Conditioner |
| `waterCooledChiller` | Water-cooled Chiller |
| `airCooledChiller` | Air-cooled Chiller |
| `all` | All System Types |

### `ece.enum.ThermalMassType`

| Member | Display name |
|--------|--------------|
| `Light` | Light |
| `Medium` | Medium |
| `Heavy` | Heavy |

### `ece.enum.UtilityMeterType`

| Member | Display name |
|--------|--------------|
| `Electricity` | Electricity |
| `Water` | Water |
| `Gas` | Gas |
| `Oil` | Oil |
| `Propane` | Propane |

### `ece.enum.UtilityPayerType`

| Member | Display name |
|--------|--------------|
| `Tenant` | Tenant |
| `Building` | Building |

### `ece.enum.UtilityServiceType`

| Member | Display name |
|--------|--------------|
| `Dwelling` | Dwelling |
| `Other` | Other |

### `ece.enum.VentilationType`

| Member | Display name |
|--------|--------------|
| `ExhaustFan` | Exhaust Fan |
| `SupplyFan` | Supply Fan |
| `ERV` | ERV |
| `AirHandlingUnit` | Air Handling Unit |
| `FanCoilFan` | Fan Coil Fan |

### `ece.enum.WaterHeaterType`

| Member | Display name |
|--------|--------------|
| `GasFiredHeaterWithIndirectTank` | Gas-fired Heater with Indirect Tank |
| `GasFiredTank` | Gas-fired Tank |
| `DemandGas` | Demand Gas |
| `OilFiredHeaterWithIndirectTank` | Oil-fired Heater with Indirect Tank |
| `OilFiredTank` | Oil-fired Tank |
| `PropaneFiredHeaterWithIndirectTank` | Propane-fired Heater with Indirect Tank |
| `PropaneFiredTank` | Propane-fired Tank |
| `ElectricTank` | Electric Tank |
| `DemandElectric` | Demand Electric |
| `HeatPumpWaterHeater` | Heat Pump Water Heater |

---

_File generated by `_build_ecm_property_reference.py`. Do not hand-edit — re-run the generator instead._
