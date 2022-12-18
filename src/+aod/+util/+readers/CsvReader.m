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
%   obj = aod.util.readers.CsvReader(fName)

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    methods
        function obj = CsvReader(fileName)
            obj = obj@aod.util.FileReader(fileName);
        end

        function out = readFile(obj)
            out = csvread(obj.fullFile); %#ok<CSVRD> 
            obj.Data = out;
        end
    end

    methods (Static)
        function out = read(fileName)
            obj = aod.util.readers.CsvReader(fileName);
            out = obj.readFile();
        end
    end
end
