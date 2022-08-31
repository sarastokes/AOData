classdef CsvReader < aod.util.FileReader 
% CSVREADER
%
% Description:
%   Basis for reading in CSV files
%
% Parent:
%   aod.util.FileReader
%
% Constructor:
%   obj = CsvReader(fName)
%   obj = CsvReader(varargin)
% -------------------------------------------------------------------------
    methods
        function obj = CsvReader(varargin)
            obj = obj@aod.util.FileReader(varargin{:});
            obj.validExtensions = '*.csv';
        end

        function out = read(obj)
            out = csvread(obj.fullFile); %#ok<CSVRD> 
            obj.Data = out;
        end
    end
end
