classdef RepositoryManager < handle 
% REPOSITORYMANAGER
%
% Description:
%   Preference setting for base aod-tools package and user-defined packages
%
% Parent:
%   handle
%
% Constructor:
%   obj = RepositoryManager()
%
% Properties:
%   basePackage - file path of base aod-tools repository
%   userPackages - file path(s) of user-defined packages
%   commitIDs - containers.Map: package names as keys, commit IDs as values
% -------------------------------------------------------------------------
    properties (SetAccess = private)
        basePackage
        userPackages
        commitIDs
    end

    properties (Hidden, Constant)
        AOD_PATH = getpref('AOData', 'BasePackage');
    end

    methods
        function obj = RepositoryManager()
            % Check user preferences for package
            obj.findPackages();
            % Ensure full packages are added to MATLAB's search path
            obj.addPackagesToPath();
            % Get repo information
            obj.compileCommitIDs();
        end

        function refreshIDs(obj)
            obj.compileCommitIDs();
        end

        function listPackages(obj)
            fprintf('Base aod-tools package:\n');
            fprintf('\t%s\n', obj.basePackage);
            if isempty(obj.userPackages)
                fprintf('No user-defined packages\n');
            else
                fprintf('User-defined packages:\n');
                for i = 1:numel(obj.userPackages)
                    fprintf('\t%s\n', obj.userPackages{i});
                end
            end
        end
    end

    methods (Access = private)
        function compileCommitIDs(obj)
            obj.commitIDs = aod.util.Parameters();
            ID = obj.getCommitHash(obj.basePackage);
            repo = obj.getRepoName(obj.basePackage);
            obj.commitIDs(repo) = ID;

            if isempty(obj.userPackages)
                return
            end

            for i = 1:numel(obj.userPackages)
                ID = obj.getCommitHash(obj.userPackages(i));
                repo = obj.getRepoName(obj.userPackages(i));
                obj.commitIDs(repo) = ID;
            end
        end

        function addPackagesToPath(obj)
            addpath(genpath(obj.basePackage));
            if ~isempty(obj.userPackages)
                for i = 1:numel(obj.userPackages)
                    addpath(genpath(obj.userPackages(i)));
                end
            end
        end

        function findPackages(obj)
            S = getpref('AOData');
            if isempty(S)
                obj.addBasePackage();
                if ~isempty(obj.userPackages)
                    obj.setUserPackages();
                else
                    setpref('AOData', 'SearchPaths', string.empty());
                end
                return
            end

            f = fieldnames(S);
            if ~ismember(f, 'BasePackage')
                obj.addBasePackage();
            else
                obj.basePackage = getpref('AOData', 'BasePackage');
            end
        end

        function addBasePackage(obj)
            warning("PackageManager:AddingBasePackage",...
                'Setting AOData/BasePackage user preference');
            obj.setBasePackage(obj.AOD_PATH);
        end

        function checkBasePackage(obj)
            if ~strcmp(obj.AOD_PATH, obj.basePackage)
                error("PackageManager:InvalidBasePackage",...
                    "Base Package does not match current aod folder!");
            end
        end

        function setBasePackage(obj, aodPath)
            arguments
                obj 
                aodPath         {mustBeFolder}
            end

            setpref('AOData', 'BasePackage', aodPath);
            obj.basePackage = aodPath;
        end

        function setUserPackages(obj)
            setpref('AOData', 'UserPackages', obj.userPackages);
        end
    end

    methods (Static)
        function ID = getCommitHash(fPath)
            % GETCOMMITHASH
            %
            % Description:
            %   Gets commit hash given repository file path
            %
            % Syntax:
            %   ID = PackageManager.getCommitHash(fPath)
            % -------------------------------------------------------------
            [~, ID] = system('git -C %s rev-parse HEAD');
            if ~isempty(ID)
                ID = strtrim(ID);
            end
        end

        function repoName = getRepoName(fPath)
            % GETREPONAME
            %
            % Description:
            %   Takes file path and returns the repository name
            %
            % Syntax:
            %   ID = PackageManager.getRepoName(fPath)
            % -------------------------------------------------------------
            arguments
                fPath       char
            end
            if endsWith(fPath, filesep)
                fPath = fPath(1:end-1);
            end
            txt = strsplit(fPath, filesep);
            repoName = txt{end};
        end
    end
end 