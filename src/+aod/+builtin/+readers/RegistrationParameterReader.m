classdef RegistrationParameterReader < aod.core.FileReader 
% REGISTRATIONPARAMETERREADER
%
% Description:
%   Creates a struct containing all strip registration parameters
%
% See also:
%   aod.builtin.registrations.StripRegistration
% -------------------------------------------------------------------------

    methods
        function obj = RegistrationParameterReader(fName)
            obj@aod.core.FileReader(fName);
        end

        function out = read(obj)
            out = struct();
            out.FilteringOption = obj.readText('Filtering option:');
            out.System = obj.readText('Algorithm runs on:');
            out.NccLinesToIgnore = obj.readNumber('NCC lines to ignore:');
            out.FrameMaxMotion = obj.readNumber('Frame-level maximum motion:');
            out.FrameRegOnly = obj.readYesNo('Frame-level registration only:');

            out.NccRowsToIgnore = obj.readNumber('NCC rows to ignore:');
            out.NccColumnsToIgnore = obj.readNumber('NCC columns to ignore:');
            out.StripNumber = obj.readNumber('Number of strips for registration:');
            out.StripHeight = obj.readNumber('Strip height for registration:');
            
            out.StripMaxMotion = obj.readNumber('Strip-level maximum motion:');
            out.StripSaveVideo = obj.readYesNo('Strip-level save video:');
            out.StripSaveFullVideo = obj.readYesNo('Frame-level save video:');

            out.MinCroppingFlag = obj.readText('Minimum cropping flag:');
            out.MinCroppingValue = obj.readNumber('Minimum cropping value:');
            out.NccCorrelationThreshold = obj.readNumber('NCC correlation threshold:');

            out.VideoFrameStart = obj.readNumber('Run video frames from #:');
            out.VideoFrameStop = obj.readNumber('Run video frames to #');
            out.RefFrameNumber = obj.readNumber('Run video frames with reference #:');
            out.AutoRef = obj.readYesNo('Run video with automatic reference:');
            out.RefImage = obj.readYesNo('Run video with a reference image:');
            out.RefImageName = obj.readText('Run video with reference image name:');
            out.Rotate90Degrees = obj.readYesNo('Run video rotating 90 degrees:');
            out.Desinusoid = obj.readYesNo('Run video with desinusoiding:');
            obj.Data = out;
        end
    end

    methods (Access = private)
        function out = readText(obj, header)
            out = removeTabs(readProperty(obj.fullFile, header));
        end

        function out = readNumber(obj, header)
            out = str2double(removeTabs(readProperty(obj.fullFile, header)));
        end

        function out = readYesNo(obj, header)
            out = convertYesNo(removeTabs(readProperty(obj.fullFile, header)));
        end
    end
end