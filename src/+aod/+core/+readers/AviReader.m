classdef AviReader < aod.core.FileReader

    methods
        function obj = AviReader(varargin)
            obj = obj@aod.core.FileReader(varargin{:});
            obj.validExtensions = '*.avi';
        end

        function out = read(obj)
            obj.Data = video2stack(obj.fullFile);
            out = obj.Data;
        end
    end
end