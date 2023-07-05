classdef MeasurementTable < aod.core.Calibration 
% Calibrations stored in a table, useful base for custom subclasses
%
% Superclasses:
%   aod.core.Calibration
%
% Constructor:
%   obj = aod.builtin.calibrations.MeasurementTable(name, calibrationDate,...
%       colNames, units, varargin)
%
% Methods:
%   addMeasurements(obj, varargin)
%   removeMeasurements(obj, idx)
%   loadTable(obj, measurementTable)
%
% Example:
%   obj = aod.builtin.calibrations.MeasurementTable('Demo', '20230314',...
%       ["Setting", "Value"], ["%", "uW"]);
%
% See also:
%   aod.builtin.calibrations.PowerMeasurement

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        % A table containing calibration measurements
        Measurements        table 
    end

    methods
        function obj = MeasurementTable(name, calibrationDate, colNames, units, varargin)
            obj@aod.core.Calibration(name, calibrationDate, varargin{:});
            
            obj.Measurements = table.empty(0, numel(colNames));
            obj.Measurements.Properties.VariableNames = colNames;
            if nargin > 3 && ~isempty(units)
                obj.Measurements.Properties.VariableUnits = units;
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
  
        function loadTable(obj, measurementTable)
            % LOADTABLE 
            %
            % Description:
            %   loadTable(obj, measurementTable)
            % -------------------------------------------------------------
            
            if istext(measurementTable)
                T = readmatrix(measurementTable);
                obj.setFile('Calibration', measurementTable);
            elseif istable(measurementTable)
                T = measurementTable;
            end
            % Check column names
        end
    end 

    % MATLAB builtin methods
    methods
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