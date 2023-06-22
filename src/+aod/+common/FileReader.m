classdef (Abstract) FileReader < handle
% A file reader (abstract)
%
% Description:
%   Standardized interface for encapsulating file reading
%
% Constructor:
%   obj = aod.common.FileReader(fileName)
%
% Examples:
%   % Initialize without file and set afterwards
%   obj = aod.common.FileReader([])
%   obj.changeFile('myfile.txt')
%   % Note, FileReader is abstract so use only with a subclass 

% By Sara Patterson, 2023 (AOData)
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

    methods (Abstract, Static)
        obj = read(obj, varargin);
    end

    methods
        function obj = FileReader(fileName)
            if nargin > 0 && ~isempty(fileName)
                obj.fullFile = completeFileName(fileName);
            end
            
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

    % MATLAB builtin methods
    methods
        function tf = isequal(obj, other)
            if ~strcmp(class(obj), class(other))
                tf = false;
                return
            end

            if ~strcmp(obj.fullFile, other.fullFile)
                tf = false;
                return
            end

            mc = metaclass(obj);
            for i = 1:numel(mc.PropertyList)
                propName = mc.PropertyList(i).Name;
                if strcmp(propName, 'Data')
                    continue 
                end
                if ~strcmp(mc.PropertyList(i).GetAccess, 'private')
                    p = findprop(other, propName);
                    if ~isempty(p) && ~isequal(obj.(propName), other.(propName))
                        tf = false;
                        return 
                    end
                end
            end

            % If it makes it this far, they're equal
            tf = true;
        end
    end
end