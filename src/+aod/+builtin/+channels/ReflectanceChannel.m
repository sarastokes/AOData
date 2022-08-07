classdef ReflectanceChannel < aod.core.Channel

    methods 
        function obj = ReflectanceChannel(varargin)
            obj = obj@aod.core.Channel(varargin{:});
            obj.dataFolder = 'Ref';
        end
    end
end 