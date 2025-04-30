# RetroCalc

A scalable, ASHRAE Level 2-compliant, energy/water modeling, and decarbonization software focused on retrofitting large multifamily buildings.

# Background

RetroCalc, developed by New Ecology Inc. (NEI), is an innovative energy modeling tool designed specifically for decarbonizing multifamily buildings at scale. Drawing on NEI’s 25 years of experience in multifamily retrofits, RetroCalc combines detailed energy and water modeling with an intuitive, user- friendly functionality. This tool provides technical assistance (TA) providers with the rigorous energy and cost analysis needed to achieve successful decarbonization, without the time and complexity typically required by traditional modeling software.

By integrating energy and water analysis and calibrating projections to real-world utility data, RetroCalc enables building owners, TA providers, and stakeholders to make informed decisions on retrofit strategies. It ensures accurate, cost-effective planning that boosts energy efficiency, reduces carbon emissions, and improves occupant comfort. RetroCalc’s ASHRAE Level II-compliant outputs have been vetted and approved by National Grid and Eversource for use in Massachusetts multifamily rebate programs, making it a trusted tool for lenders and government agencies.

The purpose of this report is to provide the reader with an understanding of the back-end model or energy engine of RetroCalc. The engine is the part of RetroCalc that does all of the number crunching in order to model a building’s existing conditions and, subsequently, the energy conservation measures (ECMs) recommended. This is the backbone that make it possible to understand the energy and utility implications of building efficiency and electrification retrofits.

# Key Features

RetroCalc strikes the right balance between rigorous analysis and ease of use by focusing on the key components that impact energy use and costs in multifamily retrofits. Developed to meet the needs identified during NEI’s energy auditing and decarbonization process (Figure 1), RetroCalc has always been designed with the needs of TA providers in mind.

## Historical Utility Analysis and Model Calibration

RetroCalc starts with a historical energy analysis (HEA) that generates a profile of a building’s current energy and water use, broken down by end uses. This analysis can be used on its own or as the baseline for calibrating the building’s model. The model is built using field-collected data and incorporates key factors, such as solar gain and internal heat sources, to ensure accurate results. The calibration process then adjusts factors like mechanical system efficiency and occupancy behavior based on the HEA baseline to create a fully calibrated model.

## Water Modeling

Unlike other tools, RetroCalc integrates water usage with energy modeling, recognizing their interdependence and offering more comprehensive savings projections. NEI has consistently found that reducing water usage not only lowers utility costs but also contributes to sustainability efforts, conserves resources, and improves overall building efficiency. By accounting for both energy and water savings, RetroCalc provides a more holistic view of potential cost reductions and environmental benefits.

## ECM Modeling and Interactivity

Current modeling tools are time-consuming when it comes to adjusting the order of implementation of energy conservation measures (ECMs), particularly when evaluating the interactive effects of different measures on HVAC performance and overall energy use. RetroCalc streamlines this process by enabling users to easily change the sequence of ECMs and quickly assess how these measures interact with one another. This flexibility allows for faster and more accurate modeling of the combined impacts on energy consumption, particularly in how HVAC systems respond to different conservation strategies. By simplifying this process, RetroCalc enhances the ability to identify the most effective combination of measures, improving energy efficiency while reducing modeling time and complexity.

## Zero-over-Time (ZoT) Planning Support

The ability to adjust the interactivity of energy conservation measures (ECMs) also enables detailed analysis of their implementation over time. This feature is crucial for buildings aiming to achieve decarbonization through a phased ZoT approach. It allows for the modeling of a gradual transition, assessing how different measures—such as energy efficiency upgrades and HVAC system adjustments—affect energy use and emissions reduction over extended periods. By simulating the impact of these measures implemented incrementally, RetroCalc supports ZoT planning. The analysis incorporates projected grid emissions and utility cost changes to ensure accuracy, while providing insights into the long-term performance and the cumulative effects of each step toward achieving net-zero emissions in building systems. This capability is essential for developing a realistic and cost-effective decarbonization strategy tailored to specific timelines and goals.

