classdef TestAnalysis < aod.core.Analysis 

    properties
        Source
        Data 
    end

    methods
        function obj = TestAnalysis()
            obj = obj@aod.core.Analysis('Test', '20220904');

            obj.Data = randn([4, 5]);
        end

        function setSource(obj, source)
            assert(isSubclass(source, {'aod.core.Source', 'aod.core.persistent.Source'}),...
                'Input must be a Source subclass');
            obj.Source = source;
        end
    end
end