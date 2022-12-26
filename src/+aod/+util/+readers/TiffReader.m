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
        function out = read(fileName)
            obj = aod.util.readers.TiffReader(fileName);
            out = obj.readFile();
        end
    end
end