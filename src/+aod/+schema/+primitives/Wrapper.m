classdef Wrapper < handle & matlab.mixin.indexing.RedefinesParen
% WRAPPER
%
% Superclasses:
%   matlab.mixin.indexing.RedefinesParen, handle
%
% Description:
%   The goal is to be fully transparent to the user (i.e. acts like the
%   Primitive in the "Value" property). The need for this wrapper is
%   because we don't want to deal with a new object when the underlying
%   Primitive type is changed.
%
% Constructor:
%   obj = aod.schema.primitives.Wrapper(name, parent)
%   obj = aod.schema.primitives.Wrapper(name, parent, 'Type', type)
%

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        Value
    end

    properties (Dependent)
        Name
        Parent
        Type
    end

    properties (Hidden, Dependent)
        OPTIONS
    end

    methods
        function obj = PrimitiveWrapper(name, parent, varargin)
            if nargin == 0
                name = "";
            end
            if nargin < 2
                parent = [];
            end

            ip = inputParser();
            addParameter(ip, 'Type', []);
            parse(ip, varargin{:});

            if isempty(ip.Results.Type)
                obj.Value = aod.specification.types.Unknown(...
                    name, parent, varargin{:});
            else
                % TODO: Fill out primitive type creation
                error('PrimitiveWrapper:NotYetImplemented',...
                    'Specific type creation not yet implemented');
            end
        end

        function value = get.Name(obj)
            value = obj.Value.Name;
        end

        function value = get.Parent(obj)
            value = obj.Value.Parent;
        end

        function value = get.Type(obj)
            value = getClassWithoutPackages(obj.Value);
        end

        function value = get.OPTIONS(obj)
            if isempty(obj.Value)
                value = [];
            else
                value = obj.Value.OPTIONS;
            end
        end
    end

    % Work in progress methods
    methods
        function setType(obj, primitiveType)
            % Convert valid specifications to new type
            obj.OPTIONS = obj.Value.OPTIONS;

            currentProps = string(properties(obj));

            mc = metaclass(obj.Value);
            propNames = arrayfun(@(x) string(x.Name), mc.PropertyList);
        end
    end

    methods
        function assign(obj, varargin)
            obj.Value.assign(varargin{:});
        end
    end

    % matlab.mixin.indexing.RedefinesParen
    methods
        function out = cat(dim, varargin)
            numCatArrays = nargin - 1;
            newArgs = cell(numCatArrays, 1);
            for ix = 1:numCatArrays
                if isa(varargin{ix}, 'aod.specification.Entry2')
                    newArgs{ix} = varargin{ix}.Value;
                else
                    newArgs{ix} = varargin{ix};
                end
            end
            out = aod.specification.Entry(cat(dim, newArgs{:}));
        end

        function varargout = end(~, ~, ~)
            error("EntityContainer:EndNotSupported",...
                "End not supported");
        end

        function varargout = size(obj,varargin)
            [varargout{1:nargout}] = size(obj.Value,varargin{:});
        end

    end

    methods (Access = protected)
        function out = parenReference(obj, ~)
            out = obj.Value;
        end

        function n = parenListLength(obj, indexOp, ctx)
            if numel(indexOp) <= 2
                n = 1;
                return
            end
            containedObj = obj.(indexOp(1:2));
            n = listlength(containedObj, indexOp(3:end), ctx);
        end

        function out = parenAssign(~, ~, varargin)
            error('parenAssign:NotSupported', 'Parenthesis assignment not supported');
        end

        function obj = parenDelete(~, ~)
            error('parenDelete:NotSupported', 'Parenthesis deletion not supported')
        end
    end

    methods (Static)
        function obj = empty()
            obj = aod.specification.Entry2([], []);
        end
    end

end