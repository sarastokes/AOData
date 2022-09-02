classdef Persistor < handle

    properties
        hdfName
        attributeListeners
        datasetListeners
        UUIDs
    end

    methods
        function obj = Persistor(hdfName)
            obj.hdfName = hdfName;
        end

        function bind(obj, entity)
            obj.UUIDs = cat(1, obj.UUIDs, string(entity.UUID));
            obj.attributeListeners = cat(1, obj.attributeListeners,...
                addlistener(entity, 'ChangedAttribute', @obj.onAttChanged));
        end
    end

    methods (Access = protected)
        function onAttChanged(obj, src, evt)
            disp('Notification received')
            assignin('base', 'src', src);
            assignin('base', 'evt', evt);
        end

        function onDatasetChanged(obj, src, evt)
        end
    end

    methods (Access = ?aod.core.persistent.EntityFactory)
        function clearListeners(obj)
            obj.attributeListeners = [];
            obj.datasetListeners = [];
        end
    end
end