classdef (Abstract) Specification < handle & matlab.mixin.Heterogeneous
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

    methods (Abstract)
        out = text(obj)
        setValue(obj, input)
        tf = isSpecified(obj)
    end

    methods
        function obj = Specification(parent)
            if nargin > 0 && ~isempty(parent)
                obj.setParent(parent);
            end
        end
    end

    methods
        function out = compare(obj, other)
            % Compare two specifications
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
                    out = MatchType.MISSING;
                elseif ~other.isSpecified()
                    out = MatchType.UNEXPECTED;
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
            % TODO: Validation
            obj.Parent = primitive;
        end
    end
end