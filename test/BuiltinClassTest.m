classdef BuiltinClassTest < matlab.unittest.TestCase

    methods (Test)
        % DEVICES ---------------------------------------------------------
        function testPinhole(testCase)
            obj = aod.builtin.devices.Pinhole(25,... 
                'Manufacturer', 'ThorLabs', 'Model', 'P20K');
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
        end

        function testBandpassFilter(testCase)
            obj = aod.builtin.devices.BandpassFilter(590, 20,...
                'Manufacturer', 'Semrock', 'Model', 'FF01-590/20');
            obj.setTransmission(sara.resources.getResource('FF01-590_20.txt'));
        end

        % REGISTRATIONS ---------------------------------------------------
        function testRigidRegistration(testCase)
            obj = aod.builtin.registrations.RigidRegistration(...
                'SIFT', '20220822', eye(3));
        end

        function testStripRegistration(testCase)
            obj = aod.builtin.registrations.StripRegistration(...
                [], [], false);
        end

        % STIMULI ----------------------------------------------------------
        function testImagingLight(testCase)
            obj = aod.builtin.stimuli.ImagingLight('Mustang', 22, '%');
        end

        % SOURCES ----------------------------------------------------------
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
            obj.addSource(obj2);
        end

        % REGIONS ---------------------------------------------------------
        function testRois(testCase)
            obj = aod.builtin.regions.Rois('851_OSR_20220823',...
                randn(360, 242), 'Size', [360, 242]);
        end
    end
end 