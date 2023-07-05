classdef CoreInterfaceTest < matlab.unittest.TestCase 
% Test the basic functionality of AOData's core interface
%
% Description:
%   Tests adding, searching and removing entities to an Experiment and 
%   functionality inherited from aod.core.Entity (e.g. attributes, files)
%
% Parent:
%   matlab.unittest.TestCase
%
% Use:
%   result = runtests('CoreInterfaceTest')
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
            warning('off', 'remove:NoEntitiesToRemove');
        end
    end

    methods (TestClassTeardown)
        function methodTeardown(testCase)
            warning('on', 'remove:NoEntitiesToRemove');
        end
    end

    % Terribly long methods but test function order isn't guarenteed
    methods (Test, TestTags=["Experiment", "Core", "LevelZero"])
        function ExperimentIO(testCase)
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
        end

        function ExperimentErrors(testCase)
            % Miscellaneous errors not tested elsewhere
            testCase.verifyError(...
                @() testCase.EXPT.getByEpoch('all', 'Calibration'),...
                'getByEpoch:NonChildEntityType');

            testCase.verifyEmpty(testCase.EXPT.getByEpoch('all', 'Response'));

            % Check entity checks for remove
            testCase.verifyError(...
                @()testCase.EXPT.remove('Response', 'all'),...
                "remove:InvalidEntityType");
            
            % Confirm error for invalid file
            testCase.verifyError(...
                @() testCase.EXPT.setFile('All', 'Invalid'),...
                "setFile:InvalidName");
        end

        function Equality(testCase)
            testCase.verifyTrue(isequal(testCase.EXPT, testCase.EXPT));
        end

        function PropertyAccess(testCase)
            obj = aod.builtin.devices.Beamsplitter(30, 70);
            value = [1:5; 5:-1:1]';
            obj.setTransmission(value);
            testCase.verifyEqual(obj.transmission, value);
            testCase.verifyError(...
                @(x) setTransmission(x, value'), "setProp:InvalidValue") 
        end

        function AttributeAccess(testCase)
            import aod.infra.ErrorTypes
            testCase.verifyError(...
                @()testCase.EXPT.getAttr('BadParam', ErrorTypes.ERROR),...
                'getAttr:NotFound');
            testCase.verifyWarning(...
                @()testCase.EXPT.getAttr('BadParam', ErrorTypes.WARNING),...
                'getAttr:NotFound');
            testCase.verifyTrue(...
                ismissing(testCase.EXPT.getAttr('BadParam', ErrorTypes.MISSING)));
            testCase.verifyEmpty(...
                testCase.EXPT.getAttr('BadParam', ErrorTypes.NONE));
        end

        function FileAccess(testCase)
            import aod.infra.ErrorTypes

            testCase.verifyError(...
                @()testCase.EXPT.getFile('BadFile', ErrorTypes.ERROR),...
                'getFile:NotFound');
            testCase.verifyWarning(...
                @()testCase.EXPT.getFile('BadFile', ErrorTypes.WARNING),...
                'getFile:NotFound');
            testCase.verifyTrue(...
                ismissing(testCase.EXPT.getFile('BadFile', ErrorTypes.MISSING)));
            testCase.verifyEmpty(...
                testCase.EXPT.getFile('BadFile', ErrorTypes.NONE));

            epoch = aod.core.Epoch(10);
            epoch.setFile('MyFile', 'test.txt');
            testCase.verifyError(...
                @()epoch.getExptFile('MyFile'), "getExptFile:NoHomeDirectory");
        end
    end

    methods (Test, TestTags=["Calibration", "Core", "LevelOne"])
        function calibrationIO(testCase)
            import matlab.unittest.constraints.Throws

            % Add a first calibration
            cal1 = aod.core.Calibration('PowerMeasurement1', '20220823');
            testCase.EXPT.add(cal1);
            testCase.verifyEqual(numel(testCase.EXPT.Calibrations), 1);

            % Add a second calibration with an empty date
            cal2 = aod.builtin.calibrations.PowerMeasurement('Mustang', [], 488);
            cal2.addMeasurements({22, 100});
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
            testCase.EXPT.Calibrations(1).setDate([]);
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
    end

    methods (Test, TestTags=["Analysis", "Core", "LevelOne"])
        function AnalysisIO(testCase)
            % Create an analysis and add a description
            analysis1 = aod.core.Analysis('TestAnalysis1',... 
                "Date", getDateYMD());
            analysis1.setDescription('This is a test analysis');
            
            % Add an experiment
            testCase.EXPT.add(analysis1);
            testCase.verifyEqual(numel(testCase.EXPT.Analyses), 1);

            % Add a second analysis
            analysis2 = aod.core.Analysis('TestAnalysis2');
            testCase.EXPT.add(analysis2);
            testCase.verifyEqual(numel(testCase.EXPT.Analyses), 2);

            % Add a date to the analysis
            dateYMD = getDateYMD();
            analysis2.setDate(dateYMD);
            test.util.verifyDatesEqual(testCase, analysis2.analysisDate, dateYMD);

            % Add an empty date to the analysis
            testCase.EXPT.Analyses(1).setDate();
            testCase.verifyEmpty(testCase.EXPT.Analyses(1).analysisDate);

            % Remove analyses one by one
            testCase.EXPT.remove('Analysis', 1);
            testCase.verifyEqual(numel(testCase.EXPT.Analyses), 1);
            testCase.EXPT.remove('Analysis', 1);
            testCase.verifyEmpty(testCase.EXPT.Analyses);

            % Create a third analysis with pre-set Parent
            analysis3 = aod.core.Analysis('TestAnalysis3',... 
                'Parent', testCase.EXPT);
            testCase.verifyEqual(testCase.EXPT.UUID, analysis3.Parent.UUID);
            
            % Add all the analyses back
            testCase.EXPT.add([analysis1, analysis2, analysis3]);
            testCase.verifyEqual(numel(testCase.EXPT.Analyses), 3);
            
            % Clear all the analyses
            testCase.EXPT.remove('Analysis', 'all');
        end 
    end

    methods (Test, TestTags=["Annotation", "Core", "LevelOne"])
        function AnnotationIO(testCase)

            testCase.verifyFalse(testCase.EXPT.has('Annotation'));
            
            % Create a few annotations
            annotation1 = aod.core.Annotation('Annotation1');
            annotation2 = aod.core.Annotation('Annotation2');

            % Add multiple annotations to the experiment at once
            testCase.EXPT.add([annotation1, annotation2]);
            testCase.verifyNumElements(testCase.EXPT.Annotations, 2);
            testCase.verifyTrue(testCase.EXPT.has('Annotation'));

            % Query from Experiment by name
            out = testCase.EXPT.get('Annotation', {'Name', 'Annotation1'});
            testCase.verifyNumElements(out, 1);

            % Query from Experiment by attribute presence
            annotation2.setAttr('MyParam', 1);
            testCase.verifyTrue(...
                testCase.EXPT.has('Annotation', {'Attr', 'MyParam'}));
            out = testCase.EXPT.get('Annotation', {'Attr', 'MyParam'});
            testCase.verifyNumElements(out, 1);
            testCase.verifyTrue(strcmpi(out.Name, 'Annotation2'));

            % Query from Experiment by attribute value
            out = testCase.EXPT.get('Annotation', {'Attr', 'MyParam', 1});
            testCase.verifyNumElements(out, 1);
            testCase.verifyEmpty(...
                testCase.EXPT.get('Annotation', {'Attr', 'MyParam', 2}));

            % Test query removal from Experiment
            testCase.EXPT.remove('Annotation', 1);
            testCase.verifyNumElements(testCase.EXPT.Annotations, 1);

            % Test clear all removal
            testCase.EXPT.remove('Annotation', 'all');
            testCase.verifyEmpty(testCase.EXPT.Annotations);
        end

        function AnnotationLinks(testCase)
            annotation1 = aod.core.Annotation('Annotation1');
            annotation2 = aod.core.Annotation('Annotation2');

            % Set a valid source
            setSource([annotation1, annotation2], aod.core.Source('Source1'));
            testCase.verifyEqual(annotation1.Source.Name, "Source1");
            testCase.verifyEqual(annotation2.Source.Name, "Source1");

            % Set an invalid source
            testCase.verifyError(...
                @() annotation1.setSource(aod.core.System('System1')),...
                "setSource:InvalidEntityType");

            % Remove an existing source
            annotation1.setSource([]);
            testCase.verifyEmpty(annotation1.Source);
        end
    end

    methods (Test, TestTags=["System", "Core", "LevelOne"])
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

            % Test has query
            testCase.verifyTrue(system.has('Channel', {'Name', 'TestChannel1'}));

            % Test get access
            testCase.verifyNumElements(system.get('Channel'), 3);
            testCase.verifyNumElements( ...
                system.get('Channel', {'Name', 'TestChannel1'}), 1);

            % Create some devices
            device1 = aod.builtin.devices.Pinhole(20);
            device2 = aod.builtin.devices.Pinhole(5);
            device3 = aod.builtin.devices.Pinhole(9);

            % Add to channels
            channel1.add([device1, device2]);
            channel2.add(device3);

            % Access all devices from different entities
            testCase.verifyNumElements(channel1.Devices, 2);
            testCase.verifyNumElements(channel1.get('Device'), 2);
            testCase.verifyNumElements(channel2.Devices, 1);
            testCase.verifyEqual(numel(system.get('Device')), 3);
            testCase.verifyEqual(numel(testCase.EXPT.get('Device')), 3);
            testCase.verifyTrue(channel1.has('Device'));

            % Check device ancestor
            testCase.verifyEqual(...
                device1.getParent(aod.common.EntityTypes.EXPERIMENT),...
                testCase.EXPT);

            % Query devices from Channel
            testCase.verifyNumElements(channel1.get('Device',... 
                {'Attr', 'Diameter', 5}), 1);

            % Work with device array
            allDevices = testCase.EXPT.get('Device');
            % Add notes to all the devices, then remove them
            allDevices.setNote("This is a note");
            testCase.verifyEqual(numel(device1.notes), 1);
            allDevices.removeNote(1);
            testCase.verifyEqual(numel(device1.notes), 0);

            % Add notes from all the devices
            setNote([device1,device2,device3], "This is a note");
            % Change a specific note
            device2.setNote("New note", 1);
            testCase.verifyEqual(device2.notes(1), "New note");
            % Remove note from all devices
            removeNote([device1, device2, device3], 'all');
            
            % Remove a device
            channel1.remove('Device', 2);
            testCase.verifyEqual(numel(testCase.EXPT.Systems(1).Channels(1).Devices), 1);
            
            % Check for error when removing invalid entity
            testCase.verifyError(...
                @() channel1.remove('System', 1), "remove:InvalidEntityType");

            % Check for error when providing invalid ID
            testCase.verifyError(...
                @() channel1.remove('bad'), "remove:InvalidID");
            testCase.verifyError(...
                @() channel1.remove('Device', 'bad'), "remove:InvalidID");

            % Clear the devices (channel-specific)
            channel1.remove('Device', 'all');
            testCase.verifyFalse(channel1.has('Device'));
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
            testCase.EXPT.Systems.remove('Channel', 'all');
            testCase.verifyEqual(numel(testCase.EXPT.get('Channel')), 0);

            % Remove a system
            testCase.EXPT.remove('System', 1);
            testCase.verifyEqual(numel(testCase.EXPT.Systems), 1);
            testCase.verifyEqual(testCase.EXPT.Systems(1).UUID, system2.UUID);

            % Clear all systems
            testCase.EXPT.remove('System', 'all');
            testCase.verifyEqual(numel(testCase.EXPT.Systems), 0);
        end

        function SystemErrors(testCase)
            system1 = aod.core.System('System1');
            testCase.verifyError(@()system1.get('Epoch'), 'get:InvalidEntityType');

            % No error even though device is empty
            system2 = aod.core.System('System2');
            clearAllDevices([system1, system2]);
        end
    end

    methods (Test, TestTags=["Response", "Core", "LevelTwo"])
        function ResponseIO(testCase)
            import matlab.unittest.constraints.Throws

            % If previous functions errored, epochs may still be present
            testCase.EXPT.remove('Epoch', 'all');

            % Add two epochs
            testCase.EXPT.add(aod.core.Epoch(1));
            testCase.EXPT.add(aod.core.Epoch(2));

            % Create some responses
            response1 = aod.core.Response('ResponseWithTiming');
            response1.setData(2:2:8);
            response1.setTiming(seconds(linspace(0.5, 2.5, 4)));

            response2 = aod.core.Response('ResponseWithoutTiming');
            response2.setData(2:2:8);
            
            % Add to an epoch and test various access methods
            testCase.EXPT.Epochs(1).add([response1, response2]);
            testCase.verifyNumElements(testCase.EXPT.getByEpoch(1, 'Response'), 2);
            testCase.verifyNumElements(testCase.EXPT.Epochs(1).get('Response'), 2);
            testCase.verifyNumElements(testCase.EXPT.getByEpoch('all', 'Response'), 2);
            testCase.verifyNumElements(testCase.EXPT.get('Response'), 2);

            % Clear the timing from the first response
            response1.setTiming([]);
            testCase.verifyEmpty(testCase.EXPT.Epochs(1).Responses(1).Timing);

            % Add timing at the epoch level
            testCase.EXPT.Epochs(2).setTiming(seconds(linspace(0.5, 2.5, 4)));
            testCase.verifyTrue(testCase.EXPT.Epochs(2).hasTiming());
            testCase.EXPT.Epochs(2).setTiming([]);
            testCase.verifyFalse(testCase.EXPT.Epochs(2).hasTiming());

            % Remove a response
            testCase.EXPT.Epochs(1).remove('Response', 1);
            testCase.verifyEqual(numel(testCase.EXPT.getByEpoch(1, 'Response')), 1);
            
            % Clear the responses
            testCase.EXPT.removeByEpoch('all', 'Response');
            testCase.verifyEqual(numel(testCase.EXPT.getByEpoch(1, 'Response')), 0);
            testCase.verifyEqual(numel(testCase.EXPT.getByEpoch('all', 'Response')), 0);

            % Clear the epochs
            testCase.EXPT.remove('Epoch', 'all');
            testCase.verifyEqual(numel(testCase.EXPT.Epochs), 0);
        end
    end

    methods (Test, TestTags=["EpochDataset", "Core", "LevelTwo"])
        function EpochDatasetIO(testCase)
            import matlab.unittest.constraints.Throws

            % Add an epoch
            testCase.EXPT.remove('Epoch', 'all');
            testCase.EXPT.add(aod.core.Epoch(1));

            % Create some datasets
            dataset1 = aod.core.EpochDataset('TestDataset1');
            dataset2 = aod.core.EpochDataset('TestDataset2',...
                'Data', eye(3));
            dataset2.setDescription('This is a test dataset');
            
            % Add the datasets to the experiment
            testCase.EXPT.Epochs(1).add([dataset1, dataset2]);

            % Test direct dataset access
            testCase.verifyEqual(numel(testCase.EXPT.Epochs(1).EpochDatasets), 2);
            % Test Epoch's get access
            testCase.verifyNumElements(testCase.EXPT.Epochs(1).get('EpochDataset'), 2);
            testCase.verifyNumElements(testCase.EXPT.Epochs(1).get(...
                'EpochDataset', {'Name', 'TestDataset1'}), 1);
            % Test Experiment's get access
            testCase.verifyEqual(numel(testCase.EXPT.getByEpoch('all', 'EpochDataset')), 2);
            testCase.verifyNumElements(testCase.EXPT.get('EpochDataset'), 2);

            % Check dataset data
            testCase.verifyEqual(testCase.EXPT.Epochs(1).EpochDatasets(2).Data, eye(3));
            testCase.verifyNumElements(testCase.EXPT.Epochs(1).get(...
                'EpochDataset', {'Dataset', 'Data', eye(3)}), 1);
            testCase.verifyTrue(testCase.EXPT.Epochs(1).has(...
                'EpochDataset', {'Dataset', 'Data', eye(3)}));

            % Remove datasets by query
            testCase.EXPT.Epochs(1).remove('EpochDataset', {'Dataset', 'Data', eye(3)});
            testCase.verifyFalse(testCase.EXPT.Epochs(1).has(...
                'EpochDataset', {'Dataset', 'Data', eye(3)}));
            
            % Clear all the datasets
            testCase.EXPT.removeByEpoch('all', 'EpochDataset');
            testCase.verifyEqual(numel(testCase.EXPT.Epochs(1).EpochDatasets), 0);

            % Clear the epochs
            testCase.EXPT.remove('Epoch', 'all');
            testCase.verifyEqual(numel(testCase.EXPT.Epochs), 0);

            % Try to add a dataset to the experiment
            testCase.verifyThat(...
                @() testCase.EXPT.add(aod.core.EpochDataset('TestDataset3')),...
                Throws("Experiment:AddedInvalidEntity"));
        end
    end

    methods (Test, TestTags=["ExperimentDataset", "Core", "LevelOne"])
        function ExperimentDatasetIO(testCase)
            
            % Create some datasets
            dataset1 = aod.core.ExperimentDataset('TestDataset1');
            dataset2 = aod.core.ExperimentDataset('TestDataset2', 'Data', eye(3));
            dataset2.setDescription('This is a test dataset');

            % Add all at once
            testCase.EXPT.add([dataset1, dataset2]);
            
            % Test direct dataset access
            testCase.verifyEqual(numel(testCase.EXPT.ExperimentDatasets), 2);
            testCase.verifyEqual(numel(testCase.EXPT.get('ExperimentDataset')), 2);


            % Check dataset data
            testCase.verifyEqual(testCase.EXPT.ExperimentDatasets(2).Data, eye(3));
            testCase.verifyNumElements(testCase.EXPT.get(...
                'ExperimentDataset', {'Dataset', 'Data', eye(3)}),1);
            
            % Clear all the datasets
            testCase.EXPT.remove('ExperimentDataset', 'all');
            testCase.verifyEqual(numel(testCase.EXPT.ExperimentDatasets), 0);
        end
    end

    methods (Test, TestTags=["Registration", "Core", "LevelTwo"])
        function registrationIO(testCase)
            import matlab.unittest.constraints.Throws

            % If previous functions errored, epochs may still be present
            testCase.EXPT.remove('Epoch', 'all');

            % Add an epoch 
            testCase.EXPT.add(aod.core.Epoch(1));
            testCase.EXPT.add(aod.core.Epoch(2));

            % Create some registrations
            reg1 = aod.core.Registration('Reg1', getDateYMD());
            reg2 = aod.core.Registration('Reg2');

            % Add and remove registration dates
            reg1.setDate([]);
            regDate = getDateYMD();
            setDate([reg1, reg2], regDate);
            test.util.verifyDatesEqual(testCase, reg1.registrationDate, regDate);

            % Add Registrations to an Epoch
            testCase.EXPT.Epochs(1).add([reg1, reg2]);
            
            % Test access from Experiment
            testCase.verifyNumElements(testCase.EXPT.get('Registration'), 2);

            % Clear the registrations
            testCase.EXPT.removeByEpoch(1, 'Registration');

            % Clear the epochs
            testCase.EXPT.remove('Epoch', 'all');
            testCase.verifyEqual(numel(testCase.EXPT.Epochs), 0);
        end
    end

    methods (Test, TestTags=["Stimulus", "CoreApi"])
        function StimulusIO(testCase)
            
            % If previous functions errored, epochs may still be present
            testCase.EXPT.remove('Epoch', 'all');

            % Create two Epochs and add to the Experiment
            epoch1 = aod.core.Epoch(1);
            epoch2 = aod.core.Epoch(2);
            testCase.EXPT.add([epoch1, epoch2]);

            % Create two stimuli
            stim1 = aod.core.Stimulus('Stim1');
            stim2 = aod.core.Stimulus('Stim2');

            % Add to the epochs
            epoch1.add(stim1); 
            epoch2.add(stim2);

            % Test various access methods
            testCase.verifyNumElements(epoch1.Stimuli, 1);
            testCase.verifyNumElements(testCase.EXPT.get('Stimulus'), 2);
            testCase.verifyNumElements(testCase.EXPT.getByEpoch('all', 'Stimulus'), 2);
            testCase.verifyNumElements(testCase.EXPT.getByEpoch(1, 'Stimulus'), 1);
        end

        function StimulusErrors(testCase)
            stim1 = aod.core.Stimulus('StimWithoutProtocol');
            testCase.verifyError(@() stim1.getProtocol(), "getProtocol:ProtocolNotSet");
        end

        function StimulusProtocol(testCase)
            % Create protocols with and without calibration
            protocol1 = test.TestStimProtocol([],...
                'PreTime', 5, 'StimTime', 5, 'TailTime', 5,...
                'BaseIntensity', 0.5, 'Contrast', 1);

            % Create a stimulus with the protocol
            stim1 = aod.core.Stimulus('StimWithProtocol', protocol1);

            % Verify Stimulus protocol properties are correct
            testCase.verifyEqual(stim1.protocolName, "TestStimProtocol");
            testCase.verifyTrue(strcmp(stim1.protocolClass, class(protocol1)));

            % Verify protocol output is correct
            testCase.verifyEqual(stim1.getProtocol(), protocol1);
        end
    end
end 