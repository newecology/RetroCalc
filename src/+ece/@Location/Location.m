classdef Location < handle & matlab.mixin.Copyable
    % LOCATION Class to store all location-based properties for computing
    % location-dependent parameters.

    properties (Access = public)
        %location properties of site includes, city, state and coordinates
        % City: String name of City.
        City (1,1) string = "Boston";

        % State: Two-character string name of State.
        State (1,1) string = "MA";

        % Latitude: Constrained Latitude for location.
        Latitude (1,1) double {mustBeInRange(Latitude,18.9,71.39)} = ...
            42.35;

        % Longitude: Constrained Longitude for Location.
        Longitude (1,1) double {mustBeInRange(Longitude,-180,-66.9)} = ...
            -71.06;

    end %properties (public)

    properties (Dependent)
        % Amplitude of ground surface temperature for the location, °F
        GroundSurfaceTempAmplitude_F (1,1) double

        % Ground mean annual temperature for the location, °F
        GroundMeanAnnualTemp_F (1,1) double

        CDD_monthly table
        HDD_monthly table

    end %properties (Public, dependent)

    % Properties to import from external sources
    properties (SetAccess = private, GetAccess = public)
        % WeatherDataTable: Table containing a year of average hourly 
        % weather, usually taken from TMY3 or TMY3x weather data files.
        WeatherDataTable table 

        % HistoricalDDTable: Historical degree day table that contains
        % three columns: Time, HDD, CDD.
        HistoricalDDTable (:,3) table = table.empty(0,3);
        
    end %end

    methods % Internal methods (Constructors + Getters)
        
        % Define Constructor Method
        function obj = Location()
            %LOCATION Construct an instance of the Location class.

        end %function (Constructor)

        function value = get.GroundSurfaceTempAmplitude_F(obj)
            % Getter for GroundSurfaceTempAmplitude_F.
            %   Using the Location's lat/long, derive the
            %   groundSurfaceAmplitude value.

            % Obtain value from reference file.
            value = ece.Reference.getUSGroundSurfaceAmplitude(...
                obj.Latitude,obj.Longitude);

        end %function

        function value = get.GroundMeanAnnualTemp_F(obj)
            % Getter for GroundMeanAnnualTemp_F.
            %   Uses the mean of hourly dry-bulb air temperature as a 
            %   practical proxy.
            %   - Assumes obj.WeatherDataTable contains a 'DryBulb' column 
            %   in °C (e.g., from EPW/TMY3). 
            %   - NaNs are ignored in the average.
            
            % -- Return NaN if No Data
            % Check if source tables are empty or contain no data.
            noWeatherData = isempty(obj.WeatherDataTable);
            if noWeatherData
                % Return NaN value.
                value = NaN;
                return;
            end %endif

            % -- Enforce Existence of DryBulb Column
            % Case-insensitive lookup for 'DryBulb'
            varNames = string(obj.WeatherDataTable.Properties.VariableNames);
            colIdx = find(strcmpi(varNames, 'DryBulb'), 1);
            if isempty(colIdx)
                % Report Error
                error("WeatherDataTable does not contain a " + ...
                    "''DryBulb'' column.");
            end %endif

            % -- Calculate Value
            % All required inputs have been validated, so assign value.
            % Extract and validate data.
            dryBulbColumnName = varNames(colIdx);
            dryBulbC = obj.WeatherDataTable.(dryBulbColumnName);

            % Mean in °C (omit NaNs), then convert to °F
            meanC = mean(dryBulbC, 'omitnan');
            value = meanC * (9/5) + 32;
        end %function

        function value = get.CDD_monthly(obj)
                        % Extract year and month from dates
            years = year(obj.HistoricalDDTable.Date);
            months = month(obj.HistoricalDDTable.Date);
            
            % Get unique years
            uniqueYears = unique(years);
            
            
            value = array2table(zeros(length(uniqueYears), 12), ...
                'VariableNames', {'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'}, ...
                'RowNames', string(uniqueYears));
            
            % Sum by year and month
            for i = 1:length(uniqueYears)
                for m = 1:12
                    idx = (years == uniqueYears(i)) & (months == m);

                    value{i, m} = sum(obj.HistoricalDDTable.CDD70(idx));
                end
            end
        end

        function value = get.HDD_monthly(obj)
                        % Extract year and month from dates
            years = year(obj.HistoricalDDTable.Date);
            months = month(obj.HistoricalDDTable.Date);
            
            % Get unique years
            uniqueYears = unique(years);
            
            
            value = array2table(zeros(length(uniqueYears), 12), ...
                'VariableNames', {'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'}, ...
                'RowNames', string(uniqueYears));
            
            % Sum by year and month
            for i = 1:length(uniqueYears)
                for m = 1:12
                    idx = (years == uniqueYears(i)) & (months == m);

                    value{i, m} = sum(obj.HistoricalDDTable.HDD65(idx));
                end
            end
        end

    end %methods (Internal)

    methods (Access = public)
        %Function to import the Location
        importLocation(obj,dataSource);

        %Funtion to import the weather data TMY from file for L2 analysis
        importWeatherData(obj,dataSource);

        %Function to import the historical DD data for HEA analysis
        importHistoricalDDTable(obj,dataSource);

        %Function to import hist DD table using API
        [statusOK,msg] = importHistoricalDDTable_API(obj);
        
    end %methods
     
end %classdef