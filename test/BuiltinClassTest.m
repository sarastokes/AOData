classdef BuiltinClassTest < matlab.unittest.TestCase
% Test the aod.builtin package
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

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

%#ok<*MANU>  
%#ok<*NASGU>

    methods (Test, TestTags = {'Devices'})
        function Pinhole(testCase) 
            obj = aod.builtin.devices.Pinhole(25,... 
                'Manufacturer', "ThorLabs", 'Model', "P20K"); 
            obj.setDiameter(20);
            paramValue = getAttr(obj, 'Diameter');
            testCase.verifyEqual(paramValue, 20);
        end

        function PMT(testCase) 
            obj = aod.builtin.devices.PMT('VisiblePMT',...
                'Manufacturer', "Hamamatsu", 'Model', "H16722");
        end

        function LightSource(testCase)
            obj = aod.builtin.devices.LightSource(488,...
                'SerialNumber', "123A");
            obj.setSpectra([1:10; 11:20]);
        end

        function DichroicFilter(testCase)
            obj = aod.builtin.devices.DichroicFilter(470, 'high',...
                'Manufacturer', "Semrock", 'Model', "FF470-Di01");
            obj.setTransmission(sara.resources.getResource('FF470_Di01.txt'));
        end

        function NDF(testCase)
            obj = aod.builtin.devices.NeutralDensityFilter(0.6,...
                'Manufacturer', "ThorLabs", 'Model', "NE06A-A");
            obj.setTransmission([400:700; zeros(size(400:700))]);
            testCase.verifyTrue(strcmp(obj.label, '0.6NDF'));
        end

        function BandpassFilter(testCase)
            obj = aod.builtin.devices.BandpassFilter(590, 20,...
                'Manufacturer', "Semrock", 'Model', "FF01-590/20");
            obj.setTransmission(sara.resources.getResource('FF01-590_20.txt'));
        end
    end

    methods (Test, TestTags = {'Calibrations'})
        function MeasurementTable(testCase)
            obj = aod.builtin.calibrations.MeasurementTable( ...
                "Power", getDateYMD(),...
                ["Mustang", "Value"], ["%", "microwatts"]);
            testCase.verifyEqual(obj.numMeasurements, 0);
            testCase.verifyTrue(isempty(obj));
            testCase.verifyEqual(...
                obj.Measurements.Properties.VariableNames, ...
                cellstr(["Mustang", "Value"]));

            obj.addMeasurements({22, 10}, {28, 17});
            testCase.verifyEqual(obj.numMeasurements, 2);
            testCase.verifySize(obj.table(), [2 2]);

            % Remove measurements
            obj.removeMeasurements(1);
            testCase.verifySize(obj.table(), [1 2]);
        end

        function MeasurementTableErrors(testCase)
            obj = aod.builtin.calibrations.MeasurementTable(...
                "Power", getDateYMD(), ["Mustang", "Value"]);
            testCase.verifyError(...
                @() obj.addMeasurements(123),...
                "addMeasurement:InvalidInput");
        end

        function RoomMeasurement(testCase)
            obj = aod.builtin.calibrations.RoomMeasurement(getDateYMD());
            % Add a first measurement
            obj.addMeasurement("11:45", 71.1, 28);
            testCase.verifyEqual(size(obj.measurements), [1 3]);
            % Append a measurement
            obj.addMeasurement("12:20", 71.2, 28);
            testCase.verifyEqual(size(obj.measurements), [2 3]);
        end
    end

    methods (Test, TestTags = {'Registrations'})
        function RigidRegistration(testCase)
            obj = aod.builtin.registrations.RigidRegistration(...
                'SIFT', '20220822', eye(3));
            testCase.verifyClass(obj.affine2d_to_3d(eye(3)), 'affine3d');
            testCase.verifyClass(obj.affine2d_to_3d(affine2d(eye(3))), 'affine3d');
        end

        function RigidRegistrationErrors(testCase)
            testCase.verifyError(...
                @() aod.builtin.registrations.RigidRegistration('Reg', getDateYMD(), [2 2; 2 2]),...
                "RigidRegistration:IncorrectSize");
        end

        function RigidRegistrationApply(testCase)
            tform = affine2d([2 0 0; 0.33 1 0; 0 0 1]);
            I = imread('pout.tif');
            refObj = imref2d(size(I));
            J = imwarp(I, refObj, tform, ...
                'OutputView', refObj, 'SmoothEdges', true);

            % Make pseudovideo
            V = cat(3, I, I, I);

            obj = aod.builtin.registrations.RigidRegistration( ...
                'Reg', getDateYMD(), tform);
            out = obj.apply(I, 'SmoothEdges', true);
            testCase.verifyEqual(out, J);
            testCase.verifyTrue(obj.hasAttr('SmoothEdges'));
        end

        function StripRegistration(testCase)
            obj = aod.builtin.registrations.StripRegistration([]);
        end
    end

    methods (Test, TestTags = {'Stimuli'})
        function ImagingLight(testCase)
            obj = aod.builtin.stimuli.ImagingLight('Mustang', 22,...
                'IntensityUnits', "%");
            testCase.verifyEqual(obj.intensity, 22);
            obj.setIntensity(23, "%");
            testCase.verifyEqual(obj.intensity, 23);
        end

        function VisualStimulus(testCase)
            protocol = test.TestStimProtocol([],...
                'PreTime', 5, 'StimTime', 5, 'TailTime', 5,...
                'BaseIntensity', 0.5, 'Contrast', 1);
            obj = aod.builtin.stimuli.VisualStimulus(protocol);
            testCase.verifyTrue(strcmp(obj.label, 'TestStimProtocol'));
        end
    end

    methods (Test, TestTags = {'Sources'})
        function ModelEye(testCase)
            obj = aod.builtin.sources.ModelEye();
        end

        function PrimateHierarchy(testCase)
            obj = aod.builtin.sources.primate.Primate('MC00851',...
                'Species', "macaca nemestrina", 'Sex', "male",...
                'Demographics', "GCaMP6s, Rhodamine");
            testCase.verifyEqual(obj.ID, 851);

            obj2 = aod.builtin.sources.primate.Eye('OS',...
                'AxialLength', 16.56,... 
                'ContactLens', "5.8mm/12.2mm/plano",...
                'PupilSize', 6.7);
            obj.add(obj2);
        end
    end 

    methods (Test, TestTags={'Annotations'})
        function Rois(testCase)
            data = randi([1 400], 360, 242);
            obj = aod.builtin.annotations.Rois('851_OSR_20220823',...
                data, 'Size', [360, 242]);
            testCase.verifyEqual(obj.numRois, numel(unique(data(:))));
        end
    end

    methods (Test, TestTags=["Readers"])
        function RegistrationParameterReader(testCase)
            obj = aod.builtin.registrations.StripRegistration([], "20220314");

            reader = aod.builtin.readers.RegistrationParameterReader(...
                fullfile(test.util.getAODataTestFolder(), "test_data",... 
                    "851_20230314_ref_0003_20230314_params_ref000_001.txt"));
            out = reader.readFile();
            testCase.verifyTrue(strcmp(out.System,...
                "nVidia GPU: NVIDIA GeForce GTX 1660"));
            testCase.verifyEqual(out.StripSaveVideo, true);
            testCase.verifyEqual(out.NccLinesToIgnore, 50);
        end
    end
end 