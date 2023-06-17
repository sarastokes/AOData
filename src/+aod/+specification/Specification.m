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

    methods (Access = protected)
        function notifyListeners(obj, msg)
            evtData = aod.specification.events.ValidationEvent(...
                class(obj), msg);
            notify(obj, 'ValidationFailed', evtData);
        end
    end
end