classdef ExceptionNode < handle & matlab.mixin.Heterogeneous

    properties (SetAccess = protected)
        SCHEMA_LEVEL
        EXCEPTION_TYPE      aod.schema.exceptions.ExceptionType
    end

    properties (SetAccess = protected)
        Parent
        Children            aod.schema.exceptions.tree.ExceptionNode
    end

    properties (SetAccess = private)
        Causes
    end

    properties (Dependent)
        numErrors           {mustBeInteger}
        numChildren         {mustBeInteger}
    end

    properties (Hidden, Dependent)
        totalNumErrors      {mustBeInteger}
    end

    methods
        function obj = ExceptionNode(exceptionType, causes)
            obj.exceptionType = aod.schema.exceptions.ExceptionType.get(exceptionType);

            if nargin > 0 && ~isempty(causes)
                obj.addCause(cause);
            end
        end
    end

    methods
        function value = get.numErrors(obj)
            value = numel(obj.Causes);
        end

        function value = get.numChildren(obj)
            value = numel(obj.Children);
        end

        function value = get.totalNumErrors(obj)
            value = obj.numErrors + sum(obj.Children.totalNumErrors);
        end
    end

    methods
        function addCause(obj, cause)
            arguments
                obj
                cause       MException
            end

            obj.Causes = [obj.Causes; cause];
        end

        function addChildren(obj, children)
            for i = 1:numel(children)
                % TODO: Check schema level is obj.SCHEMA_LEVEL + 1
                children(i).setParent(obj);
                obj.Children = [obj.Children; children(i)];
            end
        end
    end

    methods
        function out = text(obj)  %#ok<MANU>
            % TEXT  Subclasses can extend to provide a text representation
            out = "";
        end
    end

    methods (Access = private)
        function setParent(obj, parent)
            % TODO: If node, check that schema level is obj.SCHEMA_LEVEL - 1
            mustBeSubclass(parent, ["aod.schema.exceptions.tree.ExceptionTree",...
                                    "aod.schema.exceptions.tree.ExceptionNode"]);

            obj.Parent = parent;
        end
    end

    methods (Static)
        function out = getIndent(indentLevel)
            if indentLevel == 0
                out = "";
            else
                out = repmat("  ", 1, indentLevel);
            end
        end
    end
end