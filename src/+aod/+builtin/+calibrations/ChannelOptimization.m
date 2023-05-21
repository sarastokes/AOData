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
%   pmtPosition         double [1 x 3]
%       XYZ position of the PMT
%   sourcePosition      double [1 x 1]
%       Z position of the light source
%   Channel             aod.core.Channel or aod.persistent.Channel
%       Link to the Channel being optimized
%
% Parameters:
%   Wavelength          double
%       Wavelength of light source
%
% Methods:
%   setPmtPosition(obj, x, y, z)
%   setSourcePosition(obj, z)
%   setChannel(obj, z)

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        % XYZ position of PMT
        pmtPosition         double    
        % Z position of the light source  
        sourcePosition      double      

        % Channel being optimized
        Channel   {mustBeEntityType(Channel, 'Channel')} = aod.core.Channel.empty()
    end

    methods
        function obj = ChannelOptimization(name, calibrationDate, varargin)
            obj = obj@aod.core.Calibration(name, calibrationDate, varargin{:});
            
            % Optional input parsing
            ip = aod.util.InputParser();
            addParameter(ip, 'Channel', []);
            addParameter(ip, 'PmtPosition', []);
            addParameter(ip, 'SourcePosition', []);
            parse(ip, varargin{:});

            obj.setChannel(ip.Results.Channel);
            obj.setPmtPosition(ip.Results.PmtPosition);
            obj.setSourcePosition(ip.Results.SourcePosition);
        end

        function setPmtPosition(obj, xyz)
            if isempty(xyz) || nargin < 2
                obj.pmtPosition = [];
            else
                obj.pmtPosition = xyz;
            end
        end

        function setSourcePosition(obj, z)
            if isempty(z) || nargin < 2
                obj.sourcePosition = [];
            else
                obj.sourcePosition = z;
            end
        end

        function setChannel(obj, channel)
            if isempty(channel) || nargin < 2
                obj.Channel = aod.core.Channel.empty();
            else
                obj.Channel = channel;
            end
        end
    end

    methods (Static)
        function value = specifyAttributes()
            value = specifyAttributes@aod.core.Calibration();
            
            value.add('Wavelength', [], @isnumeric);
        end
    end
end 