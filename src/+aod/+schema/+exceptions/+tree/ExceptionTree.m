classdef ExceptionTree < handle

    properties (SetAccess = private)
        exceptionType
        Children        aod.schema.exceptions.tree.ExceptionNode = aod.schema.exceptions.tree.ExceptionNode.empty()
    end

    properties (Dependent)
        numChildren     {mustBeInteger}
        totalNumErrors  {mustBeInteger}
    end

    methods
        function obj = ExceptionTree(exceptionType)
            obj.exceptionType = exceptionType;
        end
    end

    methods
        function value = get.numChildren(obj)
            value = numel(obj.Children);
        end

        function value = get.totalNumErrors(obj)
            if obj.numChildren == 0
                value = 0;
            else
                value = sum(obj.Children.totalNumErrors);
            end
        end
    end

    methods
        function addChildren(obj, children)
            for i = 1:numel(children)
                children(i).setParent(obj);
                obj.Children = [obj.Children, children(i)];
            end
        end

        function out = text(obj)
            if obj.totalNumErrors == 0
                out = "No errors found";
                return
            end

            out = "";
            for i = 1:numel(obj.Children)
                out = out + obj.Children(i).text();
            end
        end
    end
end