# Architecture

This software is written in MATLAB and uses a modular, object-oriented architecture in MATLAB. RetroCalc is designed to model the energy and water usage of a building based upon the energy flows through each building component and their system interactions. Each building system, e.g., space conditioning, ventilation, water heating, and appliances, is modeled as a distinct class, making the framework highly extensible, testable, and maintainable.

## Application Data Flow

From the user perspective, there are discrete steps throughout the process of using RetroCalc where data is entered and interacted with. The flow of this process can be seen in the [RetroCalc Flowchart](https://github.com/newecology/RetroCalc/blob/main/retroCalcFlowchart.pdf), where the orange bubbles signify data entry points for building characteristics, and green rhombuses show user interaction. The user starts by completing a historical energy analysis (HEA) by entering basic building characteristics and utility data. This HEA is then calibrated to the level 2 model that the user creates from detailed takeoffs of a building. After the model has been calibrated, the user defines the ECMs to model and calculate energy and carbon savings. These ECMs are packaged together and then output as results that can be incorporated into a decarbonization plan. The data structure created to organize the back-end of RetroCalc’s engine has been developed with this high-level user context in mind.

## Data Structure

The top level of the architecture has the Site Class which includes the Historical Energy Analysis (HEA) class that is the starting point for analysis and calculations. It holds annual and monthly utility usage and cost data. The Building Class is used both in Site and HEA, which is responsible for holding key properties like Area and volume of a building. Number of occupants and units, heating and cooling set points, Weather and solar data. A Building contains:

-   Mechanical Systems:
    -   Space HeatCool, Airmovers, Pumps
-   Envelope Components:
    -   OpaqueSurfaces, GlazedSurfaces, BelowGradeSurfaces, SlabOnGrade
-   Utilities: Electricity, Gas, Water - Domestic Hot Water (DHW) Systems: DHWsystems, DHWtanks, DHWpipesMechRoom - End Uses: Appliances, PlumbingFixtures
-   Environmental Inputs: Solar gains, internal gains

# View Architecture Diagram

[View system architecture diagram on diagrams.net](https://app.diagrams.net/#Wb!1BT1CzIKA0W4NNPtvamtEsLCsXKENnJHiiKqG-uknUfzUayUV16iQbTUJK23fBWJ%2F01IKS5YVAIKDZFAS3H5VGJVKTXKD2GM3MK#%7B%22pageId%22%3A%22jWfv4X7doiBbksh0aBEH%22%7D)

# The system includes built-in support for:

-   Energy Conservation Measures (ECMs): Each model component (e.g., Solar, PlumbingFixture, Heating) can be associated with an EcmID, enabling simulation and comparison of different retrofit strategies.
-   Baseline & Calibrated Models: Each data record supports Baseline and Calibrated flags, allowing for before-and-after analysis. This structure enables calibration against real-world performance data or measurement & verification studies.

# Installing on MATLAB

To install Retrocalc, simply clone the GitHub repository to your local machine using git clone, then open the RetroCalc.prj file in MATLAB. This will automatically set the project path and environment. Make sure that your input files—such as the weather station metadata (weather_metadata.csv) and your building data Excel file—are located in the project directory or properly referenced in your script. No additional setup is required beyond having MATLAB (R2022b or later) and the required toolboxes installed.

# How it works

Retrocalc uses Excel input files to gather building information, utility history, and system details, which are then processed through MATLAB classes to model energy and water usage. The tool matches each building to a nearby weather station using city and state inputs, applies climate-appropriate assumptions, and calibrates results against actual utility bills. Outputs include detailed baseline usage, retrofit savings estimates, and projections for cost, carbon, and electrification impacts—making it practical for large-scale multifamily decarbonization planning.
