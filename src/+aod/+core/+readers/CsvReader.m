classdef CsvReader < aod.core.FileReader 

    methods
        function obj = CsvReader(varargin)
            obj = obj@aod.core.FileReader(varargin{:});
            obj.validExtensions = '*.csv';
        end

        function out = read(obj)
            out = csvread(obj.fullFile); %#ok<CSVRD> 
            obj.Data = out;
        end
    end
end
