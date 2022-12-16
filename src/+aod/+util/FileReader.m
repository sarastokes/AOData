classdef (Abstract) FileReader < handle
% FILEREADER (abstract)
%
% Description:
%   Standardized interface for reading files
%
% Constructor:
%   obj = aod.util.FileReader(varargin)

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------
    properties (SetAccess = protected)
        Path 
        Name
        Extension
    end

    properties (Hidden, SetAccess = protected)
        validExtensions = '*.*'   % valid types ('*.m' or {'*.m', '*.py'})
    end

    properties (Transient, SetAccess = protected)
        Data        % Info read, not saved if reader is saved
    end

    properties (Dependent)
        fullFile
    end

    methods (Abstract)
        % Reads in the file and assigns to "data"
        out = read(obj)
    end

    methods
        function obj = FileReader(varargin)
            if nargin == 1
                % Treat as file name, pass to getFileName() if invalid
                try
                    [obj.Path, obj.Name, obj.Extension] = fileparts(varargin{1});
                catch
                    obj.getFileName(varargin{:});
                end
            elseif nargin > 1
                obj.getFileName(varargin{:});
            elseif nargin == 0
                return      % Useful for subclasses to own initialization
            end
        end

        function value = get.fullFile(obj)
            if ischar(obj.Path)
                value = [obj.Path, filesep, obj.Name, obj.Extension];
            else 
                value = obj.Path + filesep + obj.Name + obj.Extension;
            end
        end

        function out = reload(obj)
            out = obj.read();
        end

        function setName(obj, newFileName)
            obj.Name = newFileName;
        end

        function getFileName(obj, varargin) 
            [fName, fPath] = uigetfile(obj.validExtensions);
            if fName ~= 0 
                obj.Name = fName;
                obj.Path = fPath;
            else
                disp('User canceled. File name and path not set.')
            end
        end

        function setPath(obj, newFilePath)
            assert(isfolder(newFilePath), 'File path does not exist!');
            obj.Path = newFilePath;
        end
    end
end