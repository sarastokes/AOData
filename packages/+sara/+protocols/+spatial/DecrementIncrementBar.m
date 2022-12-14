classdef DecrementIncrementBar < sara.protocols.spatial.DecrementIncrement
% DECREMENTINCREMENTBARS
%
% Description:
%   Individual bar presented as a decrement followed by an increment
%
% Constructor:
%   obj = DecrementIncrementBar(stimTime, varargin)
%
% Properties (set as optional key/value inputs):
%   numBars
%   barID
%   orientation
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
        function obj = DecrementIncrementBar(calibration, varargin)
            obj = obj@sara.protocols.spatial.DecrementIncrement(calibration, varargin{:});
            
            ip = inputParser();
            ip.CaseSensitive = false;
            ip.KeepUnmatched = true;
            addParameter(ip, 'NumBars', 8, @isnumeric);
            addParameter(ip, 'BarID', 1, @isnumeric);
            addParameter(ip, 'Orientation', 'vertical', @(x) ismember(x, {'vertical', 'horizontal'}));
            parse(ip, varargin{:});

            obj.numBars = ip.Results.NumBars;
            obj.orientation = ip.Results.Orientation;
            obj.barID = ip.Results.BarID;

            % Derived parameters
            switch obj.orientation
                case 'vertical'
                    obj.barSize = floor(obj.canvasSize(1)/obj.numBars);
                case 'horizontal'
                    obj.barSize = floor(obj.canvasSize(2)/obj.numBars);
            end
        end

        function stim = generate(obj)
            stim = obj.initStimulus();   
            for i = 1:obj.totalPoints
                stim(:, (obj.barID-1) * obj.barSize+1 : obj.barID*obj.barSize, i) = trace(i);
            end
            
            if strcmp(obj.orientation, 'horizontal')
                stim = stim';
            end
        end

        function fName = getFileName(obj)
            fName = sprintf('%s_decrement_increment_%us_%ut_bar_%uof%u',...
                obj.orientation, obj.stepTime, obj.totalTime, obj.barID, obj.numBars);
        end
    end
end