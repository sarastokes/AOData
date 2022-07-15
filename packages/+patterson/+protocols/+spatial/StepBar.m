classdef StepBar < patterson.protocols.spatial.Step
% STEPBAR
%
% Description:
%   Individual bar presented as a decrement followed by an increment
%
% Constructor:
%   obj = StepBar(stimTime, varargin)
%
% Parent class:
%   patterson.protocols.spatial.Step
%
% Properties (set as optional key/value inputs):
%   numBars
%   barID
%   orientation
%
% Notes:
%   - If numBars is not divisible by canvasSize, the barSize will be
%       rounded down with floor()
% -------------------------------------------------------------------------
    properties
        barID               % which bar to present (of numBars)
        numBars             % integer, ideally divisible by canvasSize
        orientation         % 'horizontal' or 'vertical'
    end

    properties (SetAccess = private)
        barSize             % pixels
    end

    methods
        function obj = StepBar(calibration, varargin)
            obj = obj@patterson.protocols.spatial.Step(calibration, varargin{:});
            
            ip = inputParser();
            ip.CaseSensitive = false;
            ip.KeepUnmatched = true;
            addParameter(ip, 'NumBars', 8, @isnumeric);
            addParameter(ip, 'BarID', 1, @isnumeric);
            addParameter(ip, 'Orientation', 'vertical',... 
                @(x) ismember(x, {'vertical', 'horizontal'}));
            parse(ip, varargin{:});

            obj.numBars = ip.Results.NumBars;
            obj.orientation = ip.Results.Orientation;
            obj.barID = ip.Results.BarID;

            % Input checking
            assert(obj.barID > 0 & obj.barID <= obj.numBars,...
                'BarID must be between 1 and NumBars!');

            % Derived parameters
            switch obj.orientation
                case 'vertical'
                    obj.barSize = floor(obj.canvasSize(1)/obj.numBars);
                case 'horizontal'
                    obj.barSize = floor(obj.canvasSize(2)/obj.numBars);
            end

            % Stimulus-specific parameters
            obj.groupBy = {'BaseIntensity', 'Contrast', 'NumBars', 'BarID'};
        end

        function stim = generate(obj)
            stim = obj.baseIntensity + zeros(obj.canvasSize(1), obj.canvasSize(2), obj.totalSamples);   
            for i = 1:obj.totalSamples
                stim((obj.barID-1) * obj.barSize+1 : obj.barID*obj.barSize, i) = trace(i);
            end
        end

        function fName = getFileName(obj)
            fName = getFileName@patterson.protocols.spatial.Step(obj);
            fName = [fName,'_', obj.orientation, ...
                sprintf('_bar_%uof%u', obj.barID, obj.numBars)];
        end
    end
end