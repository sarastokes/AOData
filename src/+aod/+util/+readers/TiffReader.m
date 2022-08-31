classdef TiffReader < aod.util.FileReader
% TIFFREADER
%
% Description:
%   Reads in TIFF files
%
% Parent:
%   aod.util.FileReader
%
% Constructor:
%   obj = TiffReader(fName)
% -------------------------------------------------------------------------
    methods
        function obj = TiffReader(varargin)
            obj = obj@aod.util.FileReader(varargin{:});
            obj.validExtensions = {'*.tif', '*.tiff'};
        end

        function out = read(obj)
            obj.Data = obj.loadTiff(obj.fullFile);
            out = obj.Data;
        end
    end

    methods (Static)
        function ts = loadTiff(fileName)
            imInfo = imfinfo(fileName);
            nFrames = size(imfinfo(fileName));
            
            ts = zeros(imInfo(1).Height, imInfo(1).Width, 'uint8');
        
            for i = 1:nFrames
                ts(:,:,i) = imread(fileName, 'Index', i);
            end
        end
    end
end