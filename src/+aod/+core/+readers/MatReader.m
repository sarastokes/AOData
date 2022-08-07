classdef MatReader < aod.core.FileReader
% MATREADER
%
% Description:
%   Reads in a .mat file
%
% Parent:
%   aod.core.FileReader
% -------------------------------------------------------------------------
    methods
        function obj = MatReader(varargin)
            obj = obj@aod.core.FileReader(varargin{:});
            obj.validExtensions = '*.mat';
        end

        function out = read(obj)
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
end