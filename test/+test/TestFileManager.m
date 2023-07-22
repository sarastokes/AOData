classdef TestFileManager < aod.util.FileManager 

    methods
        function obj = TestFileManager(varargin)
            obj@aod.util.FileManager(varargin{:});
        end

        function entity = populateFileNames(~, entity)
            % Do nothing
        end

        function out = getFilesFound(obj, varargin)
            % Access to collectFiles method
            out = obj.collectFiles(varargin{:});
        end
    end
end 