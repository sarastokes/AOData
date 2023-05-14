classdef AODataViewerCache < aod.app.AppCache 

    methods
        function obj = AODataViewerCache()
            obj = obj@aod.app.AppCache();
        end
    end

    methods (Access = protected)
        function app = createUI(obj, hdfName)
            app = AODataViewer(hdfName);
        end
    end
end 