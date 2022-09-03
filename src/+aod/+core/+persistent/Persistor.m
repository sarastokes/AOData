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
            obj.datasetListeners = cat(1, obj.datasetListeners,...
                addlistener(entity, 'ChangedDataset', @obj.onDatasetChanged));
        end

        function unbind(obj)
            % TODO not sure this is sufficient
            obj.attributeListeners = [];
            obj.datasetListeners = [];
        end
    end

    methods (Access = protected)
        function onAttChanged(obj, src, evt)
            if isempty(evt.Value)
                % Remove attribute
                aod.h5.HDF5.deleteAttribute(obj.hdfName, src.hdfPath, evt.Name);
            else % Add attribute
                aod.h5.writeAttributeByType(obj.hdfName, src.hdfPath, evt.Name, evt.Value);
            end
        end

        function onDatasetChanged(obj, src, evt)
            if isempty(evt.Value)
                % TODO: Remove dataset
            else
                aod.h5.writeDatasetByType(obj.hdfName, src.hdfPath, evt.Name);
            end
        end
    end

    methods (Access = ?aod.core.persistent.EntityFactory)
        function clearListeners(obj)
            obj.attributeListeners = [];
            obj.datasetListeners = [];
        end
    end
end