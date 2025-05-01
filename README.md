# RetroCalc

> A scalable, ASHRAE Level 2-compliant, energy, water, and decarbonization modeling software focused on retrofitting large multifamily buildings.

## Background

RetroCalc, developed by New Ecology Inc. (NEI), is an innovative energy modeling tool designed specifically for decarbonizing multifamily buildings at scale. Drawing on NEI’s 25 years of experience in multifamily retrofits, RetroCalc combines detailed energy and water modeling with an intuitive, user- friendly functionality. This tool provides technical assistance (TA) providers with the rigorous energy and cost analysis needed to achieve successful decarbonization, without the time and complexity typically required by traditional modeling software.

By integrating energy and water analysis and calibrating projections to real-world utility data, RetroCalc enables building owners, TA providers, and stakeholders to make informed decisions on retrofit strategies. It ensures accurate, cost-effective planning that boosts energy efficiency, reduces carbon emissions, and improves occupant comfort. RetroCalc’s ASHRAE Level II-compliant outputs have been vetted and approved by National Grid and Eversource for use in Massachusetts multifamily rebate programs, making it a trusted tool for lenders and government agencies.

The purpose of this report is to provide the reader with an understanding of the back-end model or energy engine of RetroCalc. The engine is the part of RetroCalc that does all of the number crunching in order to model a building’s existing conditions and, subsequently, the energy conservation measures (ECMs) recommended. This is the backbone that make it possible to understand the energy and utility implications of building efficiency and electrification retrofits.

## Key Features

RetroCalc strikes the right balance between rigorous analysis and ease of use by focusing on the key components that impact energy use and costs in multifamily retrofits. Developed to meet the needs identified during NEI’s energy auditing and decarbonization process (Figure 1), RetroCalc has always been designed with the needs of TA providers in mind.

### Historical Utility Analysis and Model Calibration

RetroCalc starts with a historical energy analysis (HEA) that generates a profile of a building’s current energy and water use, broken down by end uses. This analysis can be used on its own or as the baseline for calibrating the building’s model. The model is built using field-collected data and incorporates key factors, such as solar gain and internal heat sources, to ensure accurate results. The calibration process then adjusts factors like mechanical system efficiency and occupancy behavior based on the HEA baseline to create a fully calibrated model.

### Water Modeling

Unlike other tools, RetroCalc integrates water usage with energy modeling, recognizing their interdependence and offering more comprehensive savings projections. NEI has consistently found that reducing water usage not only lowers utility costs but also contributes to sustainability efforts, conserves resources, and improves overall building efficiency. By accounting for both energy and water savings, RetroCalc provides a more holistic view of potential cost reductions and environmental benefits.

### ECM Modeling and Interactivity

Current modeling tools are time-consuming when it comes to adjusting the order of implementation of energy conservation measures (ECMs), particularly when evaluating the interactive effects of different measures on HVAC performance and overall energy use. RetroCalc streamlines this process by enabling users to easily change the sequence of ECMs and quickly assess how these measures interact with one another. This flexibility allows for faster and more accurate modeling of the combined impacts on energy consumption, particularly in how HVAC systems respond to different conservation strategies. By simplifying this process, RetroCalc enhances the ability to identify the most effective combination of measures, improving energy efficiency while reducing modeling time and complexity.

### Zero-over-Time (ZoT) Planning Support

The ability to adjust the interactivity of energy conservation measures (ECMs) also enables detailed analysis of their implementation over time. This feature is crucial for buildings aiming to achieve decarbonization through a phased ZoT approach. It allows for the modeling of a gradual transition, assessing how different measures—such as energy efficiency upgrades and HVAC system adjustments—affect energy use and emissions reduction over extended periods. By simulating the impact of these measures implemented incrementally, RetroCalc supports ZoT planning. The analysis incorporates projected grid emissions and utility cost changes to ensure accuracy, while providing insights into the long-term performance and the cumulative effects of each step toward achieving net-zero emissions in building systems. This capability is essential for developing a realistic and cost-effective decarbonization strategy tailored to specific timelines and goals.

# Installation and Setup Guide

