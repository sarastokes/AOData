classdef ProtocolTest < matlab.unittest.TestCase 
% Tests the Protocol utility and interaction with the experiment heirarchy
%
% Parent:
%   matlab.unittest.TestCase
%
% Use:
%   result = runtests('ProtocolTest')
%
% See also:
%   runAODataTestSuite, aod.common.Protocol

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    methods (Test, TestTags = ["Protocol"])
        function DateCreated(testCase)
            protocol1 = test.TestStimProtocol([],...
                'PreTime', 5, 'StimTime', 5, 'TailTime', 5,...
                'BaseIntensity', 0, 'Contrast', 1);
            test.util.verifyDatesEqual(testCase, protocol1.DateCreated, getDateYMD());
        end

        function BaseMethods(testCase)
            % Make a protocol
            protocol1 = test.TestStimProtocol([],...
                'PreTime', 5, 'StimTime', 5, 'TailTime', 5,...
                'BaseIntensity', 0.5, 'Contrast', 1);

            % The stimRate was twice the sampleRate
            testCase.verifyEqual(protocol1.totalPoints, 2*protocol1.totalSamples);
            
            % The stimulus should match stimRate, not sampleRate
            stim = protocol1.generate();
            testCase.verifyEqual(numel(stim), protocol1.totalPoints);
            testCase.verifyEqual(max(stim), 1);

            % Default mapToStimulator returns output of generate
            testCase.verifyEqual(protocol1.mapToStimulator(), stim);
        end

        function Equality(testCase)
            % Two identical protocols with no calibrations
            protocol1 = test.TestStimProtocol([],...
                'PreTime', 5, 'StimTime', 5, 'TailTime', 5,...
                'BaseIntensity', 0.5, 'Contrast', 1);
            
            protocol2 = test.TestStimProtocol([],...
                'PreTime', 5, 'StimTime', 5, 'TailTime', 5,...
                'BaseIntensity', 0.5, 'Contrast', 1);

            % Compare identical protocols
            testCase.verifyEqual(protocol1, protocol2);
            % Compare protocol with another class
            testCase.verifyNotEqual(protocol1, 123);
            
            % Change the date
            protocol2.DateCreated = getDateYMD('20221122');
            testCase.verifyNotEqual(protocol1, protocol2);

            % Restore date, add a calibration
            protocol2.DateCreated = getDateYMD();
            protocol2.setCalibration(aod.core.Calibration('TestCalibration'));
            testCase.verifyNotEqual(protocol1, protocol2);

            % Compare protocols with different attributes
            protocol3 = test.TestStimProtocol([],...
                'PreTime', 6, 'StimTime', 5, 'TailTime', 5,...
                'BaseIntensity', 0.5, 'Contrast', 1);
            testCase.verifyNotEqual(protocol1, protocol3);
        end

        function Errors(testCase)
            protocol1 = test.TestStimProtocol([],...
                'PreTime', 5, 'StimTime', 5, 'TailTime', 5,...
                'BaseIntensity', 0.5, 'Contrast', 1);
            testCase.verifyError(@()protocol1.setCalibration(123),...
                'MATLAB:class:NoConversionDefined');
        end

        function StimVsFrameRates(testCase)
            % Sample rate = 25, stimRate = 50
            protocol1 = test.TestStimProtocol([],...
                'PreTime', 5, 'StimTime', 5, 'TailTime', 5,...
                'BaseIntensity', 0.5, 'Contrast', 1);
            testCase.verifyEqual(protocol1.pts2sec(50), 1);
            testCase.verifyEqual(protocol1.samples2pts(2), 4);
        end

        function ContrastVsIntensity(testCase)
            % Make two protocols
            protocol1 = test.TestStimProtocol([],...
                'PreTime', 5, 'StimTime', 5, 'TailTime', 5,...
                'BaseIntensity', 0.5, 'Contrast', 1);
            protocol2 = test.TestStimProtocol([],...
                'PreTime', 5, 'StimTime', 5, 'TailTime', 5,...
                'BaseIntensity', 0, 'Intensity', 0.75);

            % Contrast vs intensity specification
            testCase.verifyEqual(protocol1.amplitude, 0.5);
            testCase.verifyEqual(protocol2.amplitude, 0.75);
        end
    end
end 