# RetroCalc
An energy audit tool
# What is RetroCalc?
RetroCalc is a MATLAB-based decarbonization modeling tool thats built for existing multifamily buildings. Unlike other energy modeling software, Retrocalc combines energy and water modeling, calibrates results to actual utility bills, and handles partial or full electrification scenarios—all without requiring hours of data entry or advanced simulation expertise. It’s built to deliver ASHRAE Level II-compliant results that are scalable, making it a practical solution for engineers, energy auditors, and program implementers alike.
# Architecture
This program is built on a modular, object-oriented architecture in MATLAB, designed to simulate energy and water usage across various building systems. Each system—such as heating, cooling, ventilation, water heating, and appliances—is modeled as a distinct class, making the framework highly extensible, testable, and maintainable.
The Top level of the architecture has the Site Class which includes the HEA class that acts as the starting point for analysis and calculations. It mainly holds annual and monthly utility usage and cost data.
The Building Class is used both in Site and HEA, which is responsible for holding key properties like Area and volume of a building. Number of occupants and units, heating and cooling setpoints, Weather and solar data. 
A Building contains:
* Mechanical Systems: HeatCool, Airmovers, Pumps
* Envelope Components: OpaqueSurfaces, GlazedSurfaces, BelowGradeSurfaces, SlabOnGrade
* Utilities: Electricity, Gas, Water
* Domestic Hot Water (DHW) Systems: DHWsystems, DHWtanks, DHWpipesMechRoom
* End Uses: Appliances, PlumbingFixtures
* Environmental Inputs: Solar gains, internal gains
# The system includes built-in support for:
* Energy Conservation Measures (ECMs): Each model component (e.g., Solar, PlumbingFixture, Heating) can be associated with an EcmID, enabling simulation and comparison of different retrofit strategies.
* Baseline & Calibrated Models: Each data record supports Baseline and Calibrated flags, allowing for before-and-after analysis. This structure enables calibration against real-world performance data or measurement & verification studies.
# Installing on MATLAB
To install Retrocalc, simply clone the GitHub repository to your local machine using git clone, then open the RetroCalc.prj file in MATLAB. This will automatically set the project path and environment. Make sure that your input files—such as the weather station metadata (weather_metadata.csv) and your building data Excel file—are located in the project directory or properly referenced in your script. No additional setup is required beyond having MATLAB (R2022b or later) and the required toolboxes installed.
# How it works
Retrocalc uses Excel input files to gather building information, utility history, and system details, which are then processed through MATLAB classes to model energy and water usage. The tool matches each building to a nearby weather station using city and state inputs, applies climate-appropriate assumptions, and calibrates results against actual utility bills. Outputs include detailed baseline usage, retrofit savings estimates, and projections for cost, carbon, and electrification impacts—making it practical for large-scale multifamily decarbonization planning.


  
