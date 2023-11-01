classdef RoomMeasurement < aod.builtin.calibrations.MeasurementTable
% Measurements of temperature and humidity during experiment
%
% Description:
%   Record of room measurements made during the experiment
%
% Superclasses:
%   aod.builtin.calibrations.MeasurementTable
%
% Syntax:
%   obj = aod.builtin.calibrations.RoomMeasurement(calibrationDate, varargin)
%
% Properties:
%   measurements
%
% Methods:
%   addMeasurement(obj, timestamp, temperature, humidity)

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    methods
        function obj = RoomMeasurement(calibrationDate, varargin)
            obj = obj@aod.builtin.calibrations.MeasurementTable('RoomMeasurement', calibrationDate,...
                ["Time", "Temperature", "Humidity"], ["HH:mm", "Degrees F", "%"], varargin{:});
        end

        function addMeasurements(obj, varargin)
            % ADDMEASUREMENT
            %
            % Syntax:
            %   obj.addMeasurement(timestamp, temperature, humidity)
            %
            % Example:
            %   obj.addMeasurement('11:30', 71.1, 55);
            % -------------------------------------------------------------

            for i = 1:numel(varargin)
                iArg = varargin{i};
                iArg{1} = datetime(iArg{1}, "Format", "HH:mm");
                varargin{i} = iArg;
            end
            addMeasurements@aod.builtin.calibrations.MeasurementTable(obj, varargin{:});
        end
    end

    methods (Static)
        function UUID = specifyClassUUID()
			 UUID = "dd14deff-879e-45d0-a324-cbae977fed8e";
		end
    end
end