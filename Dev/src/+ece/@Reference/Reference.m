classdef Reference
    % Reference class containing data tables for use in calculations and
    % for guidance to the user
    % Constant property to store the table. It is made constant so that it
    % can't be changed from outside.
    % Storing the output from the static method
    properties (Constant)
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
        SpaceTypeDataTable = ece.Reference.getSpaceTypeData
        ApplianceDataTable = ece.Reference.getApplianceData
        HeatSysData = ece.Reference.getHeatSysData
        CoolSysData = ece.Reference.getCoolSysData
        WeatherCityData = ece.Reference.getWeatherCityData
    end
    % Static method used to import the data from the excel file containing the air leakage table
    %The file should live in the same folder and the file name should not be
    %changed.
    methods(Static=true,Access=public)

        % Function to import the air leakage rate table
        function val=getAirLeakageRateTable()
            val=readtable('+ece\@Reference\AirLeakageRates.xlsx');
        end

        % Function to import the thermal capacities of buildings table
        function val=getThermalCapBldgTable()
            val=readtable('+ece\@Reference\ThermalCapBldg.xlsx');
        end
        % Function to import the ground surface temperature amplitude for different
        % locations
        function val=getGroundSurfaceTempAmpTable()
            val=readtable('+ece\@Reference\GroundSurfaceTemp.xlsx');
        end

        % Function to import the soil thermal conductivities for wet, dry, medium
        % soil types. Also thermal value of uninsulated concrete wall or slab (assume 8
        % inches - very close for other thicknesses)
        function val = getSoilConductivityData()
            val = readtable('+ece\@Reference\SoilThermalConductivity.xlsx','Range','A1:C7');
            val.soilType = string(val.soilType);
            val.units = string(val.units);
        end

        % Function to import the pipe heat loss at 140F table
        function val = getPipeHeatLoss140FTable()
            val = readtable('+ece\@Reference\PipeHeatLoss140F.xlsx');
            val.Units = string(val.Units);
        end
        % Function to import stack matrix
        function val = getStackMatrix()
            val = readmatrix('+ece\@Reference\StackMatrix.xlsx');

        end
        % Function to import shield matrix
        function val = getShieldMatrix()
            val = readmatrix('+ece\@Reference\ShieldMatrix.xlsx');

        end
        % Function to import the summer peaking monthly water distribution table
        % for Irrigation and cooling towers which use water in summer peaking
        % in June, July, and August, much less in May, Sep, Oct, and zero in
        % Jan, Feb, Mar, Apr, Nov, Dec.
        function val = getSummerPeakWaterMonthDistTable()
            val = readtable('+ece\@Reference\SummerPeakingWaterMonthlyDistribution.xlsx');
        end

        %Function to get stove data table from excel file
        function val = getStoveDataTbl()
            val = readtable('+ece\@Reference\StoveDataTbl.xlsx');
        end
        %Function to get Dryer data table from excel file
        function val = getDryerDataTbl()
            val = readtable('+ece\@Reference\DryerDataTbl.xlsx');
        end

        %Function to space type data from excel file. lighting and equipment power
        %densities for internal gains, equivalent full hours per day, gains from people
        function val = getSpaceTypeData()
            val = readtable('+ece\@Reference\SpaceTypeData.xlsx','Range','A1:I24');
            val.SpaceType = string(val.SpaceType);
        end

        % function to read table of appliance data, typical usage of residential
        % and some commercial appliances
        
        function val = getApplianceData()
            val = readtable('+ece\@Reference\ApplianceData.xlsx','Range','A1:L45');
            val.ApplianceType = string(val.ApplianceType);
            val.SubType = string(val.SubType);
            val.Code = string(val.Code);
            val.Description = string(val.Description);
            val.ApplianceCategory = string(val.ApplianceCategory);
        end

        function val = getHeatSysData()
            val = readtable('+ece\@Reference\HeatSystemData.xlsx','Range','A2:Q18', ...
                'VariableNamingRule','preserve');
            val.SystemType = string(val.SystemType);
            val.effUnits = string(val.effUnits);
            val.curveEffUnits = string(val.curveEffUnits);
            val.EffCurveHeating = [val.x4thPower val.x3rdPower val.x2ndPower ...
                val.x1stPower val.constant];
            val = removevars(val, ["x4thPower", "x3rdPower", "x2ndPower", ...
                "x1stPower", "constant"]);
        end  

        function val = getCoolSysData()
            val = readtable('+ece\@Reference\CoolSystemData.xlsx','Range','A2:K14', ...
                'VariableNamingRule','preserve');
            val.SystemType = string(val.SystemType);
            val.effUnits = string(val.effUnits);
            val.curveEffUnits = string(val.curveEffUnits);
            val.EffCurveCooling = [val.x4thPower val.x3rdPower val.x2ndPower ...
                val.x1stPower val.constant];
            val = removevars(val, ["x4thPower", "x3rdPower", "x2ndPower", ...
                "x1stPower", "constant"]);
        end  

        function val = getWeatherCityData()
            val = readtable('+ece\@Reference\WeatherCityData.csv');
            val.SiteName = string(val.SiteName);
            val.State = string(val.State);
        end

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
        % folder @pump. Private methods are only callable within
        % objects of this same class.

    end %methods (private)


    methods (Access = public, Static)
        % -- Declare Publically Accessible Static Methods Here
        % Public static methods declared here are defined in the class
        % folder @pump under the .m method script of the same name.
        % Static methods are callable through the pump class without
        % needing an instance of the object to be called.

        % FromSourceData - Method to generate an object from a set
        % of input data that defines properties.

    end %methods (public, Static)

end %classdef (pump)

