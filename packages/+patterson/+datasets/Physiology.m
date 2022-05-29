classdef Physiology < patterson.core.Dataset

    properties (SetAccess = protected)
        allStimuli 
    end

    methods
        function obj = Physiology(homeDirectory, expDate)
            obj = obj@patterson.core.Dataset(homeDirectory, expDate);
        end
    end
end