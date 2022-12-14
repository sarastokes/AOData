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
        function testReadOnly(testCase)
            import matlab.unittest.constraints.Throws

            % Ensure edits cannot be made when read only mode is true
            testCase.verifyThat( ...
                @() testCase.EXPT.setParam('NewParam', 'TestValue'),...
                Throws("Entity:ReadOnlyModeEnabled"));
            testCase.EXPT.setReadOnlyMode(false);
        end

        function testHomeDirectory(testCase)
            % Changing the home directory is also a dataset change test
            oldDirectory = testCase.EXPT.homeDirectory;
            newDirectory = fileparts(testCase.EXPT.homeDirectory);
            testCase.EXPT.setHomeDirectory(newDirectory);
            out = h5read('ToyExperiment.h5', '/Experiment/homeDirectory');
            testCase.verifyEqual(out, newDirectory);

            % Reset the homeDirectory
            testCase.EXPT.setHomeDirectory(oldDirectory);
        end
        
        function testParamRead(testCase)
            testCase.verifyTrue(...
                testCase.EXPT.hasParam('Administrator'));
            testCase.verifyEqual(...
                testCase.EXPT.getParam('Administrator'), 'Sara Patterson');

            testCase.verifyFalse(...
                testCase.EXPT.hasParam('BadParam'));

        end

        function testFileRead(testCase)
            testCase.verifyTrue(...
                testCase.EXPT.Epochs(1).hasFile('PresyncFile'));
            testCase.verifyFalse(...
                testCase.EXPT.hasFile('PreSyncFile'));
        end

        function testCustomDisplay(testCase)
            disp(testCase.EXPT)
            disp(testCase.EXPT.Epochs)
        end

        function testAncestor(testCase)
            h = ancestor(testCase.EXPT.Epochs(1).Responses(1), 'experiment');
            testCase.verifyEqual(testCase.EXPT.UUID, h.UUID);
        end

        function testGetByPath(testCase)
            epochPath = '/Experiment/Epochs/0001';
            h = testCase.EXPT.getByPath(epochPath);
            testCase.verifyEqual(h.UUID, testCase.EXPT.Epochs(1).UUID);

            testCase.verifyWarning(@()testCase.EXPT.getByPath('badpath'),...
                'getByPath:InvalidHdfPath');
        end

        function testParamIO(testCase)
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

        function testFileIO(testCase)
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

        function testPropertyIO(testCase)
            % Add a property
            testCase.EXPT.addProperty('Test', eye(3));
            % Confirm new property is now a dynamic property
            testCase.verifyTrue(isprop(testCase.EXPT, 'Test'));
            % Confirm new property correctly wrote to HDF5
            out = h5read('ToyExperiment.h5', '/Experiment/Test');
            testCase.verifyEqual(eye(3), out);

            % TODO: Remove property
        end
        
        function testExperimentIndexing(testCase)
            out = testCase.EXPT.Epochs(1); 
            out = testCase.EXPT.Calibrations(0);
            out = testCase.EXPT.Annotations(0);
            out = testCase.EXPT.Systems(1);
            out = testCase.EXPT.Sources(1);
        end
    end 
end