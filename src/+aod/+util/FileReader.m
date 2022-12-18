classdef (Abstract) FileReader < handle
% A file reader (abstract)
%
% Description:
%   Standardized interface for reading files
%
% Constructor:
%   obj = aod.util.FileReader(fileName)

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        % Full file name, including file path
        fullFile
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
            fileName = completeFileName(fileName);
            obj.fullFile = fileName;
            % Because some files may be time-consuming to load, readFile()
            % is not called bu default when the FileReader is created
        end

        function out = reload(obj)
            out = obj.readFile();
        end
    end
end