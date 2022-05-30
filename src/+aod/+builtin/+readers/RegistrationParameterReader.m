classdef RegistrationParameterReader < aod.core.FileReader 

    methods
        function obj = RegistrationParameterReader(fName)
            obj@aod.core.FileReader(fName);
        end

        function out = read(obj)
            out = cell.empty();
            out = cat(2, out, 'FilteringOption',...
                removeTabs(readProperty(obj.fullFile, 'Filtering Option:')));
            out = cat(2, out, 'System',...
                removeTabs(readProperty(obj.fullFile, 'Algorithm runs on:')));
            out = cat(2, out, 'NccLinesToIgnore', obj.readNumber('NCC lines to ignore:'));
            out = cat(2, out, 'FrameMaxMotion',obj.readNumber('Frame-level maximum motion:'));
            frameRegOnly = convertYesNo(removeTabs(readProperty(obj.fullFile, 'Frame-level registration only:')));
            out = cat(2, out, 'FrameRegOnly', frameRegOnly);

            out = cat(2, out, 'NccRowsToIgnore', obj.readNumber('NCC rows to ignore:'));
            out = cat(2, out, 'NccColumnsToIgnore', obj.readNumber('NCC columns to ignore:'));
            out = cat(2, out, 'StripNumber',...
                str2double(removeTabs(readProperty(obj.fullFile, 'Number of strips for registration:'))));
            out = cat(2, out, 'StripHeight',...
                str2double(removeTabs(readProperty(obj.fullFile, 'Strip height for registration:'))));
            
            out = cat(2, out, 'StripMaxMotion',...
                str2double(removeTabs(readProperty(obj.fullFile, 'Strip-level maximum motion:'))));
            out = cat(2, out, 'StripSaveVideo',...
                convertYesNo(removeTabs(readProperty(obj.fullFile, 'Strip-level save video:'))));
            out = cat(2, out, 'StripSaveFullVideo',...
                convertYesNo(removeTabs(readProperty(obj.fullFile, 'Frame-level save video:'))));

            out = cat(2, out, 'MinCroppingFlag',...
                removeTabs(readProperty(obj.fullFile, 'Minimum cropping flag:')));
            out = cat(2, out, 'MinCroppingValue',...
                obj.readNumber('Minimum cropping value:'));
            out = cat(2, out, 'NccCorrelationThreshold', obj.readNumber('NCC correlation threshold:'));

            out = cat(2, out, 'VideoFrameStart',...
                obj.readNumber('Run video frames from #:'));
            out = cat(2, out, 'VideoFrameStop',...
                str2double(removeTabs(readProperty(obj.fullFile, 'Run video frames to #'))));
            out = cat(2, out, 'RefFrameNumber',...
                obj.readNumber('Run video frames with reference #:'));
            out = cat(2, out, 'AutoRef',...
                convertYesNo(removeTabs(readProperty(obj.fullFile, 'Run video with automatic reference:'))));
            out = cat(2, out, 'RefImage',...
                convertYesNo(removeTabs(readProperty(obj.fullFile, 'Run video with a reference image:'))));
            out = cat(2, out, 'RefImageName',...
                removeTabs(readProperty(obj.fullFile, 'Run video with reference image name:')));
            out = cat(2, out, 'Rotate90Degrees',...
                convertYesNo(removeTabs(readProperty(obj.fullFile, 'Run video rotating 90 degrees:'))));
            out = cat(2, out, 'Desinusoid',...
                convertYesNo(removeTabs(readProperty(obj.fullFile, 'Run video with desinusoiding:'))));

        end
    end

    methods (Access = private)
        function out = readNumber(obj, header)
            out = str2double(removeTabs(readProperty(obj.fullFile, header)));
        end
    end
end