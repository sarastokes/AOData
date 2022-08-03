classdef RoomMeasurement < aod.core.Calibration 
% ROOMMEASUREMENT
%
% Description:
%   Record of room measurements made during the experiment
%
% Parent:
%   aod.core.Calibration
% 
% Syntax:
%   obj = RoomMeasurement(calibrationDate, parent)
%
% Properties:
%   timestamp
%   temperature
%   humidity
%
% Methods:
%   addMeasurement(obj, timestamp, temperature, humidity)
%   T = table(obj)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        timestamp
        temperature
        humidity
    end

    methods
        function obj = RoomMeasurement(varargin)
            obj = obj@aod.core.Calibration(varargin{:});
        end

        function T = table(obj)
            % TABLE
            %
            % Description:
            %   Converts data into a table
            %
            % Syntax:
            %   T = table(obj)
            % -------------------------------------------------------------
            if isempty(timestamp)
                warning('RoomMeasurement: No data');
                T = [];
                return
            end
            T = table(obj.timestamp, obj.temperature, obj.humidity,...
                'VariableNames', {'Time', 'Temperature', 'Humidity'});
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
            for i = 1:numel(timestamp)
                obj.timestamp = cat(1, obj.timestamp,... 
                    datetime(timestamp, 'InputFormat', 'HH:mm'));
                obj.temperature = cat(1, obj.temperature, temperature);
                obj.humidity = cat(1, obj.humidity, humidity);
            end
        end
    end
end 