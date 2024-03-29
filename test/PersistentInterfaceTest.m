classdef PersistentInterfaceTest < matlab.unittest.TestCase
% Test access through the persistent interface
%
% Parent:
%    matlab.unittest.TestCase
%
% Use:
%   result = runtests('PersistentInterfaceTest')
%
% See also:
%   runAODataTestSuite, ToyExperiment, aod.util.test.makeSmallExperiment

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties
        FILE
        SMALL_FILE
        EXPT
        SMALL_EXPT
    end

    methods (TestClassSetup)
        function methodSetup(testCase)
            % Create and write a full experiment (prior versions may have
            % unexpected changes from prior tests)
            testCase.FILE = 'ToyExperiment.h5';
            [~, testCase.EXPT] = ToyExperiment(true);

            testCase.SMALL_FILE = 'PersistentInterface.h5';
            testCase.SMALL_EXPT = aotest.util.makeSmallExperiment(...
                true, testCase.SMALL_FILE);
        end
    end

    methods (Test, TestTags=["Entity"])
        function AttrRead(testCase)
            testCase.verifyTrue(...
                testCase.EXPT.hasAttr('Administrator'));
            testCase.verifyEqual(...
                testCase.EXPT.getAttr('Administrator'), "Sara Patterson");
            testCase.verifyFalse(...
                testCase.EXPT.hasAttr('BadAttr'));
        end

        function FileRead(testCase)
            testCase.verifyTrue(...
                testCase.EXPT.Epochs(1).hasFile('PresyncFile'));
            testCase.verifyFalse(...
                testCase.EXPT.hasFile('PreSyncFile'));
        end

        function GetByPath(testCase)
            epochPath = '/Experiment/Epochs/0001';
            h = aod.h5.getByPath(testCase.EXPT, epochPath);
            testCase.verifyEqual(h.UUID, testCase.EXPT.Epochs(1).UUID);

            testCase.verifyWarning(@()aod.h5.getByPath(testCase.EXPT, 'badpath'), ...
                'getByPath:InvalidHdfPath');
        end

        function GetParent(testCase)
            h = getParent(testCase.EXPT.Epochs(1).Responses(1), 'experiment');
            testCase.verifyEqual(testCase.EXPT.UUID, h.UUID);
        end

        function CustomDisplay(testCase)
            disp(testCase.EXPT)
            disp(testCase.EXPT.Epochs)
        end
    end

    methods (Test, TestTags="Experiment")
        function EpochAccess(testCase)
            epochs = testCase.EXPT.id2epoch(1:2);
            testCase.verifyClass(epochs, 'aod.persistent.Epoch');
        end

        function EntityAccess(testCase)
            testCase.verifyTrue(testCase.EXPT.has("Source"));
            testCase.verifyTrue(testCase.EXPT.has("Epoch", {"Dataset", "ID", 1}));
            testCase.verifyFalse(testCase.EXPT.has("Epoch", {"Dataset", "ID", 3}));
        end
    end


    methods (Test, TestTags="Containers")
        function EntityContainerContents(testCase)
            EC1 = testCase.EXPT.EpochsContainer;
            ECcontents = EC1.contents;
            testCase.verifyEqual(numel(ECcontents), testCase.EXPT.numEpochs);
            testCase.verifyClass(ECcontents, 'aod.persistent.Epoch');
        end

        function EmptyContainer(testCase)
            testCase.verifyEmpty(aod.persistent.EntityContainer.empty());

            EC2 = testCase.SMALL_EXPT.ExperimentDatasetsContainer;
            testCase.verifyEmpty(EC2(1));
        end

        function EntityContainerIndexing(testCase)
            testCase.verifyNumElements(testCase.EXPT.Analyses(0),...
                numel(testCase.EXPT.Analyses));
            testCase.verifyNumElements(testCase.EXPT.Epochs(1), 1);
            testCase.verifyNumElements(testCase.EXPT.Calibrations(0),...
                numel(testCase.EXPT.Calibrations));
            testCase.verifyNumElements(testCase.EXPT.Annotations(0),...
                numel(testCase.EXPT.Annotations));
            testCase.verifyNumElements(testCase.EXPT.Systems(1), 1);
            testCase.verifyNumElements(testCase.EXPT.Sources(1), 1);
        end

        function EntityContainerErrors(testCase)
            try
                testCase.EXPT.EpochsContainer(1) = [];
            catch ME
                disp(ME.identifier)
                testCase.verifyTrue(strcmp(ME.identifier,...
                    "EntityContainer:DeleteNotSupported"));
            end

            try
                testCase.EXPT.EpochsContainer(1) = 1;
            catch ME
                testCase.verifyTrue(strcmp(ME.identifier,...
                    "EntityContainer:AssignNotSupported"));
            end

            EC1 = testCase.EXPT.EpochsContainer;
            testCase.verifyError( ...
                @() [EC1, EC1], "EntityContainer:ConcatenationNotSupported");
        end
    end
end