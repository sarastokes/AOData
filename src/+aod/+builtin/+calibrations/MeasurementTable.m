classdef MeasurementTable < aod.core.Calibration 
% Calibrations stored in a table
%
% Superclasses:
%   aod.core.Calibration
%
% Example:
%   obj = aod.builtin.calibrations.MeasurementTable('Demo', '20230314',...
%       ["Setting", "Value"], ["%", "uW"]);


% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        % A table containing calibration measurements
        Measurements        table 
    end

    properties (Dependent)
        numMeasurements     double  {mustBeInteger}
    end

    methods
        function obj = MeasurementTable(name, calibrationDate, measurements, units)
            obj@aod.core.Calibration(name, calibrationDate);
            
            obj.Measurements = table.empty(0, numel(measurements));
            obj.Measurements.Properties.VariableNames = measurements;
            if nargin > 3 && ~isempty(units)
                obj.Table.Properties.VariableUnits = units;
            end
        end

        function value = get.numMeasurements(obj)
            if isempty(obj)
                value = 0;
            else
                value = height(obj.Measurements);
            end
        end
    end

    methods 
        function addMeasurements(obj, varargin)
            % Add measurements by row
            %
            % Syntax:
            %   addMeasurements(obj, varargin)
            %
            % Examples:
            %   % Add two rows of measurements
            %   obj.add({"High", 20, 10}, {"Low", 20, 22})
            %
            % Notes:
            %   All char entries will be converted to string
            % -------------------------------------------------------------
            if ~iscell(varargin{1})
                error('addMeasurements:InvalidInput',...
                    'Each row must be specified as a cell');
            end
            for i = 1:numel(varargin)
                iRow = cellfun(@(x) convertCharsToStrings(x), varargin{i},... 
                    'UniformOutput', false);
                obj.Measurements = [obj.Measurements; iRow];
            end
        end

        function removeMeasurements(obj, idx)
            % Remove measurements by row
            %
            % Syntax:
            %   removeMeasurements(obj, idx)
            %
            % Examples:
            %   % Remove the 2nd and 3rd measurements
            %   obj.remove([2, 3])
            % -------------------------------------------------------------
            obj.Measurements(idx, :) = [];
        end
    end 

    % MATLAB builtin methods
    methods
        function tf = isempty(obj)
            tf = isempty(obj.Measurements);
        end

        function T = table(obj)
            % Return the measurement table
            % 
            % Syntax:
            %   T = table(obj)
            % -------------------------------------------------------------
            T = obj.Measurements;
        end
    end
end 