1.  Install [MATLAB](https://www.mathworks.com/products/matlab.html) (R2022b or later)
2.  Clone the RetroCalc GitHub repository to your local machine
3.  Open the RetroCalc.prj file from within MATLAB
    a.  This will automatically set the project path and environment.
4.  All the input files are kept in `..tests/testdata directory`
    a.  `buildingInputs.xlsx`contains the basic inputs to the building used in both Level 2 and the HEA
    b.  `calcInputs.xlsx` contains all the input to be used for the Level 2 portion of the code.
    c.  `utilityInputs.xlsx` contains all the inputs from the utility meter data to be used for the HEA.
    d.  `historicalDDInputs.xlsx` contains the degree days data to be used for the HEA portion of the code
5.  The script `SetupSite.m`in `..src/+ece/` contains the code to run the HEA and the L2 scripts.
6.  The commands `site.computeBuildingUtilityUsages()` and `site.computeHEA()` will do the HEA after all the inputs are gathered in the excel files and the file paths are set.
7.  Similarly, `ece.Building.runModules(fileName, config)` will run the L2 calculations.
    a.  `config` sets the option for one of the following run modes:
        i.  Loading the inputs
        ii. Running the calculations
        iii. Displaying the summary results.

# Architecture

This software is written in MATLAB and uses a modular, object-oriented architecture in MATLAB. RetroCalc is designed to model the energy and water usage of a building based upon the energy flows through each building component and their system interactions. Each building system, e.g., space conditioning, ventilation, water heating, and appliances, is modeled as a distinct class, making the framework highly extensible, testable, and maintainable.

### How it works

Retrocalc uses Excel input files to gather building information, utility history, and system details, which are then processed through MATLAB classes to model energy and water usage. The tool matches each building to a nearby weather station using city and state inputs, applies climate-appropriate assumptions, and calibrates results against actual utility bills. Outputs include detailed baseline usage, retrofit savings estimates, and projections for cost, carbon, and electrification impacts—making it practical for large-scale multifamily decarbonization planning.

## Application Data Flow

From the user perspective, there are discrete steps throughout the process of using RetroCalc where data is entered and interacted with. The flow of this process can be seen in the [RetroCalc Flowchart](retroCalcFlowchart.pdf), where the orange bubbles signify data entry points for building characteristics, and green rhombuses show user interaction. The user starts by completing a historical energy analysis (HEA) by entering basic building characteristics and utility data. This HEA is then calibrated to the level 2 model that the user creates from detailed takeoffs of a building. After the model has been calibrated, the user defines the ECMs to model and calculate energy and carbon savings. These ECMs are packaged together and then output as results that can be incorporated into a decarbonization plan. The data structure created to organize the back-end of RetroCalc’s engine has been developed with this high-level user context in mind.

## Data Structure

Buildings are complex systems with many interrelated components. How these components function within the context of their building determines the overall energy and carbon outcomes. To properly organize and track the interactions between a building’s different components RetroCalc uses classes that define the objects of a building. This is a traditional object-oriented programming approach. The [RetroCalc unified modeling language (UML) diagram](retroCalcUML.pdf) that visually represents this system provides the full details of all data flow and entry. Below we will define the different classes and their interactions to give them greater context.

### Site Class

The site class exists in order to aggregate energy data from multiple buildings and properly apportion utilities that serve multiple buildings. This is an important capability in larger developments that contain multiple buildings and could have a central mechanical room. The class contains the location of the site and manages the HEA and level 2 Class (level2Calc). The site is managed by the analysis class.

### Analysis Class

The analysis class manages site objects whether there is one or multiple, and it exists to organize and validate energy data.

### Utility Class

This organizes the utility data input by the user. These different energy sources for the use of gas, water, and electricity are then used by HEA for analysis and then model calibration.

### HEA Class

This class allows for the historical energy analysis to be completed which is then used for calibration of the level 2 model. The HEA is passed through the Building class and to the level 2 class for calibration. HEA is able to calculate the total energy consumption, efficiency metrics, and carbon emissions.

### Building Class

The building class is a central artery within RetroCalc communicates the information between a large variety of classes that describe the different systems that make up a building. The building class focuses on a single structure within a site. The classes that Building obtains energy information from include the following with some examples of objects in those classes:

-   Appliances \| Refrigerator, Stove, Washer, Dryer
-   Spaces \| Residential, Hallway, Stairwell
-   Ventilation \| Exhaust fans, Energy recovery ventilator
-   OpaqueSurfaces \| Insulated walls, Roof
-   Glazing \| Double-pane windows
-   SlabOnGrade \| Concrete slab with no basement
-   BelowGradeSurfaces \| basement walls
-   PlumbingFixtures \| Shower head, Kitchen sink faucet
-   DHWpipesMechRoom \| Domestic hot water piping within the mechanical room
-   DHWtanks \| Domestic hot water tank
-   DHWsystems \| Domestic hot water boiler
-   Fans \| Bath exhaust fan
-   Pumps \| Heating circulator pumps
-   Heating \| Boiler, heat pump
-   Cooling \| Air-conditioner

These classes will be further detailed below and their data is input by the user from building takeoffs.

### Appliances Class

The Appliances class represents energy-consuming devices within a Building, such as refrigerators, ovens, and washing machines. This class is necessary for tracking energy use from household or commercial devices, contributing to overall electricity consumption calculations.

### Spaces Class

The Spaces class represents the unique areas inside of a building and their associated typical occupant usage profiles. These spaces have their own properties for conditioning setpoints, lighting, etc.

### Ventilation Class

The Ventilation class describes the airflow systems that regulate indoor air quality. This class measures the monthly average flow of the ventilation, to be used in the building class.

### OpaqueSurfaces Class

The OpaqueSurfaces class models non-transparent building elements, such as walls and roofs. It is composed within Building and plays a crucial role in thermal insulation and heat retention.

### Glazing Class

The Glazing class represents transparent building elements like windows and glass facades. It is managed by the Building class, contributing to daylighting and heat gain calculations.

### SlabOnGrade Class

The SlabOnGrade class models floor surfaces that are in direct contact with the ground. It is passed up to Building and ensures that heat transfer through the floor is accounted for in thermal modeling.

### BGSurfaces Class

The below grade surfaces class contains information about any basement walls, their insulation, and soil composition, to pass back to the Building class.

### PlumbingFixtures Class

The PlumbingFixtures class includes components such as sinks, toilets, and showers. It is composed within Building and acts as an interface for these fixtures. This class is necessary for tracking water consumption and estimating energy use for heating water.

### DHWpipesMechRoom Class

This class specifies the DHW piping systems in the buildings mechanical room. The class is essential for modeling heat loss in hot water distribution and optimizing insulation strategies.

### DHWtanks Class

The DHWtanks class includes information about the water storage tanks used in domestic hot water systems within a building. The purpose of the class is to evaluate energy storage efficiency and system sizing.

### DHWsystems Class

The DHWsystems class represents both the potable water system in a building. It includes hot and cold water and is crucial for calculating water heating energy demand. It contains information about the water heating system and its efficiency.

### Fans Class

The Fans class models air circulation devices used within a building. This class is necessary for tracking energy consumption related to air movement and ensuring proper ventilation.

### Pumps Class

The Pumps class represents the fluid movement devices within a Building, which would be used for heating, cooling, and water distribution. This class is useful for understanding energy usage in fluid transport systems.

### System Class

It is an interface class that includes the heating and cooling classes. These classes can’t exist independently, and therefore the system class unifies them into one class.

### Heating Class

The Heating class represents the heating system within a building. It is also implemented in the System class, ensuring it follows a standardized structure for climate control. This class is essential for modeling indoor heat distribution and energy consumption.

### Cooling Class

The Cooling class represents the cooling system within a building. It is also implemented in the System class, maintaining the standardized structure. This class is necessary for assessing cooling loads and energy demand.

### References Class

The References Class serves as a data repository for storing and retrieving standard reference values used in benchmarking or validation processes. It ensures that predefined values or industry standards are accessible for calculations.

### Weather Class

The Weather class provides environmental data such as temperature, humidity, and solar radiation, which are crucial for energy modeling and performance analysis. It interacts with Building to adjust energy demand based on climate conditions.

### Solar Class

The Solar class models solar energy systems, including photovoltaic panels or solar water heating. It is essential for calculating renewable energy contributions to a building’s total energy consumption.

### Enumeration Classes

The system includes several enumeration (enum) classes that define categorical values for various components. These enum classes improve data organization, enforce constraints, and facilitate consistency across system models.

-   **FuelType** specifies energy sources such as electricity, natural gas, or solar power, ensuring consistency across heating, cooling, and appliance models.

-   **VentilationType** categorizes airflow systems, distinguishing between mechanical, natural, or hybrid ventilation methods.

-   **WindowType** defines glazing characteristics, including single-pane, double-pane, or low-emissivity (Low-E) windows, crucial for thermal performance analysis.

-   **SurfaceType** differentiates between walls, roofs, and floors, providing a structured way to classify building envelope components.

-   **PumpType** and **FanType** categorize different mechanical systems used in HVAC and plumbing applications, helping define performance parameters based on standardized system types.
