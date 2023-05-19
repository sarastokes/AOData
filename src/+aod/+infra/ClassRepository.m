classdef ClassRepository < handle 
% Sorts classes by package
%
% Constructor:
%   obj = aod.infra.ClassRepository()
%   obj = aod.infra.ClassRepository(path)
%
% Input:
%   path        Search path(s) split by ';'
%       If empty, getpref('AOData', 'SearchPaths') will be used
%
% References:
%   Adapted from ClassRespository in Symphony-DAS

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        searchPath 
        classMap 
    end

    methods 
        function obj = ClassRepository(path)
            if nargin < 1
                path = obj.getPathPreferences();
            end
            obj.setSearchPath(path);
        end

        function setSearchPath(obj, path)
            if ~isstring(path)
                path = string(path);
            end
            for i = 1:numel(path)
                if isfolder(path(i))
                    [~, ~, p] = appbox.packageName(path(i));
                    addpath(p);
                end
            end
            obj.searchPath = path;
            obj.loadAll();
        end

        function cn = get(obj, superclass)
            if obj.classMap.isKey(superclass)
                cn = obj.classMap(superclass);
                cn = string(cn');
            else
                cn = string.empty();
            end
        end

        function y = list(obj)
            y = string(obj.classMap.keys)';
        end
    end

    methods (Access = private)
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