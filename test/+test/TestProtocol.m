classdef TestProtocol < aod.builtin.protocols.StimulusProtocol
% TESTPROTOCOL
%
% Description:
%   A basic protocol designed to test functionality of both the core
%   Protocol class and the builtin StimulusProtocol class
% -------------------------------------------------------------------------

%#ok<*INUSD,*MANU>
    properties (SetAccess = protected)
        sampleRate = 25;
        stimRate = 50;
    end

    methods
        function obj = TestProtocol(varargin)
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
            fName = 'TestProtocol';
        end
    end
end 