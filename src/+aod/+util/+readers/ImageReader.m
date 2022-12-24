classdef ImageReader < aod.util.FileReader 
% Reads an image 
%
% Constructor:
%   aod.util.readers.ImageReader(fName)
%
% Supported file formats:
%   .jpeg, .png, .bmp
%
% See Also:
%   imread

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    methods
        function obj = ImageReader(varargin)
            obj@aod.util.FileReader(varargin{:});
        end
        
        function out = readFile(obj)
            obj.Data = imread(obj.fullFile);
            out = obj.Data;
        end
    end

    methods (Static)
        function out = read(varargin)
            obj = aod.util.readers.ImageReader(varargin{:});
            out = obj.readFile();
        end
    end
end 