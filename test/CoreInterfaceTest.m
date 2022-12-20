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
        function experimentIO(testCase)
            import matlab.unittest.constraints.Throws
            
            % Add a relative file
            testCase.EXPT.setFile('RelFile', fullfile(cd, 'test_data', 'test.txt'));
            % Add an absolute file
            testCase.EXPT.setFile('AbsFile', 'C:\Users\sarap\Desktop\test.txt');

            % Test homeDirectory removal
            testCase.verifyFalse(contains(testCase.EXPT.files('RelFile'), cd));
            testCase.verifyTrue(contains(testCase.EXPT.files('AbsFile'), 'C:\Users\sarap\Desktop'));

            % Test getFile vs getExptFile
            testCase.verifyTrue(contains(testCase.EXPT.getExptFile('RelFile'), cd));
            testCase.verifyFalse(contains(testCase.EXPT.getFile('RelFile'), cd));

            % Test setHomeDirectory
            testCase.EXPT.setHomeDirectory(fileparts(cd));
            testCase.verifyEqual(testCase.EXPT.getExptFile('RelFile'),...
                fullfile(fileparts(cd), 'test_data', 'test.txt'));
            testCase.EXPT.setHomeDirectory(cd);

            % Description options
            testCase.EXPT.setDescription('This is a test');
            testCase.verifyFalse(isempty(testCase.EXPT.description));
            testCase.EXPT.setDescription();
            testCase.verifyTrue(isempty(testCase.EXPT.description));

            % Check empty entities
            testCase.verifyEmpty(testCase.EXPT.get('Channel'));
            testCase.verifyEmpty(testCase.EXPT.get('Device'));

            % Check entity checks for remove
            testCase.verifyThat(...
                @()testCase.EXPT.remove('Response', 'all'),...
                Throws("remove:NonChildEntityType"));
        end

        function sourceIO(testCase)
            import matlab.unittest.constraints.Throws

            % Create a parent source
            source1 = aod.core.Source('MC00851');
            source2 = aod.core.Source('MC00838');
            testCase.EXPT.add([source1, source2]);
            testCase.verifyEqual(numel(testCase.EXPT.getAllSources()), 2);

            % Create second-level source
            source1a = aod.core.Source('OS');
            source1b = aod.core.Source('OD');
            source1.add([source1a, source1b]);
            testCase.verifyEqual(numel(testCase.EXPT.getAllSources()), 4);
            
            % Check labels
            testCase.verifyEqual('MC00851_OS', source1a.label);

            % Create third-level source
            source1a1 = aod.core.Source('Right');
            source1a2 = aod.core.Source('Left');
            source1a.add([source1a1, source1a2]);
            testCase.verifyEqual(numel(testCase.EXPT.getAllSources()), 6);

            source1b1 = aod.core.Source('Right');
            source1b.add(source1b1);
            testCase.verifyEqual(numel(testCase.EXPT.getAllSources()), 7);

            % Remove a single source
            testCase.EXPT.remove('Source', 2);
            testCase.verifyEqual(numel(testCase.EXPT.getAllSources()), 6);

            % Clear all the sources
            testCase.EXPT.remove('Source', 'all');
            testCase.verifyEqual(numel(testCase.EXPT.getAllSources()), 0);
        end

        function calibrationIO(testCase)
            import matlab.unittest.constraints.Throws
            % Add a first calibration
            cal1 = aod.core.Calibration('PowerMeasurement1', '20220823');
            testCase.EXPT.add(cal1);
            testCase.verifyEqual(numel(testCase.EXPT.Calibrations), 1);

            % Add a second calibration with an empty date
            cal2 = aod.builtin.calibrations.PowerMeasurement('Mustang', [], 488);
            cal2.addMeasurement(22, 100);
            testCase.EXPT.add(cal2);
            testCase.verifyEqual(numel(testCase.EXPT.Calibrations), 2);

            % Add an invalid target
            badTarget = aod.core.Analysis("TestAnalysis");
            testCase.verifyThat(...
                @() testCase.EXPT.Calibrations(1).setTarget(badTarget),...
                Throws("Calibration:InvalidTarget"));

            % Indexing
            testCase.verifyEqual(cal2.UUID, testCase.EXPT.Calibrations(2).UUID);

            % Remove a calibration date
            testCase.EXPT.Calibrations(1).setCalibrationDate([]);
            testCase.verifyTrue(isempty(testCase.EXPT.Calibrations(1).calibrationDate));
            
            % Remove a single calibraiton
            testCase.EXPT.remove('Calibration', 1);
            testCase.verifyEqual(numel(testCase.EXPT.Calibrations), 1);
            testCase.verifyEqual(testCase.EXPT.Calibrations(1).UUID, cal2.UUID);

            % Clear all existing calibrations
            testCase.EXPT.remove('Calibration', 'all');
            testCase.verifyEqual(numel(testCase.EXPT.Calibrations), 0);

            % Add them back, together, and the clear
            testCase.EXPT.add([cal1, cal2]);
            testCase.verifyEqual(numel(testCase.EXPT.Calibrations), 2);
            testCase.EXPT.remove('Calibration', 'all');
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
            analysis2.setAnalysisDate(getDateYMD());
            dateParam = getParam(analysis2, 'Date');
            test.util.verifyDatesEqual(testCase, dateParam, getDateYMD());

            % Add an empty date to the analysis
            testCase.EXPT.Analyses(1).setAnalysisDate();
            testCase.verifyEmpty(getParam(testCase.EXPT.Analyses(1), 'Date'));

            % Remove analyses one by one
            testCase.EXPT.remove('Analysis', 1);
            testCase.verifyEqual(numel(testCase.EXPT.Analyses), 1);
            testCase.EXPT.remove('Analysis', 1);
            testCase.verifyEmpty(testCase.EXPT.Analyses);

            % Create a third analysis with pre-set Parent
            analysis3 = aod.core.Analysis('TestAnalysis3', 'Parent', testCase.EXPT);
            testCase.verifyEqual(testCase.EXPT.UUID, analysis3.Parent.UUID);
            
            % Add all the analyses back
            testCase.EXPT.add([analysis1, analysis2, analysis3]);
            testCase.verifyEqual(numel(testCase.EXPT.Analyses), 3);
            
            % Clear all the analyses
            testCase.EXPT.remove('Analysis', 'all');
        end

        function systemIO(testCase)
            system = aod.core.System('TestSystem');
            system2 = aod.core.System('');

            testCase.EXPT.add([system, system2]);
            testCase.verifyEqual(numel(testCase.EXPT.Systems), 2);

            % Request system child entities, while there are none
            testCase.verifyEmpty(testCase.EXPT.get('Channel'));
            testCase.verifyEmpty(testCase.EXPT.get('Device'));

            % Create some channels
            channel1 = aod.core.Channel('TestChannel1');
            channel2 = aod.core.Channel('TestChannel2');
            channel3 = aod.core.Channel('TestChannel3');

            % Test handle class addition
            system.add([channel1, channel2, channel3]);
            testCase.verifyEqual(numel(system.Channels), 3);
            testCase.verifyEqual(numel(testCase.EXPT.get('Channel')), 3);

            % Create some devices
            device1 = aod.builtin.devices.Pinhole(20);
            device2 = aod.builtin.devices.Pinhole(5);
            device3 = aod.builtin.devices.Pinhole(9);

            % Add to channels
            channel1.add([device1, device2]);
            channel2.add(device3);

            % Access all devices from different entities
            testCase.verifyEqual(numel(channel1.Devices), 2);
            testCase.verifyEqual(numel(channel2.Devices), 1);
            testCase.verifyEqual(numel(system.get('Device')), 3);
            testCase.verifyEqual(numel(testCase.EXPT.get('Device')), 3);
            
            % Work with device array
            allDevices = testCase.EXPT.get('Device');
            % Add notes to all the devices, then remove them
            allDevices.addNote("This is a note");
            testCase.verifyEqual(numel(device1.notes), 1);
            allDevices.removeNote(1);
            testCase.verifyEqual(numel(device1.notes), 0);

            % Clear notes from all the devices, then clear them
            addNote([device1,device2,device3], "This is a note");
            clearNotes([device1, device2, device3]);
            
            % Remove a device
            channel1.remove('Device', 2);
            testCase.verifyEqual(numel(testCase.EXPT.Systems(1).Channels(1).Devices), 1);

            % Clear the devices (channel-specific)
            channel1.remove('Device', 'all');
            testCase.verifyEqual(numel(testCase.EXPT.Systems(1).Channels(1).Devices), 0);

            % Clear the devices (all)
            testCase.EXPT.Systems(1).clearAllDevices();
            testCase.verifyEqual(numel(testCase.EXPT.get('Device', 'all')), 0);

            % Remove a channel
            testCase.EXPT.Systems(1).remove('Channel', 2);
            testCase.verifyEqual(numel(testCase.EXPT.get('Channel')), 2);
            testCase.EXPT.Systems(1).remove(2);
            testCase.verifyEqual(numel(testCase.EXPT.get('Channel')), 1);

            % Clear all channels
            testCase.EXPT.Systems(1).remove('Channel', 'all');
            testCase.verifyEqual(numel(testCase.EXPT.get('Channel')), 0);

            % Remove a system
            testCase.EXPT.remove('System', 1);
            testCase.verifyEqual(numel(testCase.EXPT.Systems), 1);
            testCase.verifyEqual(testCase.EXPT.Systems(1).UUID, system2.UUID);

            % Clear all systems
            testCase.EXPT.remove('System', 'all');
            testCase.verifyEqual(numel(testCase.EXPT.Systems), 0);
        end

        function epochIO(testCase)
            import matlab.unittest.constraints.Throws
            % Create some epochs
            epoch1 = aod.core.Epoch(1);
            epoch2 = aod.core.Epoch(2);

            % Add a date to one of them
            epoch1.setStartTime(datetime('now'));

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
            cal = aod.core.Calibration('PowerMeasurement', '20220823');
            testCase.verifyThat(...
                @() testCase.EXPT.Epochs(1).add(cal),...
                Throws("Epoch:AddedInvalidEntity"));

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
            testCase.verifyEqual(numel(testCase.EXPT.getFromEpoch(1, 'Response')), 1);
            testCase.verifyEqual(numel(testCase.EXPT.getFromEpoch('all', 'Response')), 2);

            % Clear the timing from the first response
            response1.clearTiming();
            testCase.verifyEmpty(testCase.EXPT.Epochs(1).Responses(1).Timing);

            % Add timing at the epoch level
            testCase.EXPT.Epochs(2).setTiming(linspace(0.5, 2.5, 4));
            testCase.verifyTrue(testCase.EXPT.Epochs(2).hasTiming());
            testCase.EXPT.Epochs(2).clearTiming();
            testCase.verifyFalse(testCase.EXPT.Epochs(2).hasTiming());
            
            % Clear the responses
            testCase.EXPT.removeByEpoch('all', 'Response');
            testCase.verifyEqual(numel(testCase.EXPT.getFromEpoch(1, 'Response')), 0);
            testCase.verifyEqual(numel(testCase.EXPT.getFromEpoch('all', 'Response')), 0);

            % Clear the epochs
            testCase.EXPT.remove('Epoch', 'all');
            testCase.verifyEqual(numel(testCase.EXPT.Epochs), 0);
        end

        function datasetIO(testCase)
            import matlab.unittest.constraints.Throws

            % Add an epoch
            testCase.EXPT.remove('Epoch', 'all');
            testCase.EXPT.add(aod.core.Epoch(1));

            % Create some datasets
            dataset1 = aod.core.Dataset('TestDataset1');
            dataset2 = aod.core.Dataset('TestDataset2', eye(3));
            dataset2.setDescription('This is a test dataset');
            
            % Add the datasets to the experiment
            testCase.EXPT.Epochs(1).add([dataset1, dataset2]);
            testCase.verifyEqual(numel(testCase.EXPT.Epochs(1).Datasets), 2);
            testCase.verifyEqual(numel(testCase.EXPT.getFromEpoch('all', 'Datasets')), 2);

            % Check dataset data
            testCase.verifyEqual(testCase.EXPT.Epochs(1).Datasets(2).Data, eye(3));
            
            % Clear all the datasets
            testCase.EXPT.removeByEpoch('all', 'Dataset');
            testCase.verifyEqual(numel(testCase.EXPT.Epochs(1).Datasets), 0);

            % Clear the epochs
            testCase.EXPT.remove('Epoch', 'all');
            testCase.verifyEqual(numel(testCase.EXPT.Epochs), 0);

            % Try to add a dataset to the experiment
            testCase.verifyThat(...
                @() testCase.EXPT.add(aod.core.Dataset('TestDataset3')),...
                Throws("Experiment:AddedInvalidEntity"));
        end

        function registrationIO(testCase)
            import matlab.unittest.constraints.Throws

            % Add an epoch 
            testCase.EXPT.remove('Epoch', 'all');
            testCase.EXPT.add(aod.core.Epoch(1));
            testCase.EXPT.add(aod.core.Epoch(2));

            % Create some registrations

            % Clear the epochs
            testCase.EXPT.remove('Epoch', 'all');
            testCase.verifyEqual(numel(testCase.EXPT.Epochs), 0);
        end
    end

end 