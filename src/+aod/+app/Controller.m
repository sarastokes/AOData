classdef (Abstract) Controller < aod.app.UIView
% Controller for Model-View-Controller pattern
%
% Notes:
%   Quick modification of View from Presenter-View, likely doesn't fully 
%   conform to expectations of a "Controller", but it gets the job done

    properties (SetAccess = private)
        Model 
    end

    properties (SetAccess = private)
        listeners
    end

    methods 
        function obj = Controller(model)
            obj@aod.app.UIView();

            obj.Model = model;
            obj.listeners = {};

            % These settings from UIView assume interaction w/ a Presenter
            obj.figureHandle.CloseRequestFcn = @obj.onFigureClose;
            obj.figureHandle.KeyPressFcn = [];

            obj.go();
        end
    end

    methods 
        function go(obj)
            obj.willGo();
            obj.bind();
            obj.show();
        end

        function stop(obj)
            obj.unbind();
            obj.close();
        end
    end

    % Listener methods
    methods (Access = protected)
        
        function willGo(obj) %#ok<MANU> 
            % Operations performed before showing the created UI
            %
            % Notes:
            %   createUi() is run from aod.core.UIView constructor, then 
            %   the Controller constructor is run, followed by go(). Any 
            %   aspects of the UI requiring Model must be performed here. 
        end

        function bind(obj) %#ok<MANU> 
            % Add listeners for relevant Model events
        end

        function unbind(obj)
            obj.removeAllListeners();
        end
        
        function l = addListener(obj, varargin)
            l = addlistener(varargin{:});
            obj.listeners{end + 1} = l;
        end

        function removeListener(obj, listener)
            index = cellfun(@(l)l == listener, obj.listeners);
            delete(listener);
            obj.listeners(index) = [];
        end

        function removeAllListeners(obj)
            while ~isempty(obj.listeners)
                delete(obj.listeners{1});
                obj.listeners(1) = [];
            end
        end

    end

    methods (Access = protected)
        function onFigureClose(obj, ~, ~)
            obj.stop();
        end
    end
end