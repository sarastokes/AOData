classdef Persistor < handle

    properties (Access = private)
        hdfName
        attributeListeners
        datasetListeners
        fileListeners
        UUIDs
    end

    methods
        function obj = Persistor(hdfName)
            obj.hdfName = hdfName;
        end
    end

    methods
        function bind(obj, entity)
            obj.UUIDs = cat(1, obj.UUIDs, string(entity.UUID));
            obj.attributeListeners = cat(1, obj.attributeListeners,...
                addlistener(entity, 'AttributeChanged', @obj.onAttChanged));
            obj.datasetListeners = cat(1, obj.datasetListeners,...
                addlistener(entity, 'DatasetChanged', @obj.onDatasetChanged));
            obj.fileListeners = cat(1, obj.fileListeners,...
                addlistener(entity, 'FileChanged', @obj.onFileChanged));
        end

        function unbind(obj)
            % TODO not sure this is sufficient
            obj.attributeListeners = [];
            obj.datasetListeners = [];
            obj.fileListeners = [];
        end
    end

    methods (Access = protected)
        function onAttChanged(obj, src, evt)
            % ONATTCHANGED
            %
            % Description:
            %   Processes an attribute change
            %
            % Syntax:
            %   onAttChanged(obj, src, evt)
            % -------------------------------------------------------------
            if isempty(evt.Value)
                % Remove attribute
                aod.h5.HDF5.deleteAttribute(obj.hdfName, src.hdfPath, evt.Name);
            else % Add/change attribute
                aod.h5.writeAttributeByType(obj.hdfName, src.hdfPath, evt.Name, evt.Value);
            end
        end

        function onDatasetChanged(obj, src, evt)
            % ONDATASETCHANGED
            %
            % Description:
            %   Processes a change to a dataset
            %
            % Syntax:
            %   onDatasetChanged(obj, src, evt)
            % -------------------------------------------------------------
            fullPath = aod.h5.HDF5.buildPath(src.hdfPath, evt.Name);
            if isempty(evt.NewValue)
                aod.h5.deleteObject(obj.hdfName, fullPath, evt.Name);
            else
                matClass = h5readatt(obj.hdfName, fullPath, 'Class');
                if ismember(matClass, ["string", "char", "datetime"])
                    aod.h5.writeAttributeByType(obj.hdfName, src.hdfPath, evt.Name, evt.NewValue);
                    return
                end
                if ~isequal(size(evt.NewValue), size(evt.OldValue))
                    aod.h5.deleteObject(obj.hdfName, fullPath, evt.Name);
                end 
                aod.h5.writeDatasetByType(obj.hdfName, src.hdfPath, evt.Name, evt.NewValue);
            end
        end

        function onFileChanged(obj, src, evt)
            % ONFILECHANGED
            %
            % Description:
            %   Processes an file change
            %
            % Syntax:
            %   onFileChanged(obj, src, evt)
            % -------------------------------------------------------------
            filePath = aod.h5.buildPath(obj.hdfPath, 'files');
            if isempty(evt.Value)
                % Remove file
                aod.h5.HDF5.deleteAttribute(obj.hdfName, filePath, evt.Name);
            else % Add/change file
                aod.h5.writeAttributeByType(obj.hdfName, filePath, evt.Name, evt.Value);
            end
        end
    end
end