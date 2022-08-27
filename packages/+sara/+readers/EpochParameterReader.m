classdef EpochParameterReader < aod.core.readers.TxtReader 
% EPOCHPARAMETERREADER
%
% Description:
%   Reads epoch parameter files and makes according adjustments to epoch
%
% Parent:
%   aod.core.readers.TxtReader
%
% Syntax:
%   obj = EpochParameterReader(fileName)
% -------------------------------------------------------------------------

    methods
        function obj = EpochParameterReader(varargin)
            obj@aod.core.readers.TxtReader(varargin{:});
        end

        function getFileName(obj, varargin)
            if nargin == 3
                filePath = varargin{1};
                ID = varargin{2};
            end

            files = ls(filePath);
            files = deblank(string(files));
            files = files(contains(files, '.txt'));
            [~, idx] = extractMatches(files,... 
                digitBoundary + int2fixedwidthstr(ID, 4) + digitBoundary);

            obj.Path = filePath;
            if numel(idx) > 1
                files = files(idx);
                % Choose the shortest
                [~, minIdx] = min(strlength(files));
                obj.Name = char(files(minIdx));
            elseif isempty(idx)
                error('File for ID %u not found in %s!', ID, filePath);
            else
                obj.Name = char(files(idx));
            end
        end

        function ep = read(obj, ep)
            txt = obj.readText('Date/Time = ');
            txt = erase(txt, ' (yyyy-mm-dd:hh:mm:ss)');
            ep.setStartTime(datetime(txt, 'InputFormat', 'yyyy-MM-dd HH:mm:ss'));
            
            % Additional file names
            ep.setFile('TrialFile', obj.readText('Trial file name = '));
            txt = strsplit(ep.files('TrialFile'), filesep);
            ep.setParam('StimulusName', txt{end});

            txt = obj.readText('Scanner FOV = ');
            txt = erase(txt, ' (496 lines) degrees');
            txt = strsplit(txt, ' x ');
            ep.setParam('FieldOfView', [str2double(txt{1}), str2double(txt{2})]);

            % Imaging window
            x = obj.readNumber('ImagingWindowX = ');
            y = obj.readNumber('ImagingWindowY = ');
            dx = obj.readNumber('ImagingWindowDX = ');
            dy = obj.readNumber('ImagingWindowDY = ');
            ep.setParam('ImagingWindow', [x y dx dy]);

            
            % Channel parameters
            ep.setParam('RefGain', obj.readNumber('ADC channel 1, gain = '));
            ep.setParam('VisGain', obj.readNumber('ADC channel 2, gain = '));
            ep.setParam('RefOffset', obj.readNumber('ADC channel 1, offset = '));
            ep.setParam('VisOffset', obj.readNumber('ADC channel 2, offset = '));
            ep.setParam('RefPmtGain', obj.readNumber('Reflectance PMT gain  = '));
            ep.setParam('VisPmtGain', obj.readNumber('Fluorescence PMT gain  = '));
            ep.setParam('AOM1', obj.readNumber('AOM_VALUE1 = '));
            ep.setParam('AOM2', obj.readNumber('AOM_VALUE2 = '));
            ep.setParam('AOM3', obj.readNumber('AOM_VALUE3 = '));
        end
    end
end