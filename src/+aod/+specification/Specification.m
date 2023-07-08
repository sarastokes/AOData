classdef (Abstract) Specification < handle & matlab.mixin.Heterogeneous

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

            import aod.specification.ViolationType

            if ~isa(other, class(obj))
                error('compare:UnlikeSpecificationTypes',...
                    'Comparisons can only be performed between the same specification types.');
            end

            if isequal(obj, other)
                out = ViolationType.SAME;
            else
                if isempty(obj)
                    out = ViolationType.MISSING;
                elseif isempty(other)
                    out = ViolationType.UNEXPECTED;
                else
                    out = ViolationType.CHANGED;
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