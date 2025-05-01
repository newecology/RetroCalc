classdef Appliance % < handle
    %   class definition file for Matlab
   
    properties (Access = public)
        % -- Define Public Properties
        
        % appliance category 
        ApplianceCategory (1,1) ece.enum.ApplianceCategory
                
        % Type - Enumeration for appliance type 
        % Stoves, dishwashers, refrigerators etc for all types
        ApplianceType (1,1) ece.enum.ApplianceType

        % subtype, additional description used for refrigerators and clothes
        % dryers. i.e. front or top loading, age etc
        SubType (1,1) string
        
        % Efficiency level. for now this is 1 standard or 2 Energy Star
        % except that for refrigerators, this is volume in ft3
        EfficiencyLevel (1,1) double

        % Efficiency level descriptor - tells user what the metric is for
        % efficiency
        EffLevelDescriptor (1,1) string

        % Quantity - how many of that type of appliance in the building
        Quantity (1,1) double
                
        % Fraction of dwelling units served. If half the dryers are electric
        % and half are gas, for example, user has the option to define two
        % instances with fraction of dwelling units served by each.
        FracUnitsServed (1,1) double

        % appliance code to simplify programming statements
        Code (1,2) string

    end %properties (Public)
  
    properties %(SetAccess = private, GetAccess = public)
        % -- Define Read-Only Properties
        % results array for energy use and internal gains of each appliance
        % row 1 gas use therms. row 2 electric use kWh
        % row 3 sensible internal gains kBtu. row 4 latent internal gains
        % kBtu. 12 months then annual total
        resultsArray (4,13) double

       
    end %properties (Read-Only)



    methods
        % -- Internals-related Class Methods
        % Define Constructor Method
        function obj = Appliance()
            %   Construct an instance of this class        
        end %function (constructor)
     
    end %methods (public Internals)

    methods   (Access = public, Static)
        % -- Declare Publically Accessible Static Methods Here
        % Public static methods declared here are defined in the class
        % folder  .m method script of the same name.
        % Static methods are callable through the class without
        % needing an instance of the object to be called.
        % FromSourceData - Method to generate an object from a set
        % of input data that defines properties.

        ApplianceTbl = ReadSourceData(fileName);

        % data table with standard values for energy usage 
        %ApplianceDataTbl = ReadApplianceData(fileName);


    end %methods (public, Static)

   % methods (Access = public)

        % calculate gas, electric usage, internal gains for each
        %calculateApplianceElectricAndGasUse

   % end  % methods, public


end %classdef (Appliance)
