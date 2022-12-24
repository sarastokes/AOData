classdef TiffReader < aod.util.FileReader
% Reads .tiff files
%
% Description:
%   Reads in TIFF files
%
% Parent:
%   aod.util.FileReader
%
% Constructor:
%   obj = aod.util.readers.TiffReader(fName)

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    methods
        function obj = TiffReader(fileName)
            obj = obj@aod.util.FileReader(fileName);
        end

        function out = readFile(obj)
            obj.Data = obj.loadTiff(obj.fullFile);
            
            imInfo = imfinfo(fileName);
            dType = sprintf('uint%u', imInfo(1).BitDepth);
            nFrames = size(imfinfo(fileName));
            
            out = zeros(imInfo(1).Height, imInfo(1).Width, dType);
        
            for i = 1:nFrames
                out(:,:,i) = imread(fileName, 'Index', i);
            end
            obj.Data = out;
        end
    end

    methods (Static)
        function out = read(varargin)
            obj = aod.util.readers.TiffReader(varargin{:});
            out = obj.readFile();
        end
    end
end