classdef AviReader < aod.util.FileReader
% AVIREADER
%
% Description:
%   Reads in AVI files
%
% Parent:
%   aod.util.FileReader
%
% Constructor:
%   obj = AviReader(fName)
%   obj = AviReader(varargin)
% -------------------------------------------------------------------------

    methods
        function obj = AviReader(varargin)
            obj = obj@aod.util.FileReader(varargin{:});
            obj.validExtensions = '*.avi';
        end

        function out = read(obj)
            obj.Data = video2stack(obj.fullFile);
            out = obj.Data;
        end
    end
end