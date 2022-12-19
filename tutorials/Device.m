classdef Device < aod.core.Entity 

    methods
        function obj = Device(name, varargin)
            obj = obj@aod.core.Entity(name, varargin{:});
            
            ip = inputParser();
        end

        function checkDefaultParameters(varargin)
            ip = aod.util.InputParser();
        end
    end
end