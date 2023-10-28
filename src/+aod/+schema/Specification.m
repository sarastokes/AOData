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
        Parent                  % aod.schema.primitives.Primitive
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

    methods (Access = protected)
        function out = toYAML(obj)
            % Overwrite by subclasses, if needed
            out = {obj.Value};
        end

        function notifyListeners(obj, msg)
            evtData = aod.specification.events.ValidationEvent(...
                class(obj), msg);
            notify(obj, 'ValidationFailed', evtData);
        end
    end

    methods (Sealed, Access = {?aod.schema.types.Primitive})
        function setParent(obj, primitive)
            % TODO: Validation
            obj.Parent = primitive;
        end

        function out = getValueForYAML(obj)
            % Note that values need to be wrapped in a cell array to
            % ensure proper conversion to YAML
            if ~obj.isSpecified()
                out = {yaml.Null};
            else
                out = {obj.toYAML()};
            end
        end
    end

    methods (Static, Access = protected)
        function tf = isInputEmpty(input)
            input = convertCharsToStrings(input);
            if aod.util.isempty(input) || isequal(input, "[]")
                tf = true;
            elseif isstring(input) && all(isequal(input, "[]"))
                tf = true;
            else
                tf = false;
            end
        end
    end
end