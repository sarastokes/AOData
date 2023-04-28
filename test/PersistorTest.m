classdef PersistorTest < matlab.unittest.TestCase 
% PERSISTORTEST
%
% Description:
%   Tests modification of HDF5 files from persistent interface
%
% Parent:
%    matlab.unittest.TestCase
%
% Use:
%   result = runtests('PersistorTest.m')
%
% See also:
%   runAODataTestSuite, ToyExperiment, aod.util.test.makeSmallExperiment

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

%#ok<*NASGU> 

    properties
        EXPT 
        SMALL_EXPT
    end

    methods (TestClassSetup)
        function methodSetup(testCase)
            % Creates an experiment, writes to HDF5 and reads back in  
            fileName = fullfile(getpref('AOData', 'BasePackage'), ...
                'test', 'ToyExperiment.h5');            
            if ~exist(fileName, 'file')
                ToyExperiment(true, true);
            end
            testCase.EXPT = loadExperiment(fileName);

            % Make a smaller experiment for testing empty entities
            testCase.SMALL_EXPT = test.util.makeSmallExperiment(...
                true, 'ShellExperiment.h5');
        end
    end

    methods (Test, TestTags=["MixedEntitySet", "Persistent"])
        function MixedEntitySet(testCase)
            ME = aod.persistent.MixedEntitySet();
            disp(ME);
            testCase.verifyEmpty(ME);

            ME.add(testCase.EXPT.Epochs);
            testCase.verifyEqual(ME.whichEntities(),aod.core.EntityTypes.EPOCH);
            testCase.verifyEqual(numel(ME.Epochs), testCase.EXPT.numEpochs);
            disp(ME);

            ME.add(testCase.EXPT.Sources);
            testCase.verifyNumElements(ME.whichEntities, 2);
            testCase.verifyTrue(...
                ismember(aod.core.EntityTypes.EPOCH, ME.whichEntities()));
            testCase.verifyTrue(...
                ismember(aod.core.EntityTypes.SOURCE, ME.whichEntities()));
        end

        function MixedEntitySetErrors(testCase)
            ME = aod.persistent.MixedEntitySet();

            testCase.verifyError(@() ME.add(1), "add:InvalidInput");
        end
    end

    methods (Test, TestTags = ["ReadOnly", "Persistent"])
        function ReadOnlyEnforcement(testCase)
            import matlab.unittest.constraints.Throws

            testCase.EXPT.setReadOnlyMode(true);

            % Ensure edits cannot be made when read only mode is true
            testCase.verifyThat( ...
                @() testCase.EXPT.setParam('NewParam', 'TestValue'),...
                Throws("verifyReadOnlyMode:ReadOnlyModeEnabled"));
            testCase.EXPT.setReadOnlyMode(false);
        end
    end

    methods (Test, TestTags=["HomeDirectory", "Persistent"])
        function HomeDirectory(testCase)
            testCase.verifyEqual(...
                testCase.EXPT.getHomeDirectory(),...
                testCase.EXPT.Epochs(1).getHomeDirectory());
        end

        function HomeDirectoryChanges(testCase)
            testCase.EXPT.setReadOnlyMode(false);

            % Changing the home directory is also a dataset change test
            oldDirectory = testCase.EXPT.homeDirectory;
            newDirectory = fileparts(testCase.EXPT.homeDirectory);
            testCase.EXPT.setHomeDirectory(newDirectory);
            out = h5read('ToyExperiment.h5', '/Experiment/homeDirectory');
            testCase.verifyEqual(out, newDirectory);

            % Reset the homeDirectory
            testCase.EXPT.setHomeDirectory(oldDirectory);
        end
    end

    methods (Test)
        function ParamRead(testCase)
            testCase.verifyTrue(...
                testCase.EXPT.hasParam('Administrator'));
            testCase.verifyEqual(...
                testCase.EXPT.getParam('Administrator'), "Sara Patterson");
            testCase.verifyFalse(...
                testCase.EXPT.hasParam('BadParam'));
        end

        function FileRead(testCase)
            testCase.verifyTrue(...
                testCase.EXPT.Epochs(1).hasFile('PresyncFile'));
            testCase.verifyFalse(...
                testCase.EXPT.hasFile('PreSyncFile'));
        end

        function CustomDisplay(testCase)
            disp(testCase.EXPT)
            disp(testCase.EXPT.Epochs)
        end

        function Ancestor(testCase)
            h = ancestor(testCase.EXPT.Epochs(1).Responses(1), 'experiment');
            testCase.verifyEqual(testCase.EXPT.UUID, h.UUID);
        end

        function GetByPath(testCase)
            epochPath = '/Experiment/Epochs/0001';
            h = testCase.EXPT.getByPath(epochPath);
            testCase.verifyEqual(h.UUID, testCase.EXPT.Epochs(1).UUID);

            testCase.verifyWarning(@()testCase.EXPT.getByPath('badpath'),...
                'getByPath:InvalidHdfPath');
        end
    end

    methods (Test, TestTags="Modification")
        function ParamIO(testCase)
            import matlab.unittest.constraints.Throws
            
            testCase.EXPT.setReadOnlyMode(false);
            
            % Ensure system attributes aren't editable
            testCase.verifyThat( ...
                @() testCase.EXPT.setParam('Class', 'TestValue'),...
                Throws("mustNotBeSystemAttribute:InvalidInput"));
            
            % Add a new parameter, ensure other attributes are editable
            testCase.EXPT.setParam('TestParam', 0);
            info = h5info('ToyExperiment.h5', '/Experiment');
            attributeNames = string({info.Attributes.Name});
            testCase.verifyTrue(ismember("TestParam", attributeNames));

            % Remove the new parameter
            testCase.EXPT.removeParam('TestParam');
            info = h5info('ToyExperiment.h5', '/Experiment');
            attributeNames = string({info.Attributes.Name});
            testCase.verifyFalse(ismember("TestParam", attributeNames));
        end

        function FileIO(testCase)

            testCase.EXPT.setReadOnlyMode(false);

            % Change a file
            testCase.EXPT.Epochs(1).setFile('PostSyncFile', 'test.txt');
            out = h5readatt('ToyExperiment.h5', '/Experiment/Epochs/0001/files', 'PostSyncFile');
            testCase.verifyEqual(out, 'test.txt');
            testCase.verifyEqual(testCase.EXPT.Epochs(1).getFile('PostSyncFile'), 'test.txt');

            % Remove a file
            testCase.EXPT.Epochs(1).removeFile('PostSyncFile');
            info = h5info('ToyExperiment.h5', '/Experiment/Epochs/0001/files');
            attributeNames = string({info.Attributes.Name});
            testCase.verifyFalse(ismember("PostSyncFile", attributeNames));
            testCase.verifyFalse(testCase.EXPT.Epochs(1).hasFile('PostSyncFile'));

            % Remove a file that does not exist
            testCase.verifyWarning(@()testCase.EXPT.Epochs(1).removeFile('BadFileName'),...
                "removeFile:FileNotFound");

            % Add a file
            testCase.EXPT.Epochs(1).setFile('PostSyncFile', '\PostSyncFile.txt');
            testCase.verifyTrue(testCase.EXPT.Epochs(1).hasFile('PostSyncFile'));
            info = h5info('ToyExperiment.h5', '/Experiment/Epochs/0001/files');
            attributeNames = string({info.Attributes.Name});
            testCase.verifyTrue(ismember("PostSyncFile", attributeNames));
            out = h5readatt('ToyExperiment.h5', '/Experiment/Epochs/0001/files', 'PostSyncFile');
            testCase.verifyEqual(out, '\PostSyncFile.txt');
        end

        function PropertyIO(testCase)
            
            testCase.EXPT.setReadOnlyMode(false);

            % Add a property
            testCase.EXPT.addDataset('Test', eye(3));
            % Confirm new property is now a dynamic property
            testCase.verifyTrue(isprop(testCase.EXPT, 'Test'));
            % Confirm new property correctly wrote to HDF5
            out = h5read('ToyExperiment.h5', '/Experiment/Test');
            testCase.verifyEqual(eye(3), out);

            % Test for errors with unwritten links
            testCase.verifyError(...
                @() testCase.EXPT.addDataset('BadLink', aod.core.Analysis('Test')),...
                "addDataset:UnpersistedLink");

            % TODO: Remove property
        end

        function addEntity(testCase)
            analysis = aod.core.Analysis("TestAnalysis");
            testCase.SMALL_EXPT.add(analysis);
            testCase.verifyNumElements(testCase.SMALL_EXPT.Analyses, 1);

            system = aod.core.System("TestSystem");
            testCase.SMALL_EXPT.add(system);
            testCase.verifyNumElements(testCase.SMALL_EXPT.Systems, 1);

            channel = aod.core.Channel("TestChannel",... 
                "Parent", testCase.SMALL_EXPT.Systems(1));
            % Confirm interoperability of core/persistent
            testCase.verifyClass(channel.ancestor('experiment'),... 
                "aod.persistent.Experiment");
            % Add the new channel
            testCase.SMALL_EXPT.Systems(1).add(channel);
            testCase.verifyNumElements(testCase.SMALL_EXPT.Systems(1).Channels, 1);
            % Swap interfaces
            channel0 = aod.util.swapInterfaces(channel); 
            testCase.verifyEqual(channel0.UUID, channel.UUID);

            % Add a device
            device = aod.core.Device("TestDevice", "Parent", channel);     
            channel0.add(device);
            testCase.verifyNumElements(channel0.Devices, 1);      
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