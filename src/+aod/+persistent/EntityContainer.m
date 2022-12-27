classdef EntityContainer < handle & matlab.mixin.indexing.RedefinesParen
% ENTITYCONTAINER
%
% Description:
%   A container for entities that enables lazy loading (entity in HDF5
%   file is only read when requested, then cached in entityFactory)
%
% Parents:
%   handle, matlab.mixin.indexing.RedefinesParam
%
% Constructor:
%   obj = EntityContainer(hdfPath, entityFactory)
%
% Notes:
%   EntityContainer(0) returns all entities

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    properties (Hidden, Dependent)
        contents            % All child entities
    end

    properties (SetAccess = private)
        hdfPath
        entityFactory
        memberPaths                 string = string.empty()
    end

    methods
        function obj = EntityContainer(hdfPath, entityFactory)
            if nargin > 0
                obj.hdfPath = hdfPath;
                obj.entityFactory = entityFactory;
                obj.populateContents();
            end
        end

        function value = get.contents(obj)
            value = [];
            if isempty(obj.memberPaths)
                return;
            end

            for i = 1:numel(obj.memberPaths)
                value = cat(1, value, obj.entityFactory.create(obj.memberPaths(i)));
            end
        end
    end

    methods
        function out = getClassNames(obj)
            out = cat(1, obj.contents.classNames);
        end
    end
    
    methods (Access = ?aod.persistent.Persistor)
        function refresh(obj)
            obj.memberPaths = [];
            obj.populateContents();
        end
    end

    methods (Access = private)
        function populateContents(obj)
            info = h5info(obj.entityFactory.hdfName, obj.hdfPath);
            if ~isempty(info.Groups)
                obj.memberPaths = string({info.Groups.Name})';
            end
        end
    end

    % RedefinesParen methods
    methods 
        function varargout = size(obj, varargin)
            [varargout{1:nargout}] = size(obj.memberPaths, varargin{:});
        end

        function C = cat(~, varargin) %#ok<*STOUT> 
            error("EntityContainer:ConcatenationNotSupported",...
                "Concatenation not supported");
        end

        function varargout = end(~, ~, ~)
            error("EntityContainer:EndNotSupported",...
                "End not supported");
        end
    end

    methods (Access = protected)
        function entities = parenReference(obj, indexOp)
            if isempty(obj.memberPaths)
                entities = [];
                return
            end

            if isempty(indexOp.Indices) || ...
                    all(ischar(indexOp.Indices{1}) & strcmp(indexOp.Indices{1}, ':'))...
                    || all(isnumeric(indexOp.Indices{1}) & indexOp.Indices{1} == 0)
                pathIdx = 1:numel(obj.memberPaths);
            else
                pathIdx = indexOp.Indices{1};
            end
            entities = [];
            for i = 1:numel(pathIdx)
                entities = cat(1, entities,... 
                    obj.entityFactory.create(obj.memberPaths(pathIdx(i))));
            end
        end

        function n = parenListLength(obj, indexOp, ~)
            n = numel(obj.memberPaths(indexOp(1).Indices{1}));
        end

        function obj = parenAssign(~, ~, ~)
            error("EntityContainer:AssignNotSupported",...
                "Direct assignment not supported");
        end

        function obj = parenDelete(~, ~)
            error("EntityContainer:DeleteNotSupported",...
                "Direct deletion not supported");
        end
    end

    methods (Static)
        function obj = empty(varargin)
            if nargin == 0
                obj = aod.persistent.EntityContainer();
                return
            end

            obj = aod.persistent.EntityContainer(varargin{1}, varargin{2});
        end
    end
end