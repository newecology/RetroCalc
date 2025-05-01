classdef SlabOnGrade % < handle
    %   SlabOnGrade class definition file for slab on grade object.
    %   This is a collection of properties that describe a slab on grade.
    %   A single slab on grade object describes a certain instance. Rarely
    %   a building may have more than one slab on grade.
    
    properties (Access = public)
        % -- Define Public Properties of slab on grade
        
        %Perimeter of slab in feet
        Perimeter_ft (1,1) double

        % Area_ft2 - area of the slab surface in square feet.
        % This is not used for slab heat loss, but is used to determine the
        % shell area of the building.
        Area_ft2 (1,1) double

        % F factor - Heat loss factor for the slab on grade, from ASHRAE
        % 90.1 or the ASHRAE Fundamentals handbook.
        % Btu/hr-F per linear foot
        Ffactor (1,1) double

    end %properties (Public)

    properties (Access = public, Dependent)
        % -- Define Dependent Properties
        % HeatLossCoeff - Heat loss coefficient for surface, in units of
        % Btu/hr-F
        HeatLossCoeff (1,1) double

    end %properties
    
    methods
        % -- Internals-related Class Methods
        % Define Constructor Method
        function obj = SlabOnGrade()
            %SlabOnGrade - Construct an instance of this class
            
        end %function (constructor)

        function value = get.HeatLossCoeff(obj)
            % Get HeatLossCoeff Value - Method to calculate the
            % HeatLossCoeff values from other properties.
            % The Heat Loss Coefficient is the perimeter multiplied by the F factor.
            % Calculate Output HLC
            value = obj.Perimeter_ft * obj.Ffactor;

        end %function (HeatLossCoeff)
        
    end %methods (public Internals)

    methods   (Access = public, Static)
        % Public static methods declared here are defined in the class
        % folder  .m method script of the same name.
        % FromSourceData - Method to generate an object from inputs

        slabTbl = ReadSourceData(fileName);

    end %methods (public, Static)

end %classdef (SlabOnGrade)

