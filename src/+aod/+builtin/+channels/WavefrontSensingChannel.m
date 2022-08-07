classdef WavefrontSensingChannel < aod.core.Channel

    methods 
        function obj = WavefrontSensingChannel(varargin)
            obj = obj@aod.core.Channel(varargin{:});
        end
    end
end