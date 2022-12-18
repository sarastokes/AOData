classdef MatReader < aod.util.FileReader
% Read a .mat file
%
% Description:
%   Reads in a .mat file. If it contains one variable, that will be 
%   returned. Multiple variables within a .mat file will be returned as 
%   a struct.
%
% Parent:
%   aod.util.FileReader
%
% Syntax:
%   obj = aod.util.readers.MatReader(fName)

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    methods
        function obj = MatReader(fileName)
            obj = obj@aod.util.FileReader(fileName);
        end

        function out = readFile(obj)
            S = load(obj.fullFile);
            f = fieldnames(S);
            if numel(f) == 1
                obj.Data = S.(f{1});
            else
                obj.Data = f;
            end
            out = obj.Data;
        end
    end

    methods (Static)
        function out = read(varargin)
            obj = aod.util.readers.MatReader(varargin{:});
            out = obj.readFile();
        end
    end
end