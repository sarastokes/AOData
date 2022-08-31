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
%   obj = RoomMeasurement(calibrationDate)
%
% Properties:
%   measurements
%
% Methods:
%   addMeasurement(obj, timestamp, temperature, humidity)
%   T = table(obj)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        measurements
    end

    methods
        function obj = RoomMeasurement(calibrationDate, varargin)
            obj = obj@aod.core.Calibration([], calibrationDate);

            ip = aod.util.InputParser();
            addParameter(ip, 'TemperatureUnits', 'F', @ischar);
            addParameter(ip, 'HumitityUnits', '%', @ischar);
            parse(ip, varargin{:});

            obj.setParam(ip.Results);
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
                datestamp = datetime([...
                    datestr(obj.calibrationDate), ' ', char(timestamp(i))],... 
                    'InputFormat', 'dd-MMM-yyyy HH:mm');
                if isempty(obj.measurements)
                    obj.measurements = cell2table({datestamp, temperature(i), humidity(i)});
                    obj.measurements.Properties.VariableNames = {'Time', 'Temperature', 'Humidity'};
                else
                    obj.measurements = [obj.measurements;...
                        {datestamp, temperature(i), humidity(i)}];
                end
            end
        end
    end
end 