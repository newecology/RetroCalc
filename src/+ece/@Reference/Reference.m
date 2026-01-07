classdef Reference
    % REFERENCE Class containing data tables for use in calculations and
    % for guidance to the user
    % Constant property to store the table. It is made constant so that it
    % can't be changed from outside.
    % Storing the output from the static method
    properties (Constant)
        % AirLeakageRateTable
        AirLeakageRateTable = ece.Reference.getAirLeakageRateTable;

        ThermalCapBldgTable = ece.Reference.getThermalCapBldgTable;

        GroundSurfaceTempAmpTable = ece.Reference.getGroundSurfaceTempAmpTable;

        SoilConductivityTable = ece.Reference.getSoilConductivityData;

        PipeHeatLoss140FTable = ece.Reference.getPipeHeatLoss140FTable;

        SummerPeakWaterMonthDistTable = ece.Reference.getSummerPeakWaterMonthDistTable;

        StackMatrix=ece.Reference.getStackMatrix;

        ShieldMatrix=ece.Reference.getShieldMatrix;

        StoveDataTbl=ece.Reference.getStoveDataTbl;

        DryerDataTbl=ece.Reference.getDryerDataTbl;

        SpaceTypeDataTable = ece.Reference.getSpaceTypeData;

        ApplianceDataTable = ece.Reference.getApplianceData;

        HeatSysData = ece.Reference.getHeatSysData;

        CoolSysData = ece.Reference.getCoolSysData;

        WeatherCityData = ece.Reference.getWeatherCityData;

        OilTypekBtuTable = ece.Reference.getOilTypekBtuTable;

    end %properties (Constant)

    % Methods (Static)
    methods(Access = public, Static)

        % Function to import the air leakage rate table
        function val = getAirLeakageRateTable()
            filePath = fullfile("+ece","@Reference",...
                "AirLeakageRates.xlsx");
            val = readtable(filePath,...
                "VariableNamingRule","preserve");
        end %function

        % Function to import the thermal capacities of buildings table
        function val=getThermalCapBldgTable()
            filePath = fullfile("+ece","@Reference",...
                "ThermalCapBldg.xlsx");
            val = readtable(filePath,...
                "VariableNamingRule","preserve");
        end %function

        % Function to import the ground surface temperature amplitude for different
        % locations
        function val=getGroundSurfaceTempAmpTable()

            filePath = fullfile("+ece","@Reference",...
                "GroundSurfaceTemp.xlsx");
            val = readtable(filePath,...
                "VariableNamingRule","preserve");

        end %function

        % Function to import the soil thermal conductivities for wet, dry, medium
        % soil types. Also thermal value of uninsulated concrete wall or slab (assume 8
        % inches - very close for other thicknesses)
        function val = getSoilConductivityData()

            filePath = fullfile("+ece","@Reference",...
                "SoilThermalConductivity.xlsx");
            val = readtable(filePath,...
                "Range","A1:C7",...
                "VariableNamingRule","preserve");

            
            val.SoilType = string(val.SoilType);
            val.Units = string(val.Units);



        end %function

        % Function to import the pipe heat loss at 140F table
        function val = getPipeHeatLoss140FTable()

            filePath = fullfile("+ece","@Reference",...
                "PipeHeatLoss140F.xlsx");
            val = readtable(filePath,...
                "VariableNamingRule","preserve");

            val.Units = string(val.Units);

        end %function

        % Function to import stack matrix
        function val = getStackMatrix()

            filePath = fullfile("+ece","@Reference",...
                "StackMatrix.xlsx");
            val = readmatrix(filePath);


        end %function

        % Function to import shield matrix
        function val = getShieldMatrix()
            filePath = fullfile("+ece","@Reference",...
                "ShieldMatrix.xlsx");
            val = readmatrix(filePath);
        end %function

        % Function to import the summer peaking monthly water distribution table
        % for Irrigation and cooling towers which use water in summer peaking
        % in June, July, and August, much less in May, Sep, Oct, and zero in
        % Jan, Feb, Mar, Apr, Nov, Dec.
        function val = getSummerPeakWaterMonthDistTable()

            filePath = fullfile("+ece","@Reference",...
                "SummerPeakingWaterMonthlyDistribution.xlsx");
            val = readtable(filePath,...
                "VariableNamingRule","preserve");


        end %function

        %Function to get stove data table from excel file
        function val = getStoveDataTbl()

            filePath = fullfile("+ece","@Reference",...
                "StoveDataTbl.xlsx");
            val = readtable(filePath,...
                "VariableNamingRule","preserve");
        


        end %function

        %Function to get Dryer data table from excel file
        function val = getDryerDataTbl()

            filePath = fullfile("+ece","@Reference",...
                "DryerDataTbl.xlsx");
            val = readtable(filePath,...
                "VariableNamingRule","preserve");
           

        end %function

        %Function to space type data from excel file. lighting and equipment power
        %densities for internal gains, equivalent full hours per day, gains from people
        function val = getSpaceTypeData()

            filePath = fullfile("+ece","@Reference",...
                "SpaceTypeData.xlsx");
            val = readtable(filePath,...
                "Range","A1:I24",...
                "VariableNamingRule","preserve");

            val.SpaceType = string(val.SpaceType);

        end %function

        % function to read table of appliance data, typical usage of residential
        % and some commercial appliances

        function val = getApplianceData()

            filePath = fullfile("+ece","@Reference",...
                "ApplianceData.xlsx");
            val = readtable(filePath,...
                "Range","A1:L45",...
                "VariableNamingRule","preserve");

            val.ApplianceType = string(val.ApplianceType);
            val.SubType = string(val.SubType);
            val.Code = string(val.Code);
            val.Description = string(val.Description);
            val.ApplianceCategory = string(val.ApplianceCategory);

        end %function

        function val = getHeatSysData()

            filePath = fullfile("+ece","@Reference",...
                "HeatSystemData.xlsx");
            val = readtable(filePath,...
                "Range","A2:Q18",...
                "VariableNamingRule","preserve");


            val.SystemType = string(val.SystemType);
            val.EffUnits = string(val.EffUnits);
            val.CurveEffUnits = string(val.CurveEffUnits);
            val.EffCurveHeating = [val.FourthOrderPower,...
                val.ThirdOrderPower,...
                val.SecondOrderPower,...
                val.FirstOrderPower,...
                val.Constant];
            val = removevars(val, ["FourthOrderPower",...
                "ThirdOrderPower", "SecondOrderPower", ...
                "FirstOrderPower", "Constant"]);

        end %function

        function val = getCoolSysData()

            filePath = fullfile("+ece","@Reference",...
                "CoolSystemData.xlsx");
            val = readtable(filePath,...
                "Range","A2:K14",...
                "VariableNamingRule","preserve");

            val.SystemType = string(val.SystemType);
            val.EffUnits = string(val.EffUnits);
            val.CurveEffUnits = string(val.CurveEffUnits);
            val.EffCurveCooling = [val.FourthOrderPower,...
                val.ThirdOrderPower,...
                val.SecondOrderPower,...
                val.FirstOrderPower,...
                val.Constant];
            val = removevars(val, ["FourthOrderPower",...
                "ThirdOrderPower", "SecondOrderPower", ...
                "FirstOrderPower", "Constant"]);

        end %function

        function val = getWeatherCityData()
            
            filePath = fullfile("+ece","@Reference",...
                "WeatherCityData.csv");
            val = readtable(filePath,...
                "VariableNamingRule","preserve"); 
            
            val.Site = string(val.Site);
            val.State = string(val.State);
        end %function

        function val = getOilTypekBtuTable()

            filePath = fullfile("+ece","@Reference",...
                "OilTypekBtuTable.xlsx");
            val = readtable(filePath,...
                "VariableNamingRule","preserve");
            
            val.OilType = string(val.OilType);
            %val.Properties.VariableNames{'BtuPerGallon'}='kBtuPerGallon';

        end %function

    end  % methods (static, public)


    properties (Access = public)
        % -- Define Public Properties


    end %properties (Public)


    methods
        % -- Internals-related Class Methods
        % Define Constructor Method
        function obj = Reference()
            % Construct an instance of the class.
            %   The default pump constructor takes no arguments and
            %   returns a default instance of the pump object. A pump
            %   object with loaded values can be instanced with
            %   the fromSourceData static method.
            %   This object construction style is useful when testing
            %   objects that are intended to be populated from external
            %   data, as it decouples the object's existence from the
            %   intended supplemental data.

        end %function (constructor)

        % -- Property Get Methods

        % end %function (propGet)

    end %methods (public Internals)

    methods (Access = public)
        % -- Declare Publically Accessible Methods
        % Method definitions will be fully realized in the correspondingly
        % named function script .m files in the pump class folder @pump.

    end %methods (public)


    methods (Access = private)
        % -- Declare Privately Accessible Methods Here
        % Method definitions will be fully realized and defined in the
        % correspondingly named function script .m files in the class
        % folder @Reference. Private methods are only callable within
        % objects of this same class.

    end %methods (private)


    methods (Access = public, Static)
        % Function to get Degree days data via API from degreedays.net
        credentials = getCredentialsFromEnvironment();
        data = fromDegreeDaysNetAPI(lat,long,base_temp,options);

        %Function to get the approx ground surface amplitude temp for a place
        amplitude = getUSGroundSurfaceAmplitude(lat, lon);
  
    end %methods (public, Static)

end %classdef (pump)

