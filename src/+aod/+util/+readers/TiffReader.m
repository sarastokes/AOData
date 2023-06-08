classdef TiffReader < aod.common.FileReader
% Reads .tiff files
%
% Description:
%   Reads in TIFF files
%
% Parent:
%   aod.common.FileReader
%
% Constructor:
%   obj = aod.util.readers.TiffReader(fName)

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    methods
        function obj = TiffReader(fileName)
            obj = obj@aod.common.FileReader(fileName);
        end

        function out = readFile(obj)
            imInfo = imfinfo(obj.fullFile);
            dType = sprintf('uint%u', imInfo(1).BitDepth);
            nFrames = size(imfinfo(obj.fullFile));
            
            out = zeros(imInfo(1).Height, imInfo(1).Width, dType);
        
            for i = 1:nFrames
                out(:,:,i) = imread(obj.fullFile, 'Index', i);
            end
            out = squeeze(out);
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