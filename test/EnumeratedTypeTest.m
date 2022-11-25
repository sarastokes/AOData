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
            import matlab.unittest.constraints.Throws
            import aod.util.ErrorTypes

            out = aod.util.ErrorTypes.init('error');
            testCase.verifyEqual(out, ErrorTypes.ERROR);
            out = aod.util.ErrorTypes.init('warning');
            testCase.verifyEqual(out, ErrorTypes.WARNING);
            out = aod.util.ErrorTypes.init('missing');
            testCase.verifyEqual(out, ErrorTypes.MISSING);
            out = aod.util.ErrorTypes.init('none');
            testCase.verifyEqual(out, ErrorTypes.NONE);
            testCase.verifyThat(...
                @() aod.util.ErrorTypes.init('BadInput'),...
                Throws("ErrorTypes:UnrecognizedInput"));
        end
    end
end 