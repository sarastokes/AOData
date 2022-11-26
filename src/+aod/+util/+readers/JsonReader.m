classdef JsonReader < aod.util.FileReader
% CSVREADER
%
% Description:
%   Basis for reading in JSON files
%
% Parent:
%   aod.util.FileReader
%
% Constructor:
%   obj = JsonReader(fName)
% -------------------------------------------------------------------------
    methods
        function obj = JsonReader(varargin)
            obj = obj@aod.util.FileReader(varargin{:});
            obj.validExtensions = '*.json';
        end

        function out = read(obj)
            out = loadjson(obj.fullFile);
            obj.Data = out;
        end
    end
end