classdef CoreInterfaceTest < matlab.unittest.TestCase 
% COREINTERFACETEST
%
% Description:
%   Tests adding, searching and removing entities to an Experiment
%
% Parent:
%   matlab.unittest.TestCase
%
% Use:
%   result = runtests('HDFTest.m')
%
% See also:
%   runAODataTestSuite
% -------------------------------------------------------------------------

    properties
        EXPT
    end

    methods (TestClassSetup)
        function methodSetup(testCase)
            testCase.EXPT = aod.core.Experiment(...
                '851_20221117', cd, '20221117',...
                'Administrator', 'Sara Patterson',... 
                'Laboratory', '1P Primate');
        end
    end

    methods (Test)
        function calibrationIO(testCase)
            import matlab.unittest.constraints.Throws
            % Add a first calibration
            cal1 = aod.core.Calibration('PowerMeasurement1', '20220823');
            testCase.EXPT.add(cal1);
            testCase.verifyEqual(numel(testCase.EXPT.Calibrations), 1);

            % Add a second calibration with an empty date
            cal2 = aod.core.Calibration('PowerMeasurement2', []);
            testCase.EXPT.add(cal2);
            testCase.verifyEqual(numel(testCase.EXPT.Calibrations), 2);

            % Add an invalid target
            badTarget = aod.core.Analysis("TestAnalysis");
            testCase.verifyThat(...
                @() testCase.EXPT.Calibrations(1).setTarget(badTarget),...
                Throws("Calibration:InvalidTarget"));

            % Indexing
            testCase.verifyEqual(cal2.UUID, testCase.EXPT.Calibrations(2).UUID);

            % Access calibrations
            calOut = testCase.EXPT.getCalibration('aod.core.Calibration');
            testCase.verifyEqual(numel(calOut), 2);
            
            % Remove a single calibraiton
            testCase.EXPT.removeCalibration(1);
            testCase.verifyEqual(numel(testCase.EXPT.Calibrations), 1);
            testCase.verifyEqual(testCase.EXPT.Calibrations(1).UUID, cal2.UUID);

            % Clear all existing calibrations
            testCase.EXPT.clearCalibrations();
            testCase.verifyEqual(numel(testCase.EXPT.Calibrations), 0);

            % Add them back, together, and the clear
            testCase.EXPT.add([cal1, cal2]);
            testCase.verifyEqual(numel(testCase.EXPT.Calibrations), 2);
            testCase.EXPT.clearCalibrations();
        end

        function analysisIO(testCase)
            % Create an analysis and add a description
            analysis1 = aod.core.Analysis('TestAnalysis1', 'Date', getDateYMD());
            analysis1.setDescription('This is a test analysis');
            
            % Add an experiment
            testCase.EXPT.add(analysis1);
            testCase.verifyEqual(numel(testCase.EXPT.Analyses), 1);

            % Add a second analysis
            analysis2 = aod.core.Analysis('TestAnalysis2');
            testCase.EXPT.add(analysis2);
            testCase.verifyEqual(numel(testCase.EXPT.Analyses), 2);

            % Add a date to the analysis
            testCase.EXPT.Analyses(2).setAnalysisDate(getDateYMD());
            dateParam = getParam(testCase.EXPT.Analyses(2), 'Date');
            test.util.verifyDatesEqual(testCase, dateParam, getDateYMD());

            % Add an empty date to the analysis
            testCase.EXPT.Analyses(1).setAnalysisDate();
            testCase.verifyEmpty(getParam(testCase.EXPT.Analyses(1), 'Date'));

            % Clear the analyses
            testCase.EXPT.clearAnalyses();

            % Create a third analysis with pre-set Parent
            analysis3 = aod.core.Analysis('TestAnalysis3', 'Parent', testCase.EXPT);
            testCase.verifyEqual(testCase.EXPT.UUID, analysis3.Parent.UUID);
            
            % Add all the analyses back
            testCase.EXPT.add([analysis1, analysis2, analysis3]);
            testCase.verifyEqual(numel(testCase.EXPT.Analyses), 3);
        end

        function systemIO(testCase)
            system = aod.core.System('TestSystem');
            system2 = aod.core.System('');

            testCase.EXPT.add([system, system2]);
            testCase.verifyEqual(numel(testCase.EXPT.Systems), 2);

            % Create some channels
            channel1 = aod.core.Channel('TestChannel1');
            channel2 = aod.core.Channel('TestChannel2');

            % Test handle class addition
            system.add([channel1, channel2]);
            testCase.verifyEqual(numel(system.Channels), 2);
            testCase.verifyEqual(numel(testCase.EXPT.getAllChannels()), 2);

            % Create some devices
            device1 = aod.builtin.devices.Pinhole(20);
            device2 = aod.builtin.devices.Pinhole(5);
            device3 = aod.builtin.devices.Pinhole(9);

            % Add to channels
            channel1.add([device1, device2]);
            channel2.add(device3);

            % Access all devices from different entities
            assignin('base', 'EXPT', testCase.EXPT);
            testCase.verifyEqual(numel(channel1.Devices), 2);
            testCase.verifyEqual(numel(channel2.Devices), 1);
            testCase.verifyEqual(numel(system.getAllDevices()), 3);
            testCase.verifyEqual(numel(testCase.EXPT.getAllDevices()), 3);

            % Remove a device
            channel1.removeDevice(2);
            testCase.verifyEqual(numel(testCase.EXPT.Systems(1).Channels(1).Devices), 1);

            % Clear the devices (channel-specific)
            channel1.clearDevices();
            testCase.verifyEqual(numel(testCase.EXPT.Systems(1).Channels(1).Devices), 0);

            % Clear the devices (all)
            testCase.EXPT.Systems(1).clearAllDevices();
            testCase.verifyEqual(numel(testCase.EXPT.getAllDevices()), 0);

            % Remove a channel
            testCase.EXPT.Systems(1).removeChannel(2);
            testCase.verifyEqual(numel(testCase.EXPT.getAllChannels()), 1);
            testCase.EXPT.Systems(1).clearChannels();
            testCase.verifyEqual(numel(testCase.EXPT.getAllChannels()), 0);

        end

        function epochIO(testCase)
            import matlab.unittest.constraints.Throws
            % Create some epochs
            epoch1 = aod.core.Epoch(1);
            epoch2 = aod.core.Epoch(2);

            % Add to an experiment
            testCase.EXPT.add(epoch1);
            testCase.verifyEqual(numel(testCase.EXPT.Epochs), 1);
            testCase.verifyEqual(testCase.EXPT.numEpochs, 1);
            testCase.verifyEqual(testCase.EXPT.epochIDs, 1);

            % Add a second epoch
            testCase.EXPT.add(epoch2);
            testCase.verifyEqual(numel(testCase.EXPT.Epochs), 2);
            testCase.verifyEqual(testCase.EXPT.numEpochs, 2);
            testCase.verifyEqual(testCase.EXPT.epochIDs, [1 2]);

            % Clear all the epochs
            testCase.EXPT.clearEpochs();
            testCase.verifyEqual(numel(testCase.EXPT.Epochs), 0);
            testCase.verifyEqual(testCase.EXPT.numEpochs, 0);

            % Create an epoch with a non-consecutive ID
            epoch3 = aod.core.Epoch(4);

            % Add the epochs back, together
            testCase.EXPT.add([epoch1, epoch2, epoch3]);
            testCase.verifyEqual(numel(testCase.EXPT.Epochs), 3);

            % Check epoch indexing
            testCase.verifyEqual(testCase.EXPT.id2index(4), 3);
            testCase.verifyEqual(testCase.EXPT.id2index([1 2 4]), [1 2 3]);

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

            % Clear all the epochs
            testCase.EXPT.clearEpochs();
            testCase.verifyEqual(numel(testCase.EXPT.Epochs), 0);
        end

        function responseIO(testCase)
            import matlab.unittest.constraints.Throws

            % Add two epochs
            testCase.EXPT.add(aod.core.Epoch(1));
            testCase.EXPT.add(aod.core.Epoch(2));

            % Create some responses
            response1 = aod.core.Response('ResponseWithTiming');
            response1.setData(2:2:8);
            response1.setTiming(linspace(0.5, 2.5, 4));

            response2 = aod.core.Response('ResponseWithoutTiming');
            response2.setData(2:2:8);
            
            % Add to the epochs
            testCase.EXPT.Epochs(1).add(response1);
            testCase.EXPT.Epochs(2).add(response2);
            testCase.verifyEqual(numel(testCase.EXPT.getEpochResponses(1)), 1);
            testCase.verifyEqual(numel(testCase.EXPT.getEpochResponses()), 2);

            % Clear the timing from the first response
            response1.clearTiming();
            testCase.verifyEmpty(testCase.EXPT.Epochs(1).Responses(1).Timing);
            
            % Clear the responses
            testCase.EXPT.clearEpochResponses();
            testCase.verifyEqual(numel(testCase.EXPT.getEpochResponses(1)), 0);
            testCase.verifyEqual(numel(testCase.EXPT.getEpochResponses()), 0);

            % Clear the epochs
            testCase.EXPT.clearEpochs();
            testCase.verifyEqual(numel(testCase.EXPT.Epochs), 0);
        end

        function datasetIO(testCase)
            import matlab.unittest.constraints.Throws

            % Add an epoch
            testCase.EXPT.clearEpochs();
            testCase.EXPT.add(aod.core.Epoch(1));

            % Create some datasets
            dataset1 = aod.core.Dataset('TestDataset1');
            dataset2 = aod.core.Dataset('TestDataset2', eye(3));
            dataset2.setDescription('This is a test dataset');
            
            % Add the datasets to the experiment
            testCase.EXPT.Epochs(1).add([dataset1, dataset2]);
            testCase.verifyEqual(numel(testCase.EXPT.Epochs(1).Datasets), 2);

            % Check dataset data
            testCase.verifyEqual(testCase.EXPT.Epochs(1).Datasets(2).Data, eye(3));
            
            % Clear all the datasets
            testCase.EXPT.clearEpochDatasets();
            testCase.verifyEqual(numel(testCase.EXPT.Epochs(1).Datasets), 0);

            % Clear the epochs
            testCase.EXPT.clearEpochs();
            testCase.verifyEqual(numel(testCase.EXPT.Epochs), 0);

            % Try to add a dataset to the experiment
            testCase.verifyThat(...
                @() testCase.EXPT.add(aod.core.Dataset('TestDataset3')),...
                Throws("Experiment:AddedInvalidEntity"));
        end
    end

    methods (Test)
        function testEntityGroupSearch(testCase)
            testCase.EXPT.add(aod.core.Calibration('TestCalibration1', getDateYMD()));
            testCase.EXPT.add(aod.builtin.calibrations.PowerMeasurement(...
                'Mustang', getDateYMD(), 488));
            out = aod.api.EntityGroupSearch(testCase.EXPT.Calibrations,... 
                'Subclass', 'aod.builtin.calibrations.PowerMeasurement');
            testCase.verifyEqual(numel(out), 1);
            testCase.EXPT.clearCalibrations();
            testCase.verifyEqual(numel(testCase.EXPT.Calibrations), 0);
        end
    end
end 