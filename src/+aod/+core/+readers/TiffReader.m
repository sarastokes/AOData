classdef TiffReader < aod.core.FileReader

    methods
        function obj = TiffReader(varargin)
            obj = aod.core.FileReader(varargin{:});
            obj.validExtensions = {'*.tif', '*.tiff'};
        end

        function out = read(obj)
            obj.Data = loadTiff(obj.fullFile);
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