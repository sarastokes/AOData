classdef PersistorTest < matlab.unittest.TestCase 
% Test interactions between persistent interface and HDF5 files
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

%#ok<*NASGU,*MANU>

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

            % Copy experiment for EntityRename
            h5tools.files.copyFile(fileName, "EntityRenameTest.h5");

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

    methods (Test, TestTags="Modification")
        function EntityRename(testCase)
            pEXPT = loadExperiment("EntityRenameTest.h5");
            pEXPT.setReadOnlyMode(false);
            
            % Change the group name of a source
            pEXPT.Sources(1).Sources(1).setName("OD")
            links = aod.h5.collectExperimentLinks(pEXPT.hdfName);
            % Confirm softlink updates
            testCase.verifyEmpty(find(contains(links.Location, "/OS/")));
            testCase.verifyEmpty(find(contains(links.Target, "/OS/")));
            % Confirm updates to hdf paths
            testCase.verifyTrue(contains(...
                pEXPT.Sources(1).Sources(1).hdfPath, "/OD"));
            testCase.verifyTrue(contains(...
                pEXPT.Sources(1).Sources(1).Sources(1).hdfPath, "/OD"));
            % Confirm persistent interface registers softlink updates
            epochSource = pEXPT.Epochs(1).Source;
            testCase.verifyTrue(contains(epochSource.hdfPath, "/OD/"));
        end

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

        function DatasetAddition(testCase)
            
            testCase.EXPT.setReadOnlyMode(false);

            % Add a property
            testCase.EXPT.addDataset('Test', eye(3));
            % Confirm new property is now a dynamic property
            testCase.verifyTrue(isprop(testCase.EXPT, 'Test'));
            % Confirm new property correctly wrote to HDF5
            out = h5read('ToyExperiment.h5', '/Experiment/Test');
            testCase.verifyEqual(eye(3), out);
        end

        function RemoveDatasetWarnings(testCase)
            
            testCase.EXPT.setReadOnlyMode(false);

            testCase.verifyError(...
                @() testCase.EXPT.removeDataset("UUID"),...
                "removeDataset:EntityProperty");

            testCase.verifyError(...
                @() testCase.EXPT.removeDataset("BadProp"),...
                "removeDataset:PropertyDoesNotExist");
        end

        function Links(testCase)
            testCase.EXPT.setReadOnlyMode(false);

            % Edit a link
            newTargetPath = testCase.EXPT.Sources(1).hdfPath;
            testCase.EXPT.Epochs(1).addDataset('Source', testCase.EXPT.Sources(1));
            links = aod.h5.collectExperimentLinks(testCase.EXPT);
            testCase.verifyTrue(ismember(newTargetPath, links.Target));
            
            % Restore the original link
            oldTarget = testCase.EXPT.Sources(1).Sources(1).Sources(1);
            testCase.EXPT.Epochs(1).addDataset('Source', oldTarget);
            links = aod.h5.collectExperimentLinks(testCase.EXPT);
            testCase.verifyTrue(strcmp(oldTarget.hdfPath, links.Target(1)));
     
            % Test for errors with unwritten links
            testCase.verifyError(...
                @() testCase.EXPT.addDataset('BadLink', aod.core.Analysis('Test')),...
                "addDataset:UnpersistedLink");
        end

        function addEntity(testCase)
            % Analysis
            analysis = aod.core.Analysis("TestAnalysis");
            testCase.SMALL_EXPT.add(analysis);
            testCase.verifyNumElements(testCase.SMALL_EXPT.Analyses, 1);

            % Source
            source = aod.core.Source("SourceA");
            testCase.SMALL_EXPT.add(source);
            testCase.verifyNumElements(testCase.SMALL_EXPT.Sources(1), 1);
            testCase.SMALL_EXPT.Sources(1).add(aod.core.Source("SourceB"));
            % Check with output of persistent get function
            matches = testCase.SMALL_EXPT.query({'Entity', 'Source'});
            testCase.verifyNumElements(matches, 2);

            % System
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

        function AddEpoch(testCase)
            % Add system
            testCase.SMALL_EXPT.add(aod.core.System("EpochSystem"));
            % Add epoch
            testCase.SMALL_EXPT.add(aod.core.Epoch(1));
        end
    end
end