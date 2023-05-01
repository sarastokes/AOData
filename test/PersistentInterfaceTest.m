classdef PersistentInterfaceTest < matlab.unittest.TestCase 

    properties
        FILE
        SMALL_FILE
        EXPT
        SMALL_EXPT 
    end

    methods (TestClassSetup)
        function methodSetup(testCase)
            testCase.SMALL_FILE = 'PersistentInterface.h5';
            testCase.FILE = 'ToyExperiment.h5';
            if exist(testCase.FILE, 'file')
                testCase.EXPT = loadExperiment(testCase.FILE);
            else
                [~, testCase.EXPT] = ToyExperiment(true);
            end
            testCase.SMALL_EXPT = test.util.makeSmallExperiment(...
                true, testCase.FILE);
        end
    end

    methods (Test, TestTags=["Experiment"])
        function HomeDirectoryChanges(testCase)
            testCase.EXPT.setReadOnlyMode(false);

            % Changing the home directory is also a dataset change test
            oldDirectory = testCase.EXPT.homeDirectory;
            newDirectory = fileparts(testCase.EXPT.homeDirectory);
            testCase.EXPT.setHomeDirectory(newDirectory);
            out = h5read(testCase.EXPT.hdfName, '/Experiment/homeDirectory');
            testCase.verifyEqual(out, newDirectory);

            % Reset the homeDirectory
            testCase.EXPT.setHomeDirectory(oldDirectory);
        end
    end

    
    methods (Test, TestTags=["Containers", "Persistor"])
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