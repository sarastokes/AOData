classdef EnumeratedTypeTest < matlab.unittest.TestCase 
% Test AOData's enumerated types
%
% Description:
%   Tests functionality of enumerated types not covered in other tests
%
% Parent:
%   matlab.unittest.TestCase
%
% Use:
%   result = runtests('EnumeratedTypeTest')
%
% See also:
%   runAODataTestSuite

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

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

            out = H5NodeTypes.get('none');
            testCase.verifyEqual(out, H5NodeTypes.NONE);
            out = H5NodeTypes.get('group');
            testCase.verifyEqual(out, H5NodeTypes.GROUP);
            out = H5NodeTypes.get('dataset');
            testCase.verifyEqual(out, H5NodeTypes.DATASET);
            out = H5NodeTypes.get('link');
            testCase.verifyEqual(out, H5NodeTypes.LINK);

            testCase.verifyEqual(H5NodeTypes.get(H5NodeTypes.LINK),... 
                H5NodeTypes.LINK);
            
            testCase.verifyError(...
                @()H5NodeTypes.get('bad'), 'get:UnknownNodeType');
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
    
    methods (Test, TestTags=["GroupNameType"])
        function GroupNameTypeInit(testCase)
            import aod.app.GroupNameType

            out = GroupNameType.get('UserDefined');
            testCase.verifyEqual(out, GroupNameType.UserDefined);
            out = GroupNameType.get('UserDefinedWithDefault');
            testCase.verifyEqual(out, GroupNameType.UserDefinedWithDefault);
            out = GroupNameType.get('HardCoded');
            testCase.verifyEqual(out, GroupNameType.HardCoded);
            out = GroupNameType.get('DefinedInternally');
            testCase.verifyEqual(out, GroupNameType.DefinedInternally);
            out = GroupNameType.get('ClassName');
            testCase.verifyEqual(out, GroupNameType.ClassName);
            testCase.verifyEqual(GroupNameType.get(out), GroupNameType.ClassName);
            testCase.verifyError(...
                @() GroupNameType.get('BadName'), "get:UnknownType");
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

            testCase.verifyError(@() EntityTypes.get('double'), 'get:UnknownEntity');
        end

        function Empty(testCase)
            import aod.core.EntityTypes

            testCase.verifyEmpty(EntityTypes.STIMULUS.empty());
            testCase.verifyEmpty(EntityTypes.CHANNEL.empty());
            testCase.verifyClass(EntityTypes.DEVICE.empty(), 'aod.core.Device');
            testCase.verifyClass(EntityTypes.EXPERIMENT.empty(), 'double');
        end

        function HdfPaths(testCase)
            import aod.core.EntityTypes

            testCase.verifyError(...
                @() EntityTypes.CHANNEL.getPath(123), "getPath:InvalidEntity");
            testCase.verifyEqual(EntityTypes.EXPERIMENT.getPath(), '/Experiment');
        end

        function persistentParentContainer(testCase)
            out = aod.core.EntityTypes.EPOCH.persistentParentContainer();
            testCase.verifyEqual('EpochsContainer', out);
        end

        function childContainers(testCase)
            % TODO Check for use
            out = aod.core.EntityTypes.SYSTEM.childContainers(true);
            testCase.verifyEqual("ChannelsContainer", out);
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
        end
    end
end 