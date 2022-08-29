classdef RegistrationParameterReader < aod.core.readers.TxtReader 
% REGISTRATIONPARAMETERREADER
%
% Description:
%   Creates a struct containing all strip registration parameters
%
% Parent:
%   aod.core.readers.TxtReader
%
% Syntax:
%   obj = RegistrationParameterReader(fileName)
%
% See also:
%   aod.builtin.registrations.StripRegistration
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        registrationDate 
    end

    methods
        function obj = RegistrationParameterReader(fName)
            obj@aod.core.readers.TxtReader(fName);

            % Try to extract date from fName
            obj.extractDate();
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
            out.RefImageName = obj.readText('Run video with a reference image name:');
            out.Rotate90Degrees = obj.readYesNo('Run video rotating 90 degrees:');
            out.Desinusoid = obj.readYesNo('Run video with desinusoiding:');
            obj.Data = out;
        end

        function extractDate(obj)
            % EXTRACTDATE
            %
            %   Assumes there are two dates in file name and second is the
            %   date the file was registered
            % -------------------------------------------------------------
            matches = extract(obj.Name, digitsPattern(8));
            if numel(matches) == 2
                obj.registrationDate = matches{2};
            end
        end
    end

    methods (Static)
        function obj = init(folderPath, ID)
            arguments
                folderPath      {mustBeFolder}
                ID              {mustBeInteger}
            end

            files = ls(folderPath);
            files = deblank(string(files));
            files = multicontains(files, {'params', '.txt'});
            [~, idx] = extractMatches(files,... 
                digitBoundary + int2fixedwidthstr(ID, 4) + digitBoundary);

            if isempty(idx)
                error('File for ID %u not found in %s!', ID, folderPath);
            elseif numel(idx) > 1 
                warning('Epoch %u - %u registration files found! Using last',... 
                    ID, numel(idx));
                disp(files(idx));
                idx = idx(end);
            end
            
            obj = aod.builtin.readers.RegistrationParameterReader(...
                fullfile(folderPath, char(files(idx))));
        end
    end
end