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
            % Add a first calibration
            cal1 = aod.core.Calibration('PowerMeasurement1', '20220823');
            testCase.EXPT.add(cal1);
            testCase.verifyEqual(numel(testCase.EXPT.Calibrations), 1);

            % Add a second calibration
            cal2 = aod.core.Calibration('PowerMeasurement2', '20220825');
            testCase.EXPT.add(cal2);
            testCase.verifyEqual(numel(testCase.EXPT.Calibrations), 2);

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

            % Add them back, together
            testCase.EXPT.add([cal1, cal2]);
            testCase.verifyEqual(numel(testCase.EXPT.Calibrations), 2);
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
            testCase.verifyTrue(isequal(dateParam, char(getDateYMD())));

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
            testCase.EXPT.add(system);
            testCase.verifyEqual(numel(testCase.EXPT.Systems), 1);

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
            testCase.verifyEqual(numel(channel1.Devices), 2);
            testCase.verifyEqual(numel(channel2.Devices), 1);
            testCase.verifyEqual(numel(system.getAllDevices()), 3);
            testCase.verifyEqual(testCase.EXPT.getAllDevices(), 3);
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

            % Add the epochs back, together
            testCase.EXPT.add([epoch1, epoch2]);

            % Try to add an epoch with the same ID
            badEpoch = aod.core.Epoch(1);
            testCase.verifyError(@() testCase.EXPT.add(badEpoch), Throws(?MException));
            testCase.EXPT.add(badEpoch);
        end

        function datasetIO(testCase)
            % Create a dataset
            dataset1 = aod.core.Dataset('TestDataset1');
            dataset1.setDescription('This is a test dataset');
        end
    end
end 