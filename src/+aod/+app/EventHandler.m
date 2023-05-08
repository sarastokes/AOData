classdef EventHandler < handle 
% Handles events with implementation of Chain Of Responsibility pattern
%
% Constructor:
%   obj = aod.app.EventHandler(parent, publisher)


% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        Parent          
        Listeners       
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
    end

    methods (Access = protected)
        function bind(obj, publisher)
            obj.addListener(publisher, 'NewEvent', @obj.handleRequest);
        end

        function l = addListener(obj, varargin)
            l = addlistener(varargin{:});
            obj.Listeners{end + 1} = l;
        end

        function removeListener(obj, listener)
            index = cellfun(@(l) l == listener, obj.Listeners);
            delete(listener);
            obj.Listeners(index) = [];
        end

        function removeAllListeners(obj)
            while ~isempty(obj.Listeners)
                delete(obj.Listeners{1});
                obj.Listeners(1) = [];
            end
        end
    end

    methods %(Access = private)
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