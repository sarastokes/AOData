classdef Persistor < handle
% Manages persistence to an existing HDF5 file
%
% Description:
%   Serves as interface between AOData and an HDF5 file
%
% Constructor:
%   obj = aod.persistent.Persistor(hdfName)
%
% Inputs:
%   hdfName         char
%       AOData HDF5 file name and path
%
% Events:
%   EntityChanged       --> aod.persistent.EntityFactory

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        readOnly        logical
    end

    properties (Access = private)
        hdfName
        UUIDs
    end

    events
        EntityChanged
    end

    methods
        function obj = Persistor(hdfName)
            obj.hdfName = hdfName;
            obj.readOnly = true;
        end
        
        function setReadOnly(obj, value)
            arguments
                obj
                value           logical = true
            end
            obj.readOnly = value;
        end
    end

    methods
        function bind(obj, entity)
            obj.UUIDs = cat(1, obj.UUIDs, string(entity.UUID));
            addlistener(entity, 'AttributeChanged', @obj.onAttChanged);
            addlistener(entity, 'DatasetChanged', @obj.onDatasetChanged);
            addlistener(entity, 'GroupChanged', @obj.onGroupChanged);
            addlistener(entity, 'LinkChanged', @obj.onLinkChanged);
            addlistener(entity, 'FileChanged', @obj.onFileChanged);
        end
    end

    methods (Access = protected)
        function onAttChanged(obj, src, evt)
            % Callback for changes to an entity's group attributes
            %
            % Syntax:
            %   onAttChanged(obj, src, evt)
            % ----------------------------------------------------------
            if isempty(evt.Value)
                % Remove attribute
                h5tools.deleteAttribute(obj.hdfName, src.hdfPath, evt.Name);
            else % Add/change attribute
                h5tools.writeatt(obj.hdfName, src.hdfPath, evt.Name, evt.Value);
            end
        end

        function onLinkChanged(obj, src, evt)
            % Callback for changes to a softlink 
            %
            % Syntax:
            %   onLinkChanged(obj, src, evt)
            % ----------------------------------------------------------
            if isempty(evt.Value)
                % Link removed
                h5tools.deleteObject(obj.hdfName, char(src.hdfPath));
            end
        end

        function onGroupChanged(obj, src, evt)
            % Callback for changes to an entity reflecting an HDF5 group
            %
            % Syntax:
            %   onGroupChanged(obj, src, evt)
            % ----------------------------------------------------------

            % Get entity information prior to changes
            containerName = evt.Entity.entityType.persistentParentContainer();
            hdfPath = char(src.hdfPath);
            parent = evt.Source;
            if ~isempty(evt.OldEntity)
                previousUUID = evt.OldEntity.UUID;
            else
                previousUUID = [];
            end

            % Make the change in the underlying HDF5 file
            if strcmp(evt.Action, 'Add')
                aod.h5.writeEntity(obj.hdfName, evt.Entity);
            elseif strcmp(evt.Action, 'Remove')
                h5tools.deleteObject(obj.hdfName, hdfPath);
            elseif strcmp(evt.Action, 'Replace')
                h5tools.deleteObject(obj.hdfName, parent.hdfPath,...
                    h5tools.util.getPathEnd(hdfPath));
                aod.h5.writeEntity(obj.hdfName, evt.NewEntity);
                h5writeatt(obj.hdfName, hdfPath, 'UUID', uuid);
            end

            % Ensure the change is reflected in EntityFactory
            evtData = aod.persistent.events.EntityEvent(...
                evt.Action, previousUUID);
            notify(obj, 'EntityChanged', evtData);

            % Refresh the associated EntityContainer
            parent.(containerName).refresh();
        end

        function onDatasetChanged(obj, src, evt)
            % Callback for changes to property reflecting an HDF dataset
            %
            % Syntax:
            %   onDatasetChanged(obj, src, evt)
            % ----------------------------------------------------------
            fullPath = h5tools.util.buildPath(src.hdfPath, evt.Name);
            if isempty(evt.NewValue)
                % Dataset should be deleted
                h5tools.deleteObject(obj.hdfName, fullPath, evt.Name);
            elseif ~h5tools.exist(obj.hdfName, fullPath) 
                % Dataset does not yet exist
                aod.h5.write(obj.hdfName, src.hdfPath, evt.Name, evt.NewValue);
            else  
                % Dataset exists and should be overwritten
                aod.h5.write(obj.hdfName, src.hdfPath, evt.Name, evt.NewValue);
            end
        end

        function onFileChanged(obj, ~, evt)
            % Callback for changes to "files" property
            %
            % Syntax:
            %   onFileChanged(obj, src, evt)
            % ----------------------------------------------------------
            filePath = h5tools.util.buildPath(evt.Source.hdfPath, 'files');
            if isempty(evt.Value)
                % Remove file
                h5tools.deleteAttribute(obj.hdfName, filePath, evt.Name);
            else % Add/change file
                h5tools.writeatt(obj.hdfName, filePath, evt.Name, evt.Value);
            end
        end
    end
end