classdef DHWpipesMechRoom < handle & matlab.mixin.Copyable
    % DHWPIPESMECHROOM Class definition file for DHW pipes in the 
    % mechanical room.
    %   User enters the linear feet of pipe for each diameter and the type 
    % of pipe, copper or steel, insulated or not.
   
    properties (Access = public)
        % -- Define Public Properties
        % Name: String name for labeling an instance of the object.
        Name (1,1) string = "Default DHW PipesMechRoom";
        
        % Nominal diameter of pipe in inches
        % Default of .75 inch is to avoid error message (also reasonable
        % default)
        PipeDiameter_inch (1,1) double {mustBeMember(PipeDiameter_inch,...
            [0.375, 0.500, 0.750, 1.000, 1.250, 1.500, 2.000, 2.500,...
            3.000, 4.000, 5.000, 6.000, 8.000])} = 0.750;

        % linear feet of uninsulated or bare pipe, copper or steel (4
        % options)
        PipeType (1,1) ece.enum.PipeType = ...
            ece.enum.PipeType.CopperBare;

        % hours per year that this pipe is hot. default is all hours.
        HoursHot (1,1) double = 8760;

        % length of pipe section of this diameter in feet
        Length_ft (1,1) double = 0;

    end %properties (Public)

    properties (Access = public, Constant)
        % AllowableDiameters_inch: Allowable pipe diameters in inches, to
        % be supplied to PipeDiameter property.
        AllowableDiameters (13,1) double = [...
            0.375;...
            0.500;...
            0.750;...
            1.000;...
            1.250;...
            1.500;...
            2.000;...
            2.500;...
            3.000;...
            4.000;...
            5.000;...
            6.000;...
            8.000];

    end %properties (Constant)
  
    methods %Internal Methods
        % -- Internals-related Class Methods
        % Define Constructor Method
        function obj = DHWpipesMechRoom()
            %   Construct an instance of this class.

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

        % readSourceData: Method for importing object data from file.
        DHWpipesMechRoomTbl = readSourceData(fileName);

    end %methods (public, Static)

end %classdef (DHW pipes in the mechanical room)

