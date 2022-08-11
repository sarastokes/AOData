classdef BackgroundEpoch < sara.Epoch

    properties (Dependent)
        meanValue
        stdValue
    end
        
    properties (Hidden, Access = private)
        statistics
    end

    methods
        function obj = BackgroundEpoch(ID, parent)
            obj@sara.Epoch(ID, parent, sara.EpochTypes.Background);
        end

        function value = get.meanValue(obj)
            if isempty(obj.statistics)
                obj.getStatistics();
            end
            value = obj.statistics('Mean');
        end
        
        function value = get.stdValue(obj)
            if isempty(obj.statistics)
                obj.getStatistics();
            end
            value = obj.statistics('Std');
        end
    end

    methods
        function R = getMean(obj)
            R = obj.getResponse('aod.builtin.responses.Mean');
        end
    end

    methods (Access = private)

        function getStatistics(obj)
            imStack = obj.getStack();
            obj.statistics = containers.Map();
            obj.statistics('Mean') = mean(imStack(:), 'omitnan');
            obj.statistics('Std') = std(imStack(:), 'omitnan');
        end
    end
end