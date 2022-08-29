classdef EntityContainer < handle & matlab.mixin.indexing.RedefinesParen

    properties (Hidden, Dependent)
        contents
    end

    properties (SetAccess = private)
        hdfPath
        entityFactory
        memberPaths                 string = string.empty()
    end

    methods
        function obj = EntityContainer(hdfPath, entityFactory)
            obj.hdfPath = hdfPath;
            obj.entityFactory = entityFactory;
            obj.populateContents();
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
                error("EntityContainer:MemberPathsEmpty",...
                    "There are no member paths to return");
            end

            if numel(indexOp.Indices) > 1
                error("EntityContainer:IncorrectDimensions",...
                    "The number of dimensions should be 1");
            end

            pathIdx = indexOp.Indices{1};
            entities = [];
            for i = 1:numel(pathIdx)
                entities = cat(1, entities, obj.entityFactory.create(obj.memberPaths(pathIdx(i))));
            end
        end

        function n = parenListLength(obj, indexOp, indexContext)
            assignin('base', 'indexingContext', indexingContext);
            assignin('base', 'indexOp', indexOp);
            warning('Responses/parenListLength triggered!')
            n = listLength(size(obj.memberPaths), indexOp, indexContext);
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
                obj = EntityContainer();
                return
            end

            obj = EntityContainer(varargin{1}, varargin{2});
        end
    end
end