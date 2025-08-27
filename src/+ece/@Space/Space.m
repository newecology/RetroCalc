classdef Space < handle & matlab.mixin.Copyable
    %   Space class definition file for space object.
    %   An space object is a collection of properties that describe an
    %   space in the building such as residential, corridor, etc.
    
    properties (Access = public)
        % -- Define Public Properties of OpaqueSurface
        % Name: String name for labeling an instance of the object.
        Name (1,1) string = "Default Space";
        
        % Type - Enumeration for space type.
        SpaceType (1,1) ece.enum.SpaceType = ...
            ece.enum.SpaceType.Residential;

        % Area_ft2 - area of the opaque surface in square feet.
        Area_ft2 (1,1) double = 0;

        % lighting power density in W/m2
        LPD_Wft2 (1,1) double = 0;

        % equipment power density in W/m2
        EPD_Wft2 (1,1) double = 0;

        % sensible gains from people in Btu/hr per person
        SensGain_BtuHrPerson (1,1) double = 0;
        
        % latent gains from people in Btu/hr per person
        LatGain_BtuHrPerson (1,1) double = 0;
       
        % lighting equivalent full load hours per day
        LgtEFLHday (1,1) double	= 0;

        % miscellaneous equipment equivalent full load hours per day
        EquipEFLHday (1,1) double = 0;
       
        % people equipment equivalent full load hours per day
        PeopleEFLHday (1,1) double = 0;
       
        % square feet per person for the space
        Ft2person (1,1) double = 0;

    end %properties (Public)

    properties (Access = public, Dependent)
        % -- Define Dependent Properties
        
    end %properties
    
    methods
        % -- Internals-related Class Methods
        % Define Constructor Method
        function obj = Space()
            %Space Construct an instance of this class
            %   The default constructor takes no arguments and
            %   returns a default instance of the object. An
            %   object with loaded values can be instanced with
            %   the fromSourceData static method.
            %   This object construction style is useful when testing
            %   objects that are intended to be populated from external
            %   data, as it decouples the object's existence from the
            %   intended supplemental data.
            
        end %function (constructor)

    end %methods (public Internals)

    methods   (Access = public, Static)
        % -- Declare Publically Accessible Static Methods Here
    
        % readSourceData - Method to generate a an object from a set
        % of input data that defines properties.
        spaceArr = readSourceData(fileName); 

      end %methods (public, Static)



end %classdef (Space)

