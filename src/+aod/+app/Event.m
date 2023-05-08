classdef (ConstructOnLoad) Event < event.EventData
% Type-agnostic event 
%
% Constructor:
%   obj = Event(eventName, trigger, varargin)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties
        EventType
        Trigger
        Data
    end

    methods
        function obj = Event(eventType, trigger, varargin)

            obj.EventType = eventType;
            obj.Trigger = trigger;

            obj.Data = struct();
            if ~isempty(varargin)
                for i = 1:2:numel(varargin)
                    assert(istext(varargin{i}), ...
                        'Additional inputs must be key/value pairs')
                    obj.Data.(varargin{i}) = varargin{i+1};
                end
            end
        end
    end
end 