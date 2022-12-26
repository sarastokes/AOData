classdef TemporalAverage < aod.builtin.responses.TemporalAverage


    methods
        function obj = TemporalAverage(parent, varargin)
            obj@aod.builtin.responses.TemporalAverage('Mean', 'Parent', parent);
            obj.extractResponse(varargin{:});
        end

        function imStack = loadData(obj)
            imStack = obj.Parent.getStack();
        end
    end
end 