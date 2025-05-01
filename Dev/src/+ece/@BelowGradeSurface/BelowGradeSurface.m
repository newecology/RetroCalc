classdef BelowGradeSurface  < handle
    %   Below grade surface class definition file for below grade surface object.
    %   This is a collection of properties that describe a set of below grade surfaces
    %   such as a basement or crawl space.
    %   Rarely a building may have more than one set of below grade surfaces.
    
    properties (Access = public)
        % -- Define Public Properties of the below grade space
        
        %Area of below grade wall in square feet
        BGwallArea_ft2 (1,1) double

        % R value of below grade wall insulation if any in hr-ft2-F/Btu
        % The insulation if any starts at grade level and extends down to 
        % WallInsulDepthBelowGrade
        BGwallInsulR (1,1) double
                
        % Wall insulation depth below grade in feet (if any wall insulation)
        WallInsulDepthBelowGrade_ft (1,1) double

        % Area of below grade floor in square feet
        BGfloorArea_ft2 (1,1) double

        % R value of below grade floor insulation if any in hr-ft2-F/Btu
        BGfloorInsulR (1,1) double

        % Basement or crawl space floor depth below grade in feet
        BasementDepthBelowGrade_ft (1,1) double

        % Basement or crawl space temperature in °F
        BasementTemp_F (1,1) double

        % Basement or crawl space perimeter in feet
        BasementPerimeter_ft (1,1) double

        % Basement or crawl space minimum dimension in feet
        % For a rectangular space, this is just the shortest side.
        BasementMinDimension_ft (1,1) double

        % Soil thermal conductivity in Btu/hr-ft-°F
        SoilThermalConductivity (1,1)
        % move to site class

        % R value of a standard uninsulated concrete foundation wall
        % with the interior air film only
        BaseSlabR (1,1) double = 1.47

        % Amplitude of ground surface temperature for the location, °F
        GroundSurfaceTempAmplitude_F (1,1) double
        % move to site class

        % Ground mean annual temperature for the location, °F
        GroundMeanAnnualTemp_F (1,1) double
        % move to site class

        %Phase constant for time lag in days for the location
        PhaseConstantForTimeLag_days (1,1) double
        % move to site class

    end %properties (Public)

%     properties (Access = public, Dependent)
%         % -- Define Dependent Properties
%         % Monthly heat loss in kBtu/month for each of the 12 months, for walls and floor
%         % of below grade spaces
%         BelowGradeWallMonthHeatLoss (1,12) double
%         
%         BelowGradeFloorMonthHeatLoss (1,12) double
% 
%     end %properties (public, dependent)
%     

    properties (Dependent)
        % Setting the output values to Dependent so that they can be easily
         % updated with each object 
        % -- Define Read-Only Properties
        % monthly heat loss from walls of below grade surfaces
        BGwallMonthHeatLoss_kBtu (1,12) double

        % monthly heat loss from floor of below grade surfaces
        BGfloorMonthHeatLoss_kBtu (1,12) double

    end %properties (Read-Only)



    methods
        % -- Internals-related Class Methods
        % Define Constructor Method
        function obj = BelowGradeSurface()
            %Construct an instance of this class
            
        end %function (constructor)

        % -- Property Get Methods
         function value = get.BGwallMonthHeatLoss_kBtu (obj)
             [value, ~] = obj.calculateBGsurfaceHeatLoss;
         end  % property getter function

         function value = get.BGfloorMonthHeatLoss_kBtu(obj)
             [~, value] = obj.calculateBGsurfaceHeatLoss;
         end  % property getter function


     end % methods internals

     methods (Access = public)
 
         % calculate heat loss
         [BGwallMonthHeatLoss_kBtu, BGfloorMonthHeatLoss_kBtu] = calculateBGsurfaceHeatLoss(obj);
 
     end  % methods, public


   
      methods   (Access = public, Static)
        % -- Declare Publically Accessible Static Methods Here
        % Public static methods declared here are defined in the class
        % folder @BelowGradeSurface under the .m method script of the same name.
        % Static methods are callable through the BelowGradeSurface class without
        % needing an instance of the object to be called.

        % FromSourceData - Method to generate a BelowGradeSurface object from a set
        % of input data that defines properties.
        %fileName = "C:\Users\HenryHarvey\Desktop\Projects\MATLAB\Nov2023\L2calcs\calcInputs8";
        %belowGradeSurfacesTbl = ReadBelowGradeSurfacesDataFromExcel(fileName); 
        belowGradeSurfacesTbl = ReadSourceData(fileName);

        % read table of soil conductivity values from data source (Excel
        % file)
        % soilConductivityTbl = ReadSoilConductivityDataFromExcel(fileName); 
    
         % calculate 
         %[BGwallMonthHL, BGfloorMonthHL] = calculateBGsurfaceHeatLoss(obj)
 

        % fan = fromSourceData(inData, options);
       

      end %methods (public, Static)


end %classdef (SlabOnGrade)

