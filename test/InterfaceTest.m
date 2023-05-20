classdef InterfaceTest < matlab.unittest.TestCase 
% INTERFACETEST
%
% Description:
%   Tests equality of core and persistent interface
%
% Parent:
%    matlab.unittest.TestCase
%
% Use:
%   result = runtests('InterfaceTest.m')
%
% See also:
%   runAODataTestSuite

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------


    properties
        pEXPT
        cEXPT 
    end

    methods (TestClassSetup)
        function methodSetup(testCase)
            % Creates an experiment, writes to HDF5 and reads back in  
            fileName = fullfile(getpref('AOData', 'BasePackage'), ...
                'test', 'ToyExperiment.h5');            
            if ~exist(fileName, 'file')
                ToyExperiment(true, true);
            end
            matFileName = strrep(fileName, '.h5', '.mat');
            if ~exist(matFileName, 'file')
                ToyExperiment(true, true);
            end
            S = load(matFileName);
            testCase.cEXPT = S.ToyExperiment;
            testCase.pEXPT = loadExperiment(fileName);
        end
    end

    methods (Test)
        function EntityCounts(testCase)
            testCase.verifyEqual(...
                numel(testCase.cEXPT.Epochs),...
                numel(testCase.pEXPT.Epochs));
            testCase.verifyEqual(...
                numel(testCase.cEXPT.Analyses),...
                numel(testCase.pEXPT.Analyses));
            testCase.verifyEqual(...
                numel(testCase.cEXPT.ExperimentDatasets),...
                numel(testCase.pEXPT.ExperimentDatasets));
            testCase.verifyEqual(...
                numel(testCase.cEXPT.Annotations),...
                numel(testCase.pEXPT.Annotations));
            testCase.verifyEqual(...
                numel(testCase.cEXPT.Calibrations),...
                numel(testCase.pEXPT.Calibrations));
            testCase.verifyEqual(...
                numel(testCase.cEXPT.Systems), ...
                numel(testCase.pEXPT.Systems));
            testCase.verifyEqual(...
                numel(testCase.cEXPT.Sources), ...
                numel(testCase.pEXPT.Sources));

            % Epoch hierarchy
            testCase.verifyEqual(...
                numel(testCase.cEXPT.Epochs(1).EpochDatasets), ...
                numel(testCase.pEXPT.Epochs(1).EpochDatasets));
            testCase.verifyEqual(...
                numel(testCase.cEXPT.Epochs(1).Registrations), ...
                numel(testCase.pEXPT.Epochs(1).Registrations));
            testCase.verifyEqual(...
                numel(testCase.cEXPT.Epochs(1).Responses), ...
                numel(testCase.pEXPT.Epochs(1).Responses));
            testCase.verifyEqual(...
                numel(testCase.cEXPT.Epochs(1).Stimuli), ...
                numel(testCase.pEXPT.Epochs(1).Stimuli));

            % System hierarchy
            testCase.verifyEqual( ...
                numel(testCase.cEXPT.Systems(1).Channels), ...
                numel(testCase.pEXPT.Systems(1).Channels));
            testCase.verifyEqual(...
                numel(testCase.cEXPT.Systems(1).Channels(1).Devices), ...
                numel(testCase.pEXPT.Systems(1).Channels(1).Devices));
        end


        function ExperimentProperties(testCase)
            testCase.verifyEqual(...
                testCase.cEXPT.expectedAttributes,...
                testCase.pEXPT.expectedAttributes);
            
            test.util.verifyDatesEqual(testCase,... 
                testCase.cEXPT.experimentDate,...
                testCase.pEXPT.experimentDate);
            
            testCase.verifyEqual(... 
                testCase.cEXPT.homeDirectory,...
                testCase.pEXPT.homeDirectory);

            testCase.verifyEqual(...
                testCase.cEXPT.epochIDs,...
                testCase.pEXPT.epochIDs);

            testCase.verifyEqual(...
                testCase.cEXPT.UUID,...
                testCase.pEXPT.UUID);               

            testCase.verifyEqual(...
                testCase.cEXPT.description,...
                testCase.pEXPT.description);

            testCase.verifyEqual( ...
                testCase.cEXPT.Code, ...
                testCase.pEXPT.Code);
        end
        
        function DeviceProperties(testCase)
            cDevice = testCase.cEXPT.Systems(1).Channels(1).Devices(1);
            pDevice = testCase.pEXPT.query({'UUID', cDevice.UUID});

            testCase.verifyEqual(cDevice.wavelength, pDevice.wavelength);
            testCase.verifyEqual(cDevice.label, pDevice.label);
        end

        function SourceProperties(testCase)
            cSource = testCase.cEXPT.Sources(1).Sources(1);
            pSource = testCase.pEXPT.query({'UUID', cSource.UUID});

            testCase.verifyEqual(pSource.Name, cSource.Name);
            testCase.verifyEqual(pSource.micronsPerDegree, cSource.micronsPerDegree);
            test.util.verifyAttributesEqual(testCase,...
                pSource.attributes, cSource.attributes)
        end

        function RegistrationProperties(testCase)
            test.util.verifyDatesEqual(testCase,...
                testCase.cEXPT.Epochs(1).Registrations(1).registrationDate,...
                testCase.pEXPT.Epochs(1).Registrations(1).registrationDate);
            testCase.verifyEqual(...
                testCase.cEXPT.Epochs(1).Registrations.tform,... 
                testCase.pEXPT.Epochs(1).Registrations.tform);
        end
    end
end