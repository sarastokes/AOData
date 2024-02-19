classdef ClassRepository < handle
% CLASSREPOSITORY
%
% Description:
%   Sorts classes on AOData's search path by package
%
% Constructor:
%   obj = aod.infra.ClassRepository()
%   obj = aod.infra.ClassRepository(path)
%
% Input:
%   path        Search path(s) split by ';'
%       If empty, getpref('AOData', 'SearchPaths') will be used
%
% Methods:
%   setSearchPath(obj, path)
%   superClasses = list(obj, [entityFlag])
%   subClasses = get(obj, superClass, [entityFlag])
%   allClasses = getAllClasses([entityFlag])
%
% References:
%   Adapted from ClassRespository in Symphony-DAS
%
% See also:
%   AODataManagerApp

% By Sara Patterson, 2024 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        searchPath          string
        classMap            % containers.Map
    end

    methods
        function obj = ClassRepository(path)
            if nargin < 1
                path = obj.getPathPreferences();
            end
            obj.setSearchPath(path);
        end

        function cn = get(obj, superclass)

            if obj.classMap.isKey(superclass)
                cn = obj.classMap(superclass);
                cn = string(cn');
            else
                cn = string.empty();
            end
        end

        function superClasses = list(obj, entityFlag)
            arguments
                obj         (1,1)       aod.infra.ClassRepository
                entityFlag  (1,1)       logical = true;
            end

            superClasses = string(obj.classMap.keys)';
            if entityFlag
                tf = arrayfun(@(x) isSubclass(x, "aod.core.Entity"), superClasses);
                superClasses = superClasses(tf);
            end
        end

        function classNames = getAllClasses(obj, entityFlag)
            arguments
                obj         (1,1)       aod.infra.ClassRepository
                entityFlag  (1,1)       logical = true;
            end

            keyNames = obj.list(entityFlag);
            classNames = arrayfun(@(x) obj.get(x), keyNames, ...
                "UniformOutput", false);
            classNames = uncell(classNames);
        end

        function pkgClasses = getClassesByPackage(obj, pkgName, entityFlag)
            
            arguments
                obj             aod.infra.ClassRepository
                pkgName         string
                entityFlag      logical = true
            end

            warning('getClassesByPackage:OnlySuperClasses',...
                'This only contains superclasses, not all subclasses');

            allClasses = obj.list(entityFlag);
            pkgClasses = allClasses(startsWith(allClasses, pkgName));
        end
    end

    methods (Access = private)
        function setSearchPath(obj, path)
            arguments
                obj         aod.infra.ClassRepository
                path        string
            end

            for i = 1:numel(path)
                if isfolder(path(i))
                    [~, ~, p] = appbox.packageName(path(i));
                    addpath(p);
                else
                    warning('setSearchPath:InvalidFolder',...
                        'Folder %s not found on path', path(i));
                end
            end
            obj.searchPath = path;
            obj.loadAll();
        end

        function loadAll(obj)
            obj.classMap = containers.Map();

            paths = string(obj.searchPath);
            for i = 1:numel(paths)
                obj.loadDirectory(paths(i));
            end
        end

        function loadDirectory(obj, path)
            package = appbox.packageName(path);
            if ~isempty(package)
                package = [package '.'];
            end

            listing = dir(path);
            for i = 1:numel(listing)
                l = listing(i);
                [~, name, ext] = fileparts(l.name);
                if strcmpi(ext, '.m') && exist([package name], 'class')
                    try
                        obj.loadClass([package name]);
                    catch x
                        warning(x.message);
                    end
                elseif ~isempty(name) && name(1) == '+'
                    obj.loadDirectory(fullfile(path, l.name));
                end
            end
        end

        function loadClass(obj, name)
            m = meta.class.fromName(name);
            if ~m.Abstract
                supers = superclasses(name);
                for i = 1:numel(supers)
                    s = supers{i};
                    if obj.classMap.isKey(s)
                        classes = obj.classMap(s);
                        if ~any(strcmp(name, classes))
                            classes = [classes name];  %#ok<AGROW>
                        end
                    else
                        classes = {name};
                    end
                    obj.classMap(s) = classes;
                end
            end
        end
    end

    methods (Static)
        function searchPaths = getPathPreferences()
            searchPaths = getpref('AOData', 'SearchPaths');
            searchPaths = string(strsplit(searchPaths, ';'))';
        end
    end
end