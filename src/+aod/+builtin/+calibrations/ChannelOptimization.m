classdef ChannelOptimization < aod.core.Calibration 
% Optimization of PMT and source position
%
% Description:
%   Logs optimization of PMT and source position prior to an experiment
%   and optionally adds adjustments made during the experiment
%
% Syntax:
%   obj = Optimization(name, calibrationDate, varargin)
%   obj = aod.builtin.calibrations.ChannelOptimization(name, calibrationDate,...
%       'Wavelength', value, 'PmtPosition', value,...
%       'SourcePosition', value, 'Channel', value);
%
% Properties:
%   positions         table
%       PMT XYZ and source position
%   iterations          double
%       Optimization iterations and mean light levels
%
% Parameters:
%   Wavelength          double
%       Wavelength of light source
%
% Methods:
%   setPmtPosition(obj, modelEye, varargin)
%   setIterations(obj, data)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        % Rows: ModelEye, InVivo. Columns: X, Y, Z, Source
        positions               table = table.empty()
        % Optimization iterations and mean light levels
        iterations              double
    end

    methods
        function obj = ChannelOptimization(name, calibrationDate, varargin)
            obj = obj@aod.core.Calibration(name, calibrationDate, varargin{:});

            obj.positions = table(...
                [NaN NaN]', [NaN NaN]', [NaN NaN]', [NaN NaN]',...
                'VariableNames', {'X', 'Y', 'Z', 'Source'},...
                'RowNames', {'ModelEye', 'InVivo'});
        end

        function setWavelength(obj, value)
            obj.setParam('Wavelength', value);
        end

        function setPosition(obj, modelEye, varargin)
            % Set positions for model eye or in vivo
            %
            % Syntax:
            %   setPosition(obj, modelEye, varargin)
            %
            % Examples:
            %   % Set the X and Y position for model eye
            %   setPosition(true, 'X', 4, 'Y', 5);
            %
            %   % Set the Source position for in vivo
            %   setPosition(false, 'Source', 5);
            % -------------------------------------------------------------

            ip = inputParser();
            ip.CaseSensitive = false;
            addParameter(ip, 'X', [], @isnumeric);
            addParameter(ip, 'Y', [], @isnumeric);
            addParameter(ip, 'Z', [], @isnumeric);
            addParameter(ip, 'Source', [], @isnumeric);
            parse(ip, varargin{:});

            if modelEye 
                rowName = "ModelEye";
            else
                rowName = "InVivo";
            end
            
            changedInputs = setdiff(ip.Parameters, ip.UsingDefaults);
            for i = 1:numel(changedInputs)
                obj.positions(rowName, changedInputs{i}) = ip.Results.(changedInputs{i});
            end
        end
    end

    methods (Static)
        function value = specifyAttributes()
            value = specifyAttributes@aod.core.Calibration();
            
            value.add('Wavelength', [], @isnumeric,...
                'The wavelength of the light source in the optimization (nm)');
        end

        function d = specifyDatasets(d)
            d = specifyDatasets@aod.core.Calibration(d);

            d.set("iterations",...
                "Class", "double",...
                "Description", "Mean light levels for optimization iterations");
            d.set("positions",...
                "Class", "table",...
                "Description", "PMT xyz and source positions (columns) for model eye and in vivo (rows)");
        end
    end
end 