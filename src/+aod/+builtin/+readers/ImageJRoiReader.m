classdef ImageJRoiReader < aod.util.FileReader
% IMAGEJROIREADER
%
% Description:
%   Wrapper for ImageJ ROI import functions with improvements to
%   polygon ROI processing
%
% Syntax:
%   obj = ImageJRoiReader(fullFilePath, imSize)
%
% Inputs:
%   filePath    char
%       Location and name of .roi or .zip file(s)
%   imSize      vector [1 x 2]
%       Image X and Y dimensions
%
% See also:
%   roiImportImageJ, ReadImageJROI, ROIs2Regions, poly2mask
%
% History:
%   06Nov2020 - SSP
%   07Apr2020 - SSP - Added support for Polygon ROIs
%   28Sep2021 - SSP - Added numRois output
%   19May2022 - SSP - Redesigned as FileReader
% -------------------------------------------------------------------------
    properties (SetAccess = private)
        Size(1,2) {mustBeInteger}
    end

    methods
        function obj = ImageJRoiReader(fullFilePath, imSize)
            obj@aod.util.FileReader(fullFilePath);
            obj.Size = imSize;
        end

        function getFileName(~, varargin)
            error('Not yet implemented');
        end

        function out = read(obj)
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
end