classdef (Abstract) Specification < aod.schema.AODataSchemaObject & matlab.mixin.Heterogeneous
% An abstract class for all specification fields
%
% Superclasses:
%   handle, matlab.mixin.Heterogeneous
%
% Constructor:
%   obj = aod.schema.Specification(parent)
%
% See also:
%   aod.schema.Validator, aod.schema.Decorator, aod.schema.Default

% By Sara Patterson, 2023 (AOData)
% --------------------------------------------------------------------------

    properties (SetAccess = private)
        Parent                  % aod.schema.Primitive
    end

    properties (Dependent)
        SCHEMA_TYPE             aod.schema.SchemaTypes
    end

    methods (Abstract)
        out = text(obj)
        setValue(obj, input)
        tf = isSpecified(obj)
    end

    methods (Abstract, Access = protected)
        value = determineSchemaType(obj)
    end

    methods
        function obj = Specification(parent)
            if nargin > 0 && ~isempty(parent)
                obj.setParent(parent);
            end
        end

        function value = get.SCHEMA_TYPE(obj)
            value = obj.determineSchemaType();
        end
    end

    methods
        function out = compare(obj, other)
            % Compare another specification (B) to this specification (A)
            %
            % Syntax:
            %   out = compare(obj, other)
            % --------------------------------------------------------------

            import aod.schema.MatchType

            if ~isa(other, class(obj))
                error('compare:UnlikeSpecificationTypes',...
                    'Comparisons can only be performed between the same specification types.');
            end

            if isequal(obj, other)
                out = MatchType.SAME;
            else
                if ~obj.isSpecified()
                    out = MatchType.ADDED;
                elseif ~other.isSpecified()
                    out = MatchType.REMOVED;
                else
                    out = MatchType.CHANGED;
                end
            end
        end
    end

    methods
        function out = jsonencode(obj, varargin)
            % Subclasses may modify if needed
            if ~obj.isSpecified()
                out = jsonencode([], varargin{:});
            else
                out = jsonencode(obj.Value, varargin{:});
            end
        end
    end

    methods (Sealed, Access = {?aod.schema.Primitive})
        function setParent(obj, primitive)
            mustBeSubclass(primitive, ["aod.schema.Primitive", "aod.schema.Validator"]);
            obj.Parent = primitive;
        end
    end
end