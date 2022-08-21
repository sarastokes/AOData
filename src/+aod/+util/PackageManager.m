classdef PackageManager < handle 
% PACKAGEMANAGER
%
% Description:
%   Preference setting for base aod-tools package and user-defined packages
%
% Parent:
%   handle
%
% Constructor:
%   obj = PackageManager()
%
% Properties:
%   basePackage - file path of base aod-tools repository
%   userPackages - file path(s) of user-defined packages
% -------------------------------------------------------------------------
    properties (SetAccess = private)
        basePackage
        userPackages
    end

    properties (Hidden, Constant)
        AOD_PATH = fileparts(fileparts(fileparts(fileparts(mfilename('fullpath')))));
    end

    methods
        function obj = PackageManager()
            % Check user preferences for package
            obj.findPackages();
            % Ensure full packages are added to MATLAB's search path
            obj.addPackagesToPath();
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

        function addPackage(obj, packagePath)
            arguments
                obj
                packagePath     string      {mustBeFolder}
            end
            obj.userPackages = cat(1, obj.userPackages, packagePath);
            obj.setUserPackages();
        end

        function removePackage(obj, packagePath)
            arguments
                obj
                packagePath     string 
            end
            idx = find(obj.userPackages == packagePath);
            if isempty(idx)
                obj.listPackages();
                error("PackageManager:UnrecognizedPackage",...
                    "%s not found", packagePath);
            else
                obj.userPackages(idx) = [];
                setpref('AODTools', 'UserPackages', obj.userPackages);
            end
        end
    end

    methods (Access = private)
        function addPackagesToPath(obj)
            addpath(genpath(obj.basePackage));
            if ~isempty(obj.userPackages)
                for i = 1:numel(obj.userPackages)
                    addpath(genpath(obj.userPackages(i)));
                end
            end
        end

        function findPackages(obj)
            S = getpref('AODTools');
            if isempty(S)
                obj.addBasePackage();
                if ~isempty(obj.userPackages)
                    obj.setUserPackages();
                else
                    setpref('AODTools', 'UserPackages', string.empty());
                end
                return
            end

            f = fieldnames(S);
            if ~ismember(f, 'BasePackage')
                obj.addBasePackage();
            else
                obj.basePackage = getpref('AODTools', 'BasePackage');
            end
        end

        function addBasePackage(obj)
            warning("PackageManager:AddingBasePackage",...
                'Setting AODTools/BasePackage user preference');
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

            setpref('AODTools', 'BasePackage', aodPath);
            obj.basePackage = aodPath;
        end

        function setUserPackages(obj)
            setpref('AODTools', 'UserPackages', obj.userPackages);
        end
    end
end 