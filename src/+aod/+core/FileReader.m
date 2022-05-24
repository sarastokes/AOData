classdef (Abstract) FileReader < handle

    properties (SetAccess = protected)
        Path {mustBeFolder}
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
                assert(isfile(varargin{1}), 'Single input must be file name!');
                [obj.Path, obj.Name, obj.Extension] = fileparts(varargin{1});
            elseif nargin > 1
                obj.getFileName(varargin{:});
            end
        end

        function value = get.fullFile(obj)
            value = [obj.Path, filesep, obj.Name];
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