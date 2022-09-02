classdef Persistor < handle

    properties
        hdfName
        attributeListeners
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
            return

            if isempty(evt.Value)
                aod.h5.HDF5.deleteAttribute(obj.hdfFile, evt.hdfPath, evt.Name);
            else
                h5writeatt(obj.hdfFile, evt.hdfPath, evt.Name, evt.Value);
            end
        end
    end

    methods (Access = ?aod.core.persistent.EntityFactory)
    end
end