classdef Space % < handle
    %   Space class definition file for space object.
    %   An space object is a collection of properties that describe an
    %   space in the building such as residential, corridor, etc.
    
    properties (Access = public)
        % -- Define Public Properties of OpaqueSurface
        
        % Type - Enumeration for space type.
        SpaceType (1,1) ece.enum.SpaceType

        % Area_ft2 - area of the opaque surface in square feet.
        Area_ft2 (1,1) double

        % lighting power density in W/m2
        LPD_Wft2 (1,1) double

        % equipment power density in W/m2
        EPD_Wft2 (1,1) double

        % sensible gains from people in Btu/hr per person
        SensGain_BtuHrPerson (1,1) double
        
        % latent gains from people in Btu/hr per person
        LatGain_BtuHrPerson (1,1) double	
       
        % lighting equivalent full load hours per day
        LgtEFLHday (1,1) double	

        % miscellaneous equipment equivalent full load hours per day
        EquipEFLHday (1,1) double	
       
        % people equipment equivalent full load hours per day
        PeopleEFLHday (1,1) double	
       
        % square feet per person for the space
        Ft2person (1,1) double

    end %properties (Public)

    properties (Access = public, Dependent)
        % -- Define Dependent Properties
        
    end %properties
    
    methods
        % -- Internals-related Class Methods
        % Define Constructor Method
        function obj = Space()
            %OpaqueSurface Construct an instance of this class
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
    
        % FromSourceData - Method to generate a an object from a set
        % of input data that defines properties.
        %fileName = "C:\Users\HenryHarvey\Desktop\Projects\MATLAB\Nov2023\L2calcs\calcInputs8";
        SpacesTbl = ReadSourceData(fileName); 

      end %methods (public, Static)



end %classdef (Space)

