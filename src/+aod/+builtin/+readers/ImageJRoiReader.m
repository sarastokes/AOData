classdef ImageJRoiReader < aod.util.FileReader
% IMAGEJROIREADER
%
% Description:
%   Wrapper for ImageJ ROI import functions with improvements to
%   polygon ROI processing
%
% Syntax:
%   obj = aod.builtin.readers.ImageJRoiReader(fullFilePath, imSize)
%
% Inputs:
%   filePath    char
%       Location and name of .roi or .zip file(s)
%   imSize      vector [1 x 2]
%       Image X and Y dimensions
%
% See also:
%   roiImportImageJ, ReadImageJROI, ROIs2Regions, poly2mask

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        Size (1,2)          {mustBeInteger}
    end

    methods
        function obj = ImageJRoiReader(fileName, imSize)
            obj@aod.util.FileReader(fileName);
            obj.Size = imSize;
        end

        function out = readFile(obj)
            sROI = ReadImageJROI(obj.fullFile);

            if strcmp(sROI{1}.strType, 'Polygon')
                regions.Connectivity = 8; %#ok<*PROP> 
                regions.ImageSize = fliplr(obj.Size);
                regions.NumObjects = numel(sROI);
                regions.PixelIdxList = {};

                for i = 1:numel(sROI)
                    roi = sROI{i};
                    mbThisMask = poly2mask(roi.mnCoordinates(:, 1)+1, ...
                        roi.mnCoordinates(:, 2)+1, obj.Size(2), obj.Size(1));
                    regions.PixelIdxList{i} = find(mbThisMask);
                end
                obj.Data = labelmatrix(regions);
            else
                regions = ROIs2Regions(sROI, obj.Size);
                obj.Data = labelmatrix(regions)';
            end
            out = obj.Data;
        end
    end

    methods (Static)
        function out = read(fileName, imSize)
            obj = aod.builtin.readers.ImageJRoiReader(fileName, imSize);
            out = obj.readFile();
        end
    end
end