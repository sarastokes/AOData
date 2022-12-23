classdef RoomMeasurement < aod.core.Calibration 
% Measurements of temperature and humidity during experiment
%
% Description:
%   Record of room measurements made during the experiment
%
% Parent:
%   aod.core.Calibration
% 
% Syntax:
%   obj = aod.builtin.calibrations.RoomMeasurement(calibrationDate)
%
% Properties:
%   measurements
%
% Methods:
%   addMeasurement(obj, timestamp, temperature, humidity)

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        measurements
    end

    methods
        function obj = RoomMeasurement(calibrationDate, varargin)
            obj = obj@aod.core.Calibration('RoomMeasurement', calibrationDate);
        end

        function addMeasurement(obj, timestamp, temperature, humidity)
            % ADDMEASUREMENT
            %
            % Syntax:
            %   obj.addMeasurement(timestamp, temperature, humidity)
            %
            % Example:
            %   obj.addMeasurement('11:30', 71.1, 55);
            % -------------------------------------------------------------
            arguments
                obj
                timestamp               string
                temperature             double
                humidity                double
            end

            for i = numel(timestamp)
                datestamp = datetime(timestamp(i), 'Format', 'HH:mm');
                %dur = obj.hoursmins2duration(timestamp(i));
                T = cell2table({datestamp, temperature(i), humidity(i)});
                T.Properties.VariableNames = {'Time', 'Temperature', 'Humidity'};
                T.Properties.VariableUnits = ["HH:mm", "Degrees F", "%"];
                if isempty(obj.measurements)
                    obj.measurements = T;
                else
                    obj.measurements = [obj.measurements; T];
                end
            end
        end
    end
end 