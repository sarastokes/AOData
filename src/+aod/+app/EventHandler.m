classdef EventHandler < handle 
% Handles events with approximation of the Chain Of Responsibility pattern
%
% Constructor:
%   obj = aod.app.EventHandler(parent, publisher)
%
% See also:
%   aod.app.Component, aod.app.Event

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        Parent          
        Listeners       event.listener    
    end

    methods
        function obj = EventHandler(parent, publisher)
            obj.Parent = parent;
            
            if nargin < 2 || isempty(publisher)
                publisher = obj.Parent;
            end
            obj.bind(publisher);
        end

        function handleRequest(obj, ~, evtData)
            obj.passRequest(evtData);
        end

        function passRequest(obj, evtData)
            p = obj.getParentHandler();
            if ~isempty(p)
                p.handleRequest([], evtData);
            end
        end

        function close(obj)
            obj.removeAllListeners();
        end
    end

    methods (Access = protected)
        function bind(obj, publisher)
            obj.addListener(publisher, 'NewEvent', @obj.handleRequest);
        end

        function l = addListener(obj, varargin)
            l = addlistener(varargin{:});
            obj.Listeners = cat(1, obj.Listeners, l);
        end

        function removeAllListeners(obj)
            while ~isempty(obj.Listeners)
                delete(obj.Listeners(1));
                obj.Listeners(1) = [];
            end
        end
    end

    methods (Access = private)
        function p = getParentHandler(obj)
            p = [];
            if isprop(obj.Parent, 'Parent') 
                if isprop(obj.Parent.Parent, 'Handler')
                    p = obj.Parent.Parent.Handler;
                end 
            end
        end
    end
end 