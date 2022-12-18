classdef JsonReader < aod.util.FileReader
% Read a JSON file
%
% Description:
%   Basis for reading in JSON files
%
% Parent:
%   aod.util.FileReader
%
% Constructor:
%   obj = aod.util.readers.JsonReader(fName)
%
% See Also:
%   loadjson

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    methods
        function obj = JsonReader(varargin)
            obj = obj@aod.util.FileReader(varargin{:});
        end

        function out = readFile(obj)
            out = loadjson(obj.fullFile);
            obj.Data = out;
        end
    end

    methods (Static)
        function out = read(varargin)
            obj = aod.util.readers.JsonReader(varargin{:});
            out = obj.readFile();
        end
    end
end