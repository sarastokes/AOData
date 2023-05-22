classdef ImageJRoiReader < aod.common.FileReader
% IMAGEJROIREADER
%
% Description:
%   Wrapper for ImageJ ROI import functions with improvements to polygon
%   ROI import
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
% Quick data access:
%   data = aod.builtin.readers.ImageJROIReader.read(fullFilePath, imSize)
%
% Notes:
%   Mixed polygon and oval ROIs not supported. 
%
% See also:
%   roiImportImageJ, ReadImageJROI, ROIs2Regions, poly2mask

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        Size (1,2)          {mustBeInteger}
    end

    methods
        function obj = ImageJRoiReader(fileName, imSize)
            obj@aod.common.FileReader(fileName);
            obj.Size = imSize;
        end

        function out = readFile(obj)
            sROI = ReadImageJROI(obj.fullFile);

            if strcmp(sROI{1}.strType, 'Polygon')
                regions = struct();
                regions.Connectivity = 8; 
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