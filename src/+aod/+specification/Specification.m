classdef (Abstract) Specification < handle & matlab.mixin.Heterogeneous
% An abstract class for all specification fields
%
% Superclasses:
%   handle, matlab.mixin.Heterogeneous
%
% Constructor:
%   N/A

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    events 
        ValidationFailed
    end

    methods (Abstract)
        out = text(obj)
        setValue(obj, input)
    end

    methods
        function obj = Specification()
        end
    end

    methods
        function out = compare(obj, other)
            % Compare two specifications
            %
            % Syntax:
            %   out = compare(obj, other)
            % -------------------------------------------------------------

            import aod.specification.MatchType

            if ~isa(other, class(obj))
                error('compare:UnlikeSpecificationTypes',...
                    'Comparisons can only be performed between the same specification types.');
            end

            if isequal(obj, other)
                out = MatchType.SAME;
            else
                if isempty(obj)
                    out = MatchType.MISSING;
                elseif isempty(other)
                    out = MatchType.UNEXPECTED;
                else
                    out = MatchType.CHANGED;
                end
            end
        end
    end

    methods (Access = protected)
        function notifyListeners(obj, msg)
            evtData = aod.specification.events.ValidationEvent(...
                class(obj), msg);
            notify(obj, 'ValidationFailed', evtData);
        end
    end
end