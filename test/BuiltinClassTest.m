classdef BuiltinClassTest < matlab.unittest.TestCase
% BUILTINCLASSTEST
%
% Description:
%   Tests instantiation of builtin classes
%
% Parent:
%   matlab.unittest.TestCase
%
% Example:
%   results = runtests('BuiltinCassTest.m')
%
% See also:
%   runAODataTestSuite
% -------------------------------------------------------------------------

    methods (Test, TestTags = {'Devices'})
        function testPinhole(testCase) %#ok<*MANU> 
            obj = aod.builtin.devices.Pinhole(25,... 
                'Manufacturer', 'ThorLabs', 'Model', 'P20K'); %#ok<*NASGU> 
            obj.setDiameter(20);
            paramValue = getParam(obj, 'Diameter');
            testCase.verifyEqual(paramValue, 20);

            obj.setDiameterUnits('m');
            paramValue = getParam(obj, 'DiameterUnits');
            testCase.verifyEqual(paramValue, 'm');
        end

        function testLightSource(testCase)
            obj = aod.builtin.devices.PMT('VisiblePMT',...
                'Manufacturer', 'Hamamatsu', 'Model', 'H16722');
        end

        function testDichroicFilter(testCase)
            obj = aod.builtin.devices.DichroicFilter(470, 'high',...
                'Manufacturer', 'Semrock', 'Model', 'FF470-Di01');
            obj.setTransmission(sara.resources.getResource('FF470_Di01.txt'));
        end

        function testNDF(testCase)
            obj = aod.builtin.devices.NeutralDensityFilter(0.6,...
                'Manufacturer', 'ThorLabs', 'Model', 'NE06A-A');
            obj.setTransmission([400:700; zeros(size(400:700))]);
        end

        function testBandpassFilter(testCase)
            obj = aod.builtin.devices.BandpassFilter(590, 20,...
                'Manufacturer', 'Semrock', 'Model', 'FF01-590/20');
            obj.setTransmission(sara.resources.getResource('FF01-590_20.txt'));
        end
    end

    methods (Test, TestTags = {'Calibrations'})
        function testRoomMeasurement(testCase)
            obj = aod.builtin.calibrations.RoomMeasurement(getDateYMD());
            obj.addMeasurement("11:45", 71.1, 28);
            testCase.verifyEqual(size(obj.measurements), [1 3]);
        end
    end

    methods (Test, TestTags = {'Registrations'})

        function testRigidRegistration(testCase)
            obj = aod.builtin.registrations.RigidRegistration(...
                'SIFT', '20220822', eye(3));
        end

        function testStripRegistration(testCase)
            obj = aod.builtin.registrations.StripRegistration(...
                [], [], false);
        end
    end

    methods (Test, TestTags = {'Stimuli'})
        function testImagingLight(testCase)
            obj = aod.builtin.stimuli.ImagingLight('Mustang', 22, '%');
        end
    end

    methods (Test, TestTags = {'Protocols'})
        function testContrastProtocol(testCase)
            % Make two protocols
            protocol1 = test.TestProtocol(...
                'PreTime', 5, 'StimTime', 5, 'TailTime', 5,...
                'BaseIntensity', 0.5, 'Contrast', 1);
            protocol2 = test.TestProtocol(...
                'PreTime', 5, 'StimTime', 5, 'TailTime', 5,...
                'BaseIntensity', 0, 'Intensity', 0.75);

            % The stimRate was twice the sampleRate
            testCase.verifyEqual(protocol1.totalPoints, 2*protocol1.totalSamples);
            
            % The stimulus should match stimRate, not sampleRate
            stim = protocol1.generate();
            testCase.verifyEqual(numel(stim), protocol1.totalPoints);
            testCase.verifyEqual(max(stim), 1);

            % Contrast vs intensity specification
            testCase.verifyEqual(protocol1.amplitude, 0.5);
            testCase.verifyEqual(protocol2.amplitude, 0.75);
        end
    end

    methods (Test, TestTags = {'Sources'})
        function testModelEye(testCase)
            obj = aod.builtin.sources.ModelEye();
        end

        function testPrimateHierarchy(testCase)
            obj = aod.builtin.sources.primate.Primate('MC00851',...
                'Species', 'macaque', 'Sex', 'male',...
                'Demographics', 'GCaMP6s, Rhodamine');
            testCase.verifyEqual(obj.ID, 851);

            obj2 = aod.builtin.sources.primate.Eye('OS',...
                'AxialLength', 16.56, 'ContactLens', '5.8mm/12.2mm/plano',...
                'PupilSize', 6.7);
            obj.add(obj2);
        end
    end 

    methods (Test, TestTags={'Segmentations'})
        function testRois(testCase)
            obj = aod.builtin.segmentations.Rois('851_OSR_20220823',...
                randn(360, 242), 'Size', [360, 242]);
        end
    end
end 