classdef Solar <handle
    %SOLAR Class definition file for a Solar object.
    %   The Solar class defines a static blueprint for making API calls to
    %   the service that provides Solar information.
    
    properties (Constant)
        % -- Define Constant Properties
        % Read-Only properties can be seen but not modified by external
        % scopes.

        % QueryURL - Site URL to obtain Solar data from.
        QueryURL (1,1) string = "https://developer.nrel.gov/api/pvwatts/v8.json?";

        % APIkey - API key for Solar Data
        APIkey (1,1) string = "P0sSoorvBg09LdLScLrud4fkoSG4c9JWVVR2ykZI";

        % DatasetType - Type of dataset to return from Solar API
        DatasetType (1,1) string = "nsrdb";

        % SystemCapacity - Capacity of System
        SystemCapacity (1,1) double = 4;

        % Losses - Losses tracked by solar
        Losses (1,1) double = 14;

        % ArrayType - Type of array of returned data.
        ArrayType (1,1) double = 0;

        % ModuleType - Type of module used in the API call.
        ModuleType (1,1) double = 0;

    end %properties (Read-Only)
    
    methods (Access = public, Static)
        % -- Define Static Methods 
        % Static methods can be called without needing an instance of the
        % class object. This enables common functionality to be grouped
        % under a class header and used anywhere without being tied to a
        % specific implementation.

        % GetSolarData - Static method to pass in azimuth, tilt, and
        % address location data to get the corresponding pvWattsData
        % structure about the Solar results for that position and location.
        pvWattsData = getSolarData(azimuth, tilt, latitude, longitude);



    end %methods (public, Static)

end %classdef (Solar)

