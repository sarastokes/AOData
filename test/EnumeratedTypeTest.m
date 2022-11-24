classdef EnumeratedTypeTest < matlab.unittest.TestCase 

    properties
        EXPT
    end

    methods (TestClassSetup)
        function methodSetup(testCase)
            testCase.EXPT = ToyExperiment(false);
        end
    end

    methods (Test, TestTags = {'Initialization'})
        function ErrorTypesInit(testCase)
            out = aod.util.ErrorTypes.init('error');
            out = aod.util.ErrorTypes.init('warning');
            out = aod.util.ErrorTypes.init('missing');
            out = aod.util.ErrorTypes.init('none');
        end
    end

    methods (Test, TestTags={'EntityTypes'})
        function testExperimentType(testCase)
            expType = aod.core.EntityTypes.init('experiment');
            testCase.verifyThat(isempty(expType.validParentTypes));
        end
    end
end 