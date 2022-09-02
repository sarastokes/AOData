classdef ClassRepository < handle 
% CLASSREPOSITORY
%
% Constructor:
%   obj = ClassRepository(path)
%
% Input:
%   path        Search path(s) split by ';'
%
% History:
%   06Nov2021 - SSP - Adapted from Symphony's ClassRepository
%   04Dec2021 - SSP - Added superclass list method
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        searchPath 
        classMap 
    end

    methods 
        function obj = ClassRepository(path)
            obj.setSearchPath(path);
        end

        function setSearchPath(obj, path)
            dirs = strsplit(path, ';');
            for i = 1:numel(dirs)
                if exist(dirs{i})
                    [~, ~, p] = packageName(dirs{i});
                    addpath(p);
                end
            end
            obj.searchPath = path;
            obj.loadAll();
        end

        function cn = get(obj, superclass)
            if obj.classMap.isKey(superclass)
                cn = obj.classMap(superclass);
            else
                cn = {};
            end
        end

        function y = list(obj)
            y = string(obj.classMap.keys)';
        end
    end

    methods (Access = private)
        function loadAll(obj)
            obj.classMap = containers.Map();
        
            dirs = strsplit(obj.searchPath, ';');
            for i = 1:numel(dirs)
                obj.loadDirectory(dirs{i});
            end
        end

        function loadDirectory(obj, path)
            package = packageName(path);
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
            m = eval(sprintf('?%s', name));
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
end 