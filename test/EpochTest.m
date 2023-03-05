classdef EpochTest < matlab.unittest.TestCase
% Test the core interface Epoch class
%
% Description:
%   Tests functionality of aod.core.Epoch
%
% Parent:
%   matlab.unittest.TestCase
%
% Use:
%   result = runtests('EpochTest')
%
% See also:
%   runAODataTestSuite

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------
    properties
        EXPT 
    end

    methods (TestClassSetup)
        function methodSetup(testCase)
            % Create an experiment
            testCase.EXPT = aod.core.Experiment(...
                '851_20221117', cd, '20221117',...
                'Administrator', "Sara Patterson",... 
                'Laboratory', "1P Primate");
        end
    end

    methods (Test, TestTags="Epoch")
        function EpochIO(testCase)
            import matlab.unittest.constraints.Throws

            % If previous functions errored, epochs may still be present
            testCase.EXPT.remove('Epoch', 'all');

            % Create some epochs
            epoch1 = aod.core.Epoch(1);
            epoch2 = aod.core.Epoch(2);

            % Add a date to one of them
            epoch1.setStartTime(datetime('now'));

            % Test default label
            testCase.verifyEqual(epoch1.label, 'Epoch0001');

            % Add to an experiment
            testCase.EXPT.add(epoch1);
            testCase.verifyNumElements(testCase.EXPT.Epochs, 1);
            testCase.verifyEqual(testCase.EXPT.numEpochs, 1);
            testCase.verifyEqual(testCase.EXPT.epochIDs, 1);

            % Add a second epoch
            testCase.EXPT.add(epoch2);
            testCase.verifyNumElements(testCase.EXPT.Epochs, 2);
            testCase.verifyEqual(testCase.EXPT.numEpochs, 2);
            testCase.verifyEqual(testCase.EXPT.epochIDs, [1 2]);

            % Clear all the epochs
            testCase.EXPT.remove('Epoch', 'all');
            testCase.verifyNumElements(testCase.EXPT.Epochs, 0);
            testCase.verifyEqual(testCase.EXPT.numEpochs, 0);

            % Create an epoch with a non-consecutive ID
            epoch3 = aod.core.Epoch(4);

            % Add the epochs back, together
            testCase.EXPT.add([epoch1, epoch2, epoch3]);
            testCase.verifyNumElements(testCase.EXPT.Epochs, 3);

            % Check epoch indexing
            testCase.verifyEqual(testCase.EXPT.id2index(4), 3);
            testCase.verifyEqual(testCase.EXPT.id2index([1 2 4]), [1 2 3]);
            testCase.verifyNumElements(testCase.EXPT.id2epoch([1 2 4]), 3);

            % Add a parameter to all
            setParam(testCase.EXPT.Epochs, 'TestParam1', 0);
            testCase.verifyTrue(all(hasParam(testCase.EXPT.Epochs, 'TestParam1')));
            testCase.verifyEqual(testCase.EXPT.Epochs.getParam('TestParam1'), [0;0;0]);

            % Remove a parameter from all
            testCase.EXPT.Epochs.removeParam('TestParam1');
            testCase.verifyFalse(any(hasParam(testCase.EXPT.Epochs, 'TestParam1')));

            % Add a file to all
            testCase.EXPT.Epochs.setFile('TestFile1', 'test.txt');
            testCase.verifyTrue(all(testCase.EXPT.Epochs.hasFile('TestFile1')));
            testCase.verifyTrue(strcmp(testCase.EXPT.Epochs(1).getFile('TestFile1'), 'test.txt'));
            testCase.verifyTrue(startsWith(testCase.EXPT.Epochs(1).getExptFile('TestFile1'),...
                testCase.EXPT.homeDirectory));

            % Remove a file from all
            testCase.EXPT.Epochs.removeFile('TestFile1');
            testCase.verifyFalse(any(hasFile(testCase.EXPT.Epochs, 'TestFile1')));

            % Try to add an epoch with the same ID
            badEpoch = aod.core.Epoch(1);
            testCase.verifyError(@() testCase.EXPT.add(badEpoch), ?MException);

            % Try to add a calibration to an epoch
            % Try to remove a calibration from an epoch
            testCase.verifyThat(...
                @()testCase.EXPT.removeByEpoch('all', 'Calibration'),...
                Throws("removeByEpoch:InvalidEntityType"));

            % Remove an epoch (by non-consecutive ID)
            testCase.EXPT.remove('Epoch', 4);
            testCase.verifyNumElements(testCase.EXPT.Epochs, 2);

            % Clear all the epochs
            testCase.EXPT.remove('Epoch', 'all');
            testCase.verifyNumElements(testCase.EXPT.Epochs, 0);
        end

        function EpochLinks(testCase)
            % If previous functions errored, epochs may still be present
            testCase.EXPT.remove('Epoch', 'all');

            % Create some epochs
            epoch1 = aod.core.Epoch(1);
            epoch2 = aod.core.Epoch(2);

            % Create some associated entities
            source1 = aod.core.Source('Source1');
            system1 = aod.core.System('System1');

            % Try to add an invalid entity to the epoch
            cal1 = aod.core.Calibration('PowerMeasurement', '20220823');
            testCase.verifyError(@() epoch1.add(cal1), "add:InvalidEntityType");
            
            % Test group assignment
            testCase.verifyEmpty(epoch1.System);
            testCase.verifyEmpty(epoch1.Source);
            setSource([epoch1, epoch2], source1);
            setSystem([epoch1, epoch2], system1);
            testCase.verifyTrue(strcmp(epoch1.System.Name, 'System1'));
            testCase.verifyTrue(strcmp(epoch1.Source.Name, 'Source1'));

            % Try to set invalid Source
            testCase.verifyError(@()epoch1.setSource(cal1), "setSource:InvalidEntityType");
            
            % Try to set invalid System
            testCase.verifyError(@()epoch1.setSystem(cal1), "setSystem:InvalidEntityType");
        end

        function EpochTiming(testCase)
            % Create some epochs
            epoch1 = aod.core.Epoch(1);
            epoch2 = aod.core.Epoch(2);

            % Check whether they have Timing
            testCase.verifyEqual(hasTiming([epoch1, epoch2]), [false, false]);

            % Add timing to one epoch
            epoch1.setTiming(1:4);
            testCase.verifyEqual(epoch1.Timing, (1:4)');
            
            % Clear timing
            setTiming([epoch1, epoch2], []);
            testCase.verifyEqual(hasTiming([epoch1, epoch2]), [false, false]);
        end

        function EpochRemove(testCase)

            epoch1 = aod.core.Epoch(1);
            epoch2 = aod.core.Epoch(2);
            
            % Test removal specification with response
            epoch1.add(aod.core.Response('Response1'));
            epoch2.add(aod.core.Response('Response2a'));
            epoch2.add(aod.core.Response('Response2b'));

            remove([epoch1, epoch2], 'Response', 1);
            testCase.verifyNumElements(epoch2.Responses, 1);

            testCase.verifyWarning(...
                @() epoch2.remove('Response', {'Name', 'Response1'}),...
                "remove:NoQueryMatches");

            testCase.verifyError(@() epoch1.remove('Response', 'badID'),...
                "remove:InvalidID");
            testCase.verifyError(@() epoch1.remove('Calibration'),...
                "remove:InvalidEntityType");

            % Test additional entities, remove from Epoch
            epoch1.add(aod.core.Stimulus('Stim1'));
            epoch1.remove('Stimulus', 'all');
            testCase.verifyEmpty(epoch1.Stimuli);

            epoch1.add(aod.core.EpochDataset('Dataset1'));
            epoch1.remove('EpochDataset', 'all');
            testCase.verifyEmpty(epoch1.EpochDatasets);

            epoch1.add(aod.core.Registration('Reg1', getDateYMD()));
            epoch1.remove('Registration', 'all');
            testCase.verifyEmpty(epoch1.Registrations);
        end
    end

    methods (Test, TestTags=["Error", "Epoch"])
        function EpochErrors(testCase)
            epoch = aod.core.Epoch(1);
            testCase.verifyError(@() epoch.remove('Channel', 1),...
                'remove:InvalidEntityType');
            testCase.verifyError(@() epoch.remove('Response', struct('A', 1)),...
                'remove:InvalidID');

            channel = aod.core.Channel('MyChannel');
            testCase.verifyError(@() epoch.setSource(channel),...
                'setSource:InvalidEntityType');
            testCase.verifyError(@() epoch.setSystem(channel),...
                'setSystem:InvalidEntityType');
        end
    end
end 