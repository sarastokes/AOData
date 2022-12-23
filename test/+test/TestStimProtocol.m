classdef TestStimProtocol < aod.builtin.protocols.StimulusProtocol
% A subclass of Stimulus Protocol for testing purposes
%
% Description:
%   A basic protocol designed to test functionality of both the core
%   Protocol class and the builtin StimulusProtocol class
%
% Parent:
%   aod.builtin.protocols.StimulusProtocol
%
% Constructor:
%   obj = test.TestStimProtocol(calibration, varargin)

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

%#ok<*INUSD,*MANU>
    properties (SetAccess = protected)
        sampleRate = 25;
        stimRate = 50;
    end

    methods
        function obj = TestStimProtocol(calibration, varargin)
            obj = obj@aod.builtin.protocols.StimulusProtocol([], varargin{:});
        end

        function stim = generate(obj)
            stim = obj.amplitude + obj.baseIntensity + zeros(1, obj.sec2pts(obj.stimTime));
            stim = obj.appendPreTime(stim);
            stim = obj.appendTailTime(stim);
        end

        function writeStim(obj, fName) 
            % Do nothing
        end

        function fName = getFileName(obj) 
            fName = 'TestStimProtocol';
        end
    end
end 