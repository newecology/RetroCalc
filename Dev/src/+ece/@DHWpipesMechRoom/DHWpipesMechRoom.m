classdef DHWpipesMechRoom % < handle
    % class definition file for DHW pipes in the mechanical room
    % user enters the linear feet of pipe for each diameter and the type of
    % pipe, copper or steel, insulated or not
   
    properties (Access = public)
        % -- Define Public Properties
        
        % Nominal diameter of pipe in inches
        % Default of .75 inch is to avoid error message (also reasonable
        % default)
        PipeDiameter_inch (1,1) double {mustBeMember(PipeDiameter_inch, [.375, .5, .75, 1, 1.25, 1.5, 2, ...
            2.5, 3, 4, 5, 6, 8])} = .75

        % linear feet of uninsulated or bare pipe, copper or steel (4
        % options)
        PipeType (1,1) ece.enum.PipeType

        % hours per year that this pipe is hot. default is all hours.
        HoursHot (1,1) double = 8760

        % length of pipe section of this diameter in feet
        Length_ft (1,1) double


    end %properties (Public)
  
    methods
        % -- Internals-related Class Methods
        % Define Constructor Method
        function obj = DHWpipesMechRoom()
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

        DHWpipesMechRoomTbl = ReadSourceData(fileName);

    end %methods (public, Static)

end %classdef (DHW pipes in the mechanical room)

