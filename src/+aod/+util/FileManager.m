classdef FileManager < handle 

    properties (SetAccess = protected)
        baseFolderPath
        baseFolderName
        messageLevel = aod.util.MessageTypes.WARNING 
    end

    methods (Abstract)
        ep = populateFileNames(obj, ep, varargin)
    end

    methods 
        function obj = FileManager(baseFolderPath)
            obj.baseFolderPath = baseFolderPath;
            txt = strsplit(obj.baseFolderPath, filesep);
            if isempty(txt{end}) % Trailing filesep
                obj.baseFolderName = txt{end-1};
            else
                obj.baseFolderName = txt{end};
            end
        end

        function setMessageType(obj, msgType)
            obj.messageLevel = aod.util.MessageTypes.init(msgType);
        end
    end

    methods (Access = protected)
        function out = makeFilePathRelative(obj, filePath)
            if contains(filePath, obj.baseFolderName)
                loc = strfind(filePath, obj.baseFolderName);
                out = filePath(loc + length(obj.baseFolderName):end);
            else 
                out = filePath;
            end
        end

        function files = collectFiles(obj, subFolder)
            if nargin > 1
                fPath = fullfile(obj.baseFolderPath, subFolder);
            else
                fPath = obj.baseFolderPath;
            end

            files = ls(fPath);
            files = deblank(string(files));
        end
    end

    methods (Static)
        function matches = checkFilesFound(matches, whichToKeep)
            if nargin < 2
                whichToKeep = numel(matches);
            end
            if numel(matches) > 1
                matches = matches(whichToKeep);
            end
        end
    end
end 