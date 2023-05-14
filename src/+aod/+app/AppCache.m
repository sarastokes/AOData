classdef (Abstract) AppCache < handle

    properties (Access = private)
        Cache 
    end

    methods (Abstract, Access = protected)
        app = createUI(obj, ID, varargin)
    end

    methods
        function obj = AppCache()
            obj.Cache = containers.Map();
        end

        function app = getUI(obj, ID, varargin)
            if obj.Cache.isKey(ID)
                app = obj.Cache(ID);
            else
                app = obj.createUI(ID, varargin{:});
                obj.Cache(ID) = app;
            end
        end

        function removeUI(obj, ID)
            app = obj.Cache(ID);
            delete(app);
            obj.Cache.remove(ID);
        end

        function clearCache(obj)
            k = obj.Cache.keys;
            for i = 1:numel(k)
                obj.removeUI(k{i});
            end
        end
    end

    methods 
        function delete(obj)
            obj.clearCache();
        end
    end
end 