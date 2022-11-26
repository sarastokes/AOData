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

        function FilterTypesInit(testCase)
            import aod.api.FilterTypes

            out = FilterTypes.init('entity');
            testCase.verifyEqual(out, FilterTypes.ENTITY);
            out = FilterTypes.init('parameter');
            testCase.verifyEqual(out, FilterTypes.PARAMETER);
            out = FilterTypes.init('dataset');
            testCase.verifyEqual(out, FilterTypes.DATASET);
            out = FilterTypes.init('link');
            testCase.verifyEqual(out, FilterTypes.LINK);
            out = FilterTypes.init('class');
            testCase.verifyEqual(out, FilterTypes.CLASS);
            out = FilterTypes.init('name');
            testCase.verifyEqual(out, FilterTypes.NAME);
        end

        function H5NodeTypesInit(testCase)
            import aod.app.H5NodeTypes

            out = H5NodeTypes.init('none');
            testCase.verifyEqual(out, H5NodeTypes.NONE);
            out = H5NodeTypes.init('group');
            testCase.verifyEqual(out, H5NodeTypes.GROUP);
            out = H5NodeTypes.init('dataset');
            testCase.verifyEqual(out, H5NodeTypes.DATASET);
            out = H5NodeTypes.init('link');
            testCase.verifyEqual(out, H5NodeTypes.LINK);
        end

        function AODataNodesInit(testCase)
            import aod.app.AONodeTypes
            
            out = AONodeTypes.init('Link');
            testCase.verifyEqual(out, AONodeTypes.LINK);
            out = AONodeTypes.init('entity');
            testCase.verifyEqual(out, AONodeTypes.ENTITY);
            out = AONodeTypes.init('container');
            testCase.verifyEqual(out, AONodeTypes.CONTAINER);
            out = AONodeTypes.init('string');
            testCase.verifyEqual(out, AONodeTypes.TEXT);
            out = AONodeTypes.init('char');
            testCase.verifyEqual(out, AONodeTypes.TEXT);
            out = AONodeTypes.init('timetable');
            testCase.verifyEqual(out, AONodeTypes.TIMETABLE);
            out = AONodeTypes.init('datetime');
            testCase.verifyEqual(out, AONodeTypes.DATETIME);
            out = AONodeTypes.init('containers.map');
            testCase.verifyEqual(out, AONodeTypes.MAP);
            out = AONodeTypes.init('files');
            testCase.verifyEqual(out, AONodeTypes.FILES);
            out = AONodeTypes.init('randominput');
            testCase.verifyEqual(out, AONodeTypes.UNKNOWN);
        end
    end
end 