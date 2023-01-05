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
%   runAODataTestSuite

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

%#ok<*NASGU> 

    properties
        EXPT 
    end

    methods (TestClassSetup)
        function methodSetup(testCase)
            % Creates an experiment, writes to HDF5 and reads back in  
            fileName = fullfile(getpref('AOData', 'BasePackage'), ...
                'test', 'ToyExperiment.h5');            
            if ~exist(fileName, 'file')
                ToyExperiment(true);
            end
            testCase.EXPT = loadExperiment(fileName);
        end
    end

    methods (Test)
        function ReadOnly(testCase)
            import matlab.unittest.constraints.Throws

            % Ensure edits cannot be made when read only mode is true
            testCase.verifyThat( ...
                @() testCase.EXPT.setParam('NewParam', 'TestValue'),...
                Throws("verifyReadOnlyMode:ReadOnlyModeEnabled"));
            testCase.EXPT.setReadOnlyMode(false);
        end

        function HomeDirectory(testCase)
            % Changing the home directory is also a dataset change test
            oldDirectory = testCase.EXPT.homeDirectory;
            newDirectory = fileparts(testCase.EXPT.homeDirectory);
            testCase.EXPT.setHomeDirectory(newDirectory);
            out = h5read('ToyExperiment.h5', '/Experiment/homeDirectory');
            testCase.verifyEqual(out, newDirectory);

            % Reset the homeDirectory
            testCase.EXPT.setHomeDirectory(oldDirectory);
        end
        
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

        function ParamIO(testCase)
            import matlab.unittest.constraints.Throws

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
            % Add a property
            testCase.EXPT.addDataset('Test', eye(3));
            % Confirm new property is now a dynamic property
            testCase.verifyTrue(isprop(testCase.EXPT, 'Test'));
            % Confirm new property correctly wrote to HDF5
            out = h5read('ToyExperiment.h5', '/Experiment/Test');
            testCase.verifyEqual(eye(3), out);

            % TODO: Remove property
        end
    end
        
    methods (Test, TestTags=["Containers", "Persistor"])
        function EmptyContainer(testCase)
            testCase.verifyEmpty(aod.persistent.EntityContainer.empty());
        end

        function ContainerIndexing(testCase)
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

        function ContainerErrors(testCase)
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
        end
    end 
end