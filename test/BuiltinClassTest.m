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

    properties
        dataFolder
    end

    methods (TestClassSetup)
        function setup(testCase)
            testCase.dataFolder = fullfile(...
                test.util.getAODataTestFolder(), 'test_data');
        end
    end

    methods (Test, TestTags = {'Devices'})
        function Pinhole(testCase) 
            obj = aod.builtin.devices.Pinhole(25,... 
                "Manufacturer", "ThorLabs", "Model", "P20K"); 
            obj.setDiameter(20);
            paramValue = getAttr(obj, 'Diameter');
            testCase.verifyEqual(paramValue, 20);
        end

        function PMT(testCase) 
            obj = aod.builtin.devices.PMT('VisiblePMT',...
                "Manufacturer", "Hamamatsu", "Model", "H16722");
        end

        function LightSource(testCase)
            obj = aod.builtin.devices.LightSource(488,...
                "SerialNumber", "123A");
            obj.setSpectra([1:10; 11:20]);
        end

        function Beamsplitter(testCase)
            obj = aod.builtin.devices.Beamsplitter([30, 70]);
            testCase.verifyEqual(obj.getAttr('SplittingRatio'), [30 70]);
            testCase.verifyEqual(obj.label, "30:70Beamsplitter");

            obj.setReflectance([300:700; randn(1, numel(300:700))]');
            testCase.verifySize(obj.reflectance, [numel(300:700), 2]);
        end

        function Pellicle(testCase)
            obj = aod.builtin.devices.Pellicle([30, 70]);
            testCase.verifyEqual(obj.getAttr('SplittingRatio'), [30 70]);
            testCase.verifyEqual(obj.label, "30:70Pellicle");

            value = [300:700, randn(1, numel(300:700))]';
            obj.setTransmission(value);
            testCase.verifyEqual(obj.transmission, value);
        end

        function DichroicFilter(testCase)
            obj = aod.builtin.devices.DichroicFilter(470, "high",...
                "Manufacturer", "Semrock", "Model", "FF470-Di01");
            obj.setTransmission(sara.resources.getResource('FF470_Di01.txt'));
        end

        function NDF(testCase)
            obj = aod.builtin.devices.NeutralDensityFilter(0.6,...
                "Manufacturer", "ThorLabs", "Model", "NE06A-A");
            obj.setTransmission([400:700; zeros(size(400:700))]');
            testCase.verifyTrue(strcmp(obj.label, '0.6NDF'));
        end

        function BandpassFilter(testCase)
            obj = aod.builtin.devices.BandpassFilter(590, 20,...
                "Manufacturer", "Semrock", "Model", "FF01-590/20");
            obj.setTransmission(sara.resources.getResource('FF01-590_20.txt'));
        end
    end

    methods (Test, TestTags = {'Calibrations'})
        function MeasurementTable(testCase)
            obj = aod.builtin.calibrations.MeasurementTable( ...
                "Power", getDateYMD(),...
                ["Mustang", "Value"], ["%", "microwatts"]);
            testCase.verifyTrue(isempty(obj));
            testCase.verifyEqual(...
                obj.Measurements.Properties.VariableNames, ...
                cellstr(["Mustang", "Value"]));

            obj.addMeasurements({22, 10}, {28, 17});
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
                "addMeasurements:InvalidInput");
        end

        function RoomMeasurement(testCase)
            obj = aod.builtin.calibrations.RoomMeasurement(getDateYMD());
            % Add a first measurement
            obj.addMeasurements({"11:45", 71.1, 28});
            testCase.verifyEqual(size(obj.Measurements), [1 3]);
            % Append a measurement
            obj.addMeasurements({"12:20", 71.2, 28});
            testCase.verifyEqual(size(obj.Measurements), [2 3]);
        end
    end

    methods (Test, TestTags=["Calibration", "ChannelOptimization"])
        function ChannelOptimization(testCase)
            obj = aod.builtin.calibrations.ChannelOptimization(...
                'Mustang', getDateYMD());
            obj.setWavelength(488);
            obj.setPositions(true, 'X', 1, 'Y', 2, 'Z', 3, 'Source', 4);
            testCase.verifyEqual(obj.getAttr('Wavelength'), 488);
            testCase.verifyEqual(obj.positions{1,1}, 1);
            
            obj.setPositions(false, 'X', 2, 'Y', 2);
            testCase.verifyEqual(obj.positions{2,2}, 2);

            obj.setPositions(true, 'Source', []);
            testCase.verifyTrue(isnan(obj.positions{1,4}));

            obj.setIterations(eye(3));
            testCase.verifyEqual(obj.iterations, eye(3));

        end

        function ChannelOptimizationErrors(testCase)
        
            obj = aod.builtin.calibrations.ChannelOptimization(...
                'Mustang', getDateYMD());
            testCase.verifyError(...
                @()obj.setAttr('Wavelength', 'badinput'),...
                'validate:Failed');
            testCase.verifyError(...
                @()obj.setIterations("badInput"),...
                "validate:Failed");
        end
    end

    methods (Test, TestTags = {'Registrations'})
        function RigidRegistration(testCase)
            obj = aod.builtin.registrations.RigidRegistration(...
                'SIFT', "2022-08-22", eye(3));
            testCase.verifyClass(obj.affine2d_to_3d(eye(3)), 'affine3d');
            testCase.verifyClass(obj.affine2d_to_3d(affine2d(eye(3))), 'affine3d');

            obj.setReference(1);
            testCase.verifyEqual(obj.reference, 1);
        end

        function RigidRegistrationErrors(testCase)
            testCase.verifyError(...
                @() aod.builtin.registrations.RigidRegistration('Reg', getDateYMD(), [2 2; 2 2]),...
                "RigidRegistration:IncorrectSize");

            obj = aod.builtin.registrations.RigidRegistration(...
                'SIFT', "2022-08-22", eye(3));
            testCase.verifyError(...
                @()obj.apply(zeros(3,3,3)), "Apply:NotYetImplemented");
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

            fPath = fullfile(test.util.getAODataTestFolder(), 'test_data');
            obj.loadData(fPath, 3);
            testCase.verifyTrue(obj.hasFile('RegistrationOutput'));

            obj.loadParameters(fPath, 3);
            testCase.verifyTrue(obj.hasFile('RegistrationParameters'));

            testCase.verifyError(...
                @() obj.apply(zeros(3,3,3)), "StripRegistration:AlreadyApplied")
        end
    end

    methods (Test, TestTags = {'Stimuli'})
        function ImagingLight(testCase)
            obj = aod.builtin.stimuli.ImagingLight('Mustang', 22);
            testCase.verifyEqual(obj.intensity, 22);
            obj.setIntensity(23);
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
                'ContactLens', [12.2, 5.8, 0],...
                'PupilSize', 6.7);
            obj.add(obj2);
        end
    end 

    methods (Test, TestTags={'Annotations'})
        function Rois(testCase)
            data = zeros(360, 242);
            counter = 0;
            for i = 100:5:200
                counter = counter+1;
                data(i,i-1:i) = counter;
            end
            im = randi([1 400], 360, 242);
            obj = aod.builtin.annotations.Rois('851_OSR_20220823', data,...
                'Size', [360, 242], 'Image', im);
            testCase.verifyEqual(obj.numRois, 21);
            testCase.verifyEqual(obj.Data, data);
            testCase.verifyEqual(obj.Image, im);
        end

        function RoisFromReader(testCase)
            reader = aod.builtin.readers.ImageJRoiReader(...
                fullfile(testCase.dataFolder, 'RoiSet.zip'), [242, 360]);
            obj = aod.builtin.annotations.Rois('851_OSR_20230314',  reader,...
                'Source', aod.core.Source('RoiSource'));
            testCase.verifyEqual(obj.files('AnnotationData'), reader.fullFile);
            testCase.verifyEqual(obj.Source.Name, "RoiSource");
        end

        function RoiErrors(testCase)
            testCase.verifyError(...
                @() aod.builtin.annotations.Rois('ErrorROIs', fullfile(testCase.dataFolder, 'RoiSet.zip')),...
                'findFileReader:UnknownExtension');
        end
    end

    methods (Test, TestTags=["Readers"])
        function RegistrationParameterReader(testCase)
            obj = aod.builtin.registrations.StripRegistration([], "2022-03-14");

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