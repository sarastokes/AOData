classdef AviReader < aod.common.FileReader
% Read an AVI file
%
% Description:
%   Reads in AVI files
%
% Parent:
%   aod.common.FileReader
%
% Constructor:
%   obj = aod.util.readers.AviReader(fName)

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------


    methods
        function obj = AviReader(fileName)
            obj = obj@aod.common.FileReader(fileName);
        end

        function out = readFile(obj)
            obj.Data = video2stack(obj.fullFile);
            out = obj.Data;
        end
    end

    methods (Static)
        function out = read(varargin)
            obj = aod.util.readers.AviReader(varargin{:});
            out = obj.readFile();
        end
    end
end