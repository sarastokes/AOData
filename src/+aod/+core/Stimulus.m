classdef Stimulus < aod.core.Entity

    properties (SetAccess = protected)
        presentation timetable
        stimParameters
    end

    methods (Abstract)
        loadPresentation(obj, varargin)
    end

    methods
        function obj = Stimulus(parent)
            obj.allowableParentTypes = {'aod.core.Epoch'};
            if nargin == 1
                obj.setParent(parent);
            end
            obj.stimParameters = containers.Map();
        end
    end
end
