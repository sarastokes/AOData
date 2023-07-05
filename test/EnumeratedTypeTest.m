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
            import aod.infra.ErrorTypes

            out = aod.infra.ErrorTypes.init('error');
            testCase.verifyEqual(out, ErrorTypes.ERROR);
            out = aod.infra.ErrorTypes.init('warning');
            testCase.verifyEqual(out, ErrorTypes.WARNING);
            out = aod.infra.ErrorTypes.init('missing');
            testCase.verifyEqual(out, ErrorTypes.MISSING);
            out = aod.infra.ErrorTypes.init('none');
            testCase.verifyEqual(out, ErrorTypes.NONE);
            testCase.verifyError(...
                @() aod.infra.ErrorTypes.init('BadInput'),...
                "ErrorTypes:UnrecognizedInput");
        end

        function FilterTypesInit(testCase)
            import aod.api.FilterTypes

            out = FilterTypes.init('entity');
            testCase.verifyEqual(out, FilterTypes.ENTITY);
            out = FilterTypes.init('attribute');
            testCase.verifyEqual(out, FilterTypes.ATTRIBUTE);
            out = FilterTypes.init('dataset');
            testCase.verifyEqual(out, FilterTypes.DATASET);
            out = FilterTypes.init('link');
            testCase.verifyEqual(out, FilterTypes.LINK);
            out = FilterTypes.init('class');
            testCase.verifyEqual(out, FilterTypes.CLASS);
            out = FilterTypes.init('name');
            testCase.verifyEqual(out, FilterTypes.NAME);
            out = FilterTypes.init('parent');
            testCase.verifyEqual(out, FilterTypes.PARENT);
            out = FilterTypes.init('child');
            testCase.verifyEqual(out, FilterTypes.CHILD);
            out = FilterTypes.init('path');
            testCase.verifyEqual(out, FilterTypes.PATH);
            out = FilterTypes.init('uuid');
            testCase.verifyEqual(out, FilterTypes.UUID);
            
            testCase.verifyError(...
                @() FilterTypes.init('BadInput'),...
                "init:UnknownType");
        end

        function H5NodeTypesInit(testCase)
            import aod.app.util.H5NodeTypes

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
            import aod.app.util.AONodeTypes
            
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
            out = AONodeTypes.init('table');
            testCase.verifyEqual(out, AONodeTypes.TABLE);
            out = AONodeTypes.init('enum');
            testCase.verifyEqual(out, AONodeTypes.ENUM);
            out = AONodeTypes.init('logical');
            testCase.verifyEqual(out, AONodeTypes.LOGICAL);
            out = AONodeTypes.init('aod.common.FileReader');
            testCase.verifyEqual(out, AONodeTypes.FILEREADER);
            out = AONodeTypes.init('notes');
            testCase.verifyEqual(out, AONodeTypes.NOTES);
            out = AONodeTypes.init('attributemanager');
            testCase.verifyEqual(out, AONodeTypes.ATTRIBUTEMANAGER);
            out = AONodeTypes.init('description');
            testCase.verifyEqual(out, AONodeTypes.DESCRIPTION);
            out = AONodeTypes.init('homedirectory');
            testCase.verifyEqual(out, AONodeTypes.HOMEDIRECTORY);
            out = AONodeTypes.init('affine2d');
            testCase.verifyEqual(out, AONodeTypes.TRANSFORM);
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

            testCase.verifyEqual(out, AONodeTypes.init(out));

            testCase.verifyEmpty(out.processDataForDisplay());
        end
    end

    methods (Test, TestTags=["ReturnTypes"])
        function ReturnTypesInit(testCase)
            import aod.api.ReturnTypes

            out = ReturnTypes.init('entity');
            testCase.verifyEqual(out, ReturnTypes.ENTITY);
            out = ReturnTypes.init('path');
            testCase.verifyEqual(out, ReturnTypes.PATH);
            out = ReturnTypes.init('attribute');
            testCase.verifyEqual(out, ReturnTypes.ATTRIBUTE);
            out = ReturnTypes.init('dataset');
            testCase.verifyEqual(out, ReturnTypes.DATASET);
            testCase.verifyEqual(ReturnTypes.init(out), ReturnTypes.DATASET);

            testCase.verifyError(...
                @() ReturnTypes.init('Bad'), "init:InvalidInput");
        end
    end
    
    methods (Test, TestTags=["GroupNameType"])
        function GroupNameTypeInit(testCase)
            import aod.app.util.GroupNameType

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
            import aod.app.util.GroupLoadState

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
            import aod.app.util.GroupLoadState
            testCase.verifyTrue(GroupLoadState.CONTENTS.hasAttributes());
            testCase.verifyFalse(GroupLoadState.NAME.hasAttributes());

            testCase.verifyTrue(GroupLoadState.CONTENTS.hasContents());
            testCase.verifyFalse(GroupLoadState.NAME.hasContents());

            testCase.verifyTrue(GroupLoadState.ATTRIBUTES.hasName());
            testCase.verifyFalse(GroupLoadState.NONE.hasName());
        end
    end

    methods (Test, TestTags="SizeTypes")
    
        function SizeTypesInit(testCase)
            import aod.specification.SizeTypes

            testCase.verifyEqual(SizeTypes.get('scalar'), SizeTypes.SCALAR);
            testCase.verifyEqual(SizeTypes.get('row'), SizeTypes.ROW);
            testCase.verifyEqual(SizeTypes.get('column'), SizeTypes.COLUMN);
            testCase.verifyEqual(SizeTypes.get('matrix'), SizeTypes.MATRIX);
            testCase.verifyEqual(SizeTypes.get('ndarray'), SizeTypes.NDARRAY);
            testCase.verifyEqual(SizeTypes.get('undefined'), SizeTypes.UNDEFINED);

            testCase.verifyError(...
                @() SizeTypes.get('badinput'), "SizeTypes:InvalidInput");
        end

        function SizeTypesConversion(testCase)
            import aod.specification.SizeTypes

            testCase.verifyEqual(SizeTypes.SCALAR.getSizing(), "(1,1)");
            testCase.verifyEqual(SizeTypes.ROW.getSizing(), "(1,:)");
            testCase.verifyEqual(SizeTypes.COLUMN.getSizing(), "(:,1)");
            testCase.verifyEqual(SizeTypes.MATRIX.getSizing(), "(:,:)");
            testCase.verifyEmpty(SizeTypes.UNDEFINED.getSizing());
            testCase.verifyError(...
                @() SizeTypes.NDARRAY.getSizing(), "getSizing:NotEnoughInfo");
        end

        function SizeTypesValidator(testCase)
            import aod.specification.SizeTypes

            fcn = SizeTypes.SCALAR.getValidator();
            testCase.verifyTrue(fcn(1));
            testCase.verifyFalse(fcn(eye(3)));

            fcn = SizeTypes.ROW.getValidator();
            testCase.verifyTrue(fcn([1 1 1]));
            testCase.verifyFalse(fcn([1 1 1]'));

            fcn = SizeTypes.COLUMN.getValidator();
            testCase.verifyTrue(fcn([1 1 1]'));
            testCase.verifyFalse(fcn([1 1 1]));

            fcn = SizeTypes.MATRIX.getValidator();
            testCase.verifyTrue(fcn(eye(3)));
            testCase.verifyFalse(fcn(zeros(3,3,3)));
            
            fcn = SizeTypes.NDARRAY.getValidator(zeros(3,3,3));
            testCase.verifyFalse(fcn(eye(3)));
            testCase.verifyTrue(fcn(zeros(3,3,3)));

            fcn = SizeTypes.UNDEFINED.getValidator();
            testCase.verifyEmpty(fcn);

        end
    end

    methods (Test, TestTags={'EntityTypes'})
        function EntityTypeInit(testCase)
            import aod.common.EntityTypes

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
            import aod.common.EntityTypes

            testCase.verifyEmpty(EntityTypes.STIMULUS.empty());
            testCase.verifyEmpty(EntityTypes.CHANNEL.empty());
            testCase.verifyClass(EntityTypes.DEVICE.empty(), 'aod.core.Device');
            testCase.verifyClass(EntityTypes.EXPERIMENT.empty(), 'double');
        end

        function Text(testCase)
            import aod.common.EntityTypes

            testCase.verifyEqual(char(EntityTypes.EXPERIMENTDATASET), 'ExperimentDataset');
            testCase.verifyEqual(string(EntityTypes.STIMULUS), "Stimulus");
        end

        function HdfPaths(testCase)
            import aod.common.EntityTypes

            testCase.verifyError(...
                @() EntityTypes.CHANNEL.getPath(123), "getPath:InvalidEntity");
            testCase.verifyEqual(EntityTypes.EXPERIMENT.getPath(), '/Experiment');
        end

        function persistentParentContainer(testCase)
            out = aod.common.EntityTypes.EPOCH.persistentParentContainer();
            testCase.verifyEqual('EpochsContainer', out);
        end

        function childContainers(testCase)
            % TODO Check for use
            out = aod.common.EntityTypes.SYSTEM.childContainers(true);
            testCase.verifyEqual("ChannelsContainer", out);
        end

        function collectAll(testCase)
            out = collectAll(aod.common.EntityTypes.EXPERIMENT, testCase.EXPT);
            testCase.verifyNumElements(out, 1);
            testCase.verifyEqual(out.UUID, testCase.EXPT.UUID);
        end

        function CoreClassName(testCase)
            className = aod.common.EntityTypes.EXPERIMENT.getCoreClassName();
            testCase.verifyEqual(className, 'aod.core.Experiment');
        end

        function UniqueExperiment(testCase)
            % Test where Experiment behaves differently from other entities

            expType = aod.common.EntityTypes.EXPERIMENT;
            testCase.verifyEmpty(expType.validParentTypes());
            testCase.verifyEmpty(expType.parentContainer());
        end
    end
end 