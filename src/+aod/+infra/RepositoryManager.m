classdef RepositoryManager < handle 
% Manages git repositories used by AOData
%
% Description:
%   Collects information about git repositories used by AOData
%
% Constructor:
%   obj = aod.infra.RepositoryManager()
%
% Properties:
%   repositoryInfo - table containing information about each repository
%
% Private properties:
%   basePackage - file path of base aod-tools repository
%   userPackages - file path(s) of user-defined packages
%
% See Also:
%   AODataManagerApp, getGitInfo   

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        % A table containing all git repositories and their current status
        repositoryInfo
    end

    properties (Access = private)
        basePackage
        userPackages
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
            obj.getRepoInfo();
        end

        function update(obj)
            obj.getRepoInfo();
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
        function getRepoInfo(obj)
            % Collects information about associated repos into a table
            userDirectory = pwd;
            
            repoMap = containers.Map();
            repoMap('AOData') = obj.getCommitHash(obj.basePackage);

            if ~isempty(obj.userPackages)
                for i = 1:numel(obj.userPackages)
                    gitInfo = obj.getCommitHash(obj.userPackages(i));
                    repo = obj.getRepoName(obj.userPackages(i));
                    repoMap(repo) = gitInfo;
                end
            end

            % Convert to table (TODO: Clean)
            repoNames = repoMap.keys;
            S = [];
            for i = 1:numel(repoNames)
                S = [S, repoMap(repoNames{i})]; %#ok<AGROW> 
            end  

            obj.repositoryInfo = struct2table(S);
            obj.repositoryInfo.branch = string(obj.repositoryInfo.branch);
            obj.repositoryInfo.hash = string(obj.repositoryInfo.hash);
            obj.repositoryInfo.remote = string(obj.repositoryInfo.remote);
            obj.repositoryInfo.url = string(obj.repositoryInfo.url);
            obj.repositoryInfo.Properties.RowNames = repoNames;

            % Return to user's previous directory
            cd(userDirectory);
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
            obj.basePackage = getpref('AOData', 'BasePackage');

            allPackages = string(getpref('AOData', 'GitRepos'));
            allPackages = strsplit(allPackages, ";");
            idx = find(allPackages ~= obj.basePackage);
            if ~isempty(idx)
                obj.userPackages = allPackages(idx);
            end
        end

        function checkBasePackage(obj)
            if ~strcmp(obj.AOD_PATH, obj.basePackage)
                error("PackageManager:InvalidBasePackage",...
                    "Base Package does not match current aod folder, Update with AODataManagerApp!");
            end
        end
    end

    methods (Static)
        function info = getCommitHash(fPath)
            % Gets commit information given repository file path
            %
            % Syntax:
            %   ID = PackageManager.getCommitHash(fPath)
            % -------------------------------------------------------------
            cd(fPath)
            info = getGitInfo();
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