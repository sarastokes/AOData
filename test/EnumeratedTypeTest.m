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
    
    methods (Test, TestTags={'GroupLoadState'})
        function GroupLoadStateInit(testCase)
            import matlab.unittest.constraints.Throws
            import aod.app.GroupLoadState

            % Initialize by name
            out = GroupLoadState.init('none');
            testCase.verifyEqual(out, GroupLoadState.NONE);
            out = GroupLoadState.init('contents');
            testCase.verifyEqual(out, GroupLoadState.CONTENTS);
            out = GroupLoadState.init('attributes');
            testCase.verifyEqual(out, GroupLoadState.ATTRIBUTES);
            out = GroupLoadState.init('name');
            testCase.verifyEqual(out, GroupLoadState.NAME);

            % Return if GroupLoadState
            testCase.verifyEqual(GroupLoadState.init(GroupLoadState.NAME),...
                GroupLoadState.NAME);
            
            % Error on unrecognized input
            testCase.verifyThat(...
                @() GroupLoadState.init('badinput'),...
                Throws("init:UnrecognizedInput"));
        end

        function GroupLoadStateProps(testCase)
            import aod.app.GroupLoadState
            testCase.verifyTrue(GroupLoadState.CONTENTS.hasAttributes());
            testCase.verifyFalse(GroupLoadState.NAME.hasAttributes());

            testCase.verifyTrue(GroupLoadState.CONTENTS.hasContents());
            testCase.verifyFalse(GroupLoadState.NAME.hasContents());

            testCase.verifyTrue(GroupLoadState.ATTRIBUTES.hasName());
            testCase.verifyFalse(GroupLoadState.NONE.hasName());
        end
    end

    methods (Test, TestTags={'EntityTypes'})
        function EntityTypeInit(testCase)
            import aod.core.EntityTypes

            testCase.verifyEqual(EntityTypes.get(EntityTypes.EXPERIMENT),...
                EntityTypes.EXPERIMENT);
            out = EntityTypes.get('channel');
            testCase.verifyEqual(out, EntityTypes.CHANNEL);
            out = EntityTypes.get('device');
            testCase.verifyEqual(out, EntityTypes.DEVICE);
            out = EntityTypes.get('annotation');
            testCase.verifyEqual(out, EntityTypes.ANNOTATION);
            out = EntityTypes.get('stimulus');
            testCase.verifyEqual(out, EntityTypes.STIMULUS);
            out = EntityTypes.get('analysis');
            testCase.verifyEqual(out, EntityTypes.ANALYSIS);
        end

        function persistentParentContainer(testCase)
            out = aod.core.EntityTypes.EPOCH.persistentParentContainer();
            testCase.verifyEqual('EpochsContainer', out);
        end

        function collectAll(testCase)
            out = collectAll(aod.core.EntityTypes.EXPERIMENT, testCase.EXPT);
            testCase.verifyNumElements(out, 1);
            testCase.verifyEqual(out.UUID, testCase.EXPT.UUID);
        end

        function CoreClassName(testCase)
            className = aod.core.EntityTypes.EXPERIMENT.getCoreClassName();
            testCase.verifyEqual(className, 'aod.core.Experiment');
        end

        function UniqueExperiment(testCase)
            % Test where Experiment behaves differently from other entities

            expType = aod.core.EntityTypes.EXPERIMENT;
            testCase.verifyEmpty(expType.validParentTypes());
            testCase.verifyEmpty(expType.parentContainer());
            testCase.verifyEqual(expType.getGroupName(testCase.EXPT), 'Experiment');
        end
    end
end 