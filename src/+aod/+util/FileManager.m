classdef (Abstract) FileManager < handle 
% FileManager (abstract)
%
% Description:
%   A class to encapsulate identfication of files related to a specific 
%   entity and assignment to the "files" property



    properties (SetAccess = protected)
        baseFolderPath
        baseFolderName
        messageLevel = aod.infra.ErrorTypes.WARNING 
    end

    methods (Abstract)
        % This method implements assigning file names to an entity
        entity = populateFileNames(obj, entity, varargin)
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

        function setErrorType(obj, errorType)
            obj.messageLevel = aod.infra.ErrorTypes.init(errorType);
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

            % Create a string array of files
            files = ls(fPath);
            files = deblank(string(files));

            % Remove non-file names
            files(files == ".") = [];
            files(files == "..") = [];
        end
    end

    methods (Static)
        function matches = checkFilesFound(matches, whichToKeep)
            % Determines which files to keep if more than 1 match is found
            %
            % Syntax:
            %   matches = checkFilesFound(matches)
            %   matches = checkFilesFound(matches, whichToKeep)
            %
            % Examples:
            %   % Keep the first if >1 match found
            %   matches = checkFilesFound(matches, 1)
            %
            % Notes:
            %   - If only one file is found, it will be returned
            %   - By default the last file found will be chosen as this is
            %   usually the most recent, if file names include dates
            % -------------------------------------------------------------
            if nargin < 2
                whichToKeep = numel(matches);
            end
            if numel(matches) > 1
                matches = matches(whichToKeep);
            end
        end
    end
end 