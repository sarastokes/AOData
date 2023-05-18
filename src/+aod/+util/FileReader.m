classdef (Abstract) FileReader < handle
% A file reader (abstract)
%
% Description:
%   Standardized interface for reading files
%
% Constructor:
%   obj = aod.util.FileReader(fileName)
%
% Examples:
%   % Initialize without file and set afterwards
%   obj = aod.util.FileReader([])
%   obj.changeFile('myfile.txt')

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        % Full file name, including file path
        fullFile
        % Key/value parameters related to file reading
        parameters
    end

    properties (Transient, SetAccess = protected)
        % Transient, file data should be added to an entity if worth saving
        Data        
    end
    
    methods (Abstract)
        % Reads the file and assigns to "Data" (or user-defined properties)
        out = readFile(obj)
    end

    methods
        function obj = FileReader(fileName)
            if nargin > 0 && ~isempty(fileName)
                fileName = completeFileName(fileName);
                obj.fullFile = fileName;
            end
            obj.parameters = aod.util.Parameters();
            % Because some files may be time-consuming to load, readFile()
            % is not called bu default when the FileReader is created
        end

        function changeFile(obj, fileName)
            fileName = completeFileName(fileName);
            obj.fullFile = fileName;
        end

        function out = reload(obj)
            out = obj.readFile();
        end
    end
end