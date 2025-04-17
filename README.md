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
The system includes built-in support for:
* Energy Conservation Measures (ECMs): Each model component (e.g., Solar, PlumbingFixture, Heating) can be associated with an EcmID, enabling simulation and comparison of different retrofit strategies.
* Baseline & Calibrated Models: Each data record supports Baseline and Calibrated flags, allowing for before-and-after analysis. This structure enables calibration against real-world performance data or measurement & verification studies.
# Installing on MATLAB
To use Retrocalc, you'll need the current version of MATLAB R2022b or newer, this can be downloaded from

# File Structure



  
