classdef Appliance < handle & matlab.mixin.Copyable
    %APPLIANCE Class definition file for Matlab representation of
    %Appliance.
   
    properties (Access = public)
        % -- Define Public Properties
        % Name: String name for labeling an instance of the object.
        Name (1,1) string = "Default Appliance";
        
        % ApplianceType - Enumeration for specific type of appliance, such 
        % as a specific kind of stove, dishwasher, refrigerator, etc.
        ApplianceType (1,1) ece.enum.ApplianceType = ...
            ece.enum.ApplianceType.InUnitGasStoves;

               

        % SubType: Additional description used for refrigerators and 
        % clothes dryers. i.e. front or top loading. Selection depends on
        % the Category of Appliance.
        SubType (1,1) string = "no subtype";
        
        % EfficiencyLevel: For now this is 1 standard or 2 Energy Star
        % except that for refrigerators, this is volume in ft3
        EfficiencyLevel (1,1) double = 1;

        % Quantity: How many of this type of appliance exists.
        Quantity (1,1) double = 0;
                
        % FracUnitsServed: Fraction of dwelling units served.
        %   EX: If half the dryers are electric and half are gas, the
        % option to define two instances with fraction of dwelling units
        % served by each.
        FracUnitsServed (1,1) double = 0;

        % UserAnnual_kWh: User-supplied annual electricity use (kWh/year)
        % per appliance. Only used when ApplianceType == CustomAppliance.
        % Can be zero (e.g., a gas-only custom appliance).
        UserAnnual_kWh (1,1) double = 0;

        % UserAnnual_therms: User-supplied annual gas use (therms/year)
        % per appliance. Only used when ApplianceType == CustomAppliance.
        % Can be zero (e.g., an electric-only custom appliance).
        UserAnnual_therms (1,1) double = 0;

        % SensibleGainFrac: Fraction of total energy use (converted to
        % kBtu) that becomes sensible internal gain in conditioned space.
        % Default 0.9 assumes an electric appliance located in the
        % conditioned space (nearly all input becomes sensible heat).
        % Gas in-space unvented ~0.4; any vented appliance ~0.05.
        % Only used when ApplianceType == CustomAppliance.
        SensibleGainFrac (1,1) double = 0.9;

        % LatentGainFrac: Fraction of total energy use (converted to
        % kBtu) that becomes latent internal gain (moisture). Default 0
        % assumes electric. Gas in-space unvented ~0.3; vented ~0.
        % Only used when ApplianceType == CustomAppliance.
        LatentGainFrac (1,1) double = 0.0;

    end %properties (Public)


    properties (GetAccess = public, Dependent)
        % Code: Appliance code to simplify programming statements.
        Code (1,:) string

        % SelectableSubtypes: String array of all selectable subtype for an
        % Appliance.
        SelectableSubtypes (:,1) string
      
        % EfficiencyLevelDescriptor: Descriptive text to explain what the 
        % metric of efficiency correlates to.
        EffLevelDescriptor (1,1) string

                % ApplianceCategory: Enum member to specify appliance category
        % type, derived from the Appliance Type. General version of Type.
        ApplianceCategory (1,1) ece.enum.ApplianceCategory 

    end %properties (Dependent)

  
    properties (SetAccess = {?ece.Appliance, ?ece.Building}, GetAccess = public)
        % -- Define Read-Only-From-Outside Properties
        % results array for energy use and internal gains of each appliance
        % row 1 gas use therms. row 2 electric use kWh
        % row 3 sensible internal gains kBtu. row 4 latent internal gains
        % kBtu. 12 months then annual total.
        % Populated by ece.Building.calculateApplianceElectricAndGasUse —
        % hence the restricted SetAccess that permits Building methods
        % to write while blocking generic external assignment.
        resultsArray (4,13) double = zeros(4,13)

    end %properties (Read-Only)



    methods % Internal Methods

        function obj = Appliance()
            %   Construct an instance of this class.

        end %function (constructor)

        % Method to derive Appliance category from type
        function value = get.ApplianceCategory(obj)
         switch obj.ApplianceType
           case {ece.enum.ApplianceType.InUnitGasStoves, ...
              ece.enum.ApplianceType.InUnitElectricStoves, ...
              ece.enum.ApplianceType.CommercialOvenElectric, ...
              ece.enum.ApplianceType.CommercialGriddleElectric}
            value = ece.enum.ApplianceCategory.Stove;

           case {ece.enum.ApplianceType.InUnitDishwashers, ...
              ece.enum.ApplianceType.CommercialDishwashers}
            value = ece.enum.ApplianceCategory.Dishwasher;

           case {ece.enum.ApplianceType.InUnitClotheswashers, ...
              ece.enum.ApplianceType.CommonAreaClotheswashers}
            value = ece.enum.ApplianceCategory.Clotheswasher;

           case {ece.enum.ApplianceType.InUnitGasClothesDryers, ...
              ece.enum.ApplianceType.InUnitElectricClothesDryers, ...
              ece.enum.ApplianceType.CommonAreaGasClothesDryers, ...
              ece.enum.ApplianceType.CommonAreaElectricClothesDryers}
            value = ece.enum.ApplianceCategory.Dryer;

           case ece.enum.ApplianceType.Refrigerators
            value = ece.enum.ApplianceCategory.Refrigerator;

           case ece.enum.ApplianceType.CustomAppliance
            value = ece.enum.ApplianceCategory.Custom;

           otherwise
            value = ece.enum.ApplianceCategory.None;
         end
        end


        function value = get.SelectableSubtypes(obj)
            % Getter for SelectableSubtypes.
            %   Returns the string array of all Subtypes that can be
            %   selected for the given ApplianceType. This is used to help
            %   populate dropdowns as well as confirm that the right subset
            %   of types is chosen. These values are obtained from the
            %   Reference file for appliances.

            % -- Acquire Reference to ApplianceTable Reference
            % Read ApplianceRef
            applRefTable = ece.Reference.ApplianceDataTable;

            % -- Obtain Subtypes
            % Gather Type to use for pulling valid SubTypes for selection.
            applType = obj.ApplianceType;

            % Obtain all SubTypes in reference table that map to the
            % current application type.
            validSubtypesMask = ...
                (applRefTable.ApplianceType == applType);
            validSubtypes = applRefTable.SubType(validSubtypesMask);

            % Reduce to only unique subtypes.
            validSubtypes = unique(validSubtypes);

            % -- Return Subtypes
            % Check if subtypes exists to return empty string, otherwise
            % return the subtypes.
            if ~isempty(validSubtypes)
                % Return validSubtypes
                value = validSubtypes;
            else
                % Return empty string of valid subtypes.
                value = string.empty(0,1);
            end %endif

        end %function (Getter)


        function value = get.EffLevelDescriptor(obj)
            % Getter for EffLevelDescriptor.
            %   Returns the string description for how the EfficiencyLevel
            %   property is used for the given appliance.
            %   In this case, Refrigerator-Type objects use the property
            %   for volume_ft3, but all others use it for Energy Level.

            % Determine if appliance type is fridge.
            isRefrigerator = (obj.ApplianceType == ...
                ece.enum.ApplianceType.Refrigerators);
            isCustom = (obj.ApplianceType == ...
                ece.enum.ApplianceType.CustomAppliance);

            if isRefrigerator
                % Refrigerators --> volume in cubic feet.
                value = "volume_ft3";
            elseif isCustom
                % Custom --> efficiency level is not used; user supplies
                % absolute kWh/therms directly on the object.
                value = "n/a (user-rated)";
            else
                % All Else --> Energy Star Rating
                value = "1 standard, 2 Energy Star";
            end %endif

        end %function (Getter)

        function value = get.Code(obj)
            % Getter for Code property.
            %   The Code property is used to help define how a particular
            %   Appliance is processed in the logic. The code is set based
            %   on the Appliance's Type, SubType, and EfficiencyLevel, and
            %   is derived from the ApplianceReferenceTable.

            % -- Obtain Reference Table
            % Get copy of appliance reference tables.
            applRefTable = ece.Reference.ApplianceDataTable;

            % -- Map Appliance Properties to Code
            % Check if appliance is refrigerator.
            isRefrigerator = ...
                (obj.ApplianceType == ece.enum.ApplianceType.Refrigerators);
            

            % Create Code Mask based on Appliance Type
            if isRefrigerator
                % -- Acquire Code for Refrigerators
                % Use Appliance Type & SubType to search for Code in
                % reference table.
                applCodeMask = ...
                    (applRefTable.ApplianceType == obj.ApplianceType) & ...
                    (applRefTable.SubType == obj.SubType);

            else
                % -- Acquire Code for Other Appliances
                % Use Appliance Type, SubType, & EfficiencyLevel to search
                % for Code in reference table.
                applCodeMask = ...
                    (applRefTable.ApplianceType == obj.ApplianceType) & ...
                    (applRefTable.SubType == obj.SubType) & ...
                    (applRefTable.EfficiencyLevel == obj.EfficiencyLevel);

            end %endif

            % -- Extract Code
            % Use Mask to pull Code from ReferenceTable as row vector.
            applCode = applRefTable.Code(applCodeMask)';

            % Catch empty mask output.
            if isempty(applCode)
                % Return default Code string.
                value = "";

            else
                % Return discovered Code string pair.
                value = applCode;

            end %endif



        end %function (Getter)


    end %methods (public Internals)

    methods   (Access = public, Static)
        % -- Declare Publically Accessible Static Methods Here
        % Public static methods declared here are defined in the class
        % folder  .m method script of the same name.
        % Static methods are callable through the class without
        % needing an instance of the object to be called.
        % FromSourceData - Method to generate an object from a set
        % of input data that defines properties.

        ApplianceTbl = readSourceData(fileName);

        % data table with standard values for energy usage 
        %ApplianceDataTbl = ReadApplianceData(fileName);


    end %methods (public, Static)

   % methods (Access = public)

        % calculate gas, electric usage, internal gains for each
        %calculateApplianceElectricAndGasUse

   % end  % methods, public


end %classdef (Appliance)
