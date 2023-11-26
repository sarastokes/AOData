classdef TestAnalysis < aod.core.Analysis

    properties
        Source
        Data        = 2
        Prop   (1,1)    string = "test"
    end

    methods
        function obj = TestAnalysis()
            obj = obj@aod.core.Analysis('Test',...
                "Date", '20220904');

            obj.Data = randn([4, 5]);
        end

        function setSource(obj, source)
            assert(isSubclass(source, {'aod.core.Source', 'aod.persistent.Source'}),...
                'Input must be a Source subclass');
            obj.Source = source;
        end
    end

    methods (Static)
        function UUID = specifyClassUUID()
			 UUID = "c8079cbf-a71b-483b-b4ae-9edede056908";
		end
    end
end