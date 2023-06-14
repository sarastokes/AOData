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
% Properties:
%   readOnly            logical
%       Whether persisted experiment is read-only or not
%
% Events:
%   EntityChanged       --> aod.persistent.EntityFactory
%   HdfPathChanged      --> aod.persistent.EntityFactory
% Subscriptions:
%   AttributeChanged    <-- aod.persistent.Entity
%   DatasetChanged      <-- aod.persistent.Entity
%   FileChanged         <-- aod.persistent.Entity
%   GroupChanged        <-- aod.persistent.Entity
%   LinkChanged         <-- aod.persistent.Entity

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    events
        % Triggered when a full HDF5 group (entity) is changed
        EntityChanged
        % Triggered when an HDF5 path changes due to group name change
        HdfPathChanged
    end

    properties (SetAccess = private)
        hdfName             string
        readOnly            logical
        listeners           event.listener
        UUIDs               string
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
            obj.listeners = cat(1, obj.listeners, [...
                addlistener(entity, 'AttributeChanged', @obj.onAttChanged),...
                addlistener(entity, 'DatasetChanged', @obj.onDatasetChanged),...
                addlistener(entity, 'GroupChanged', @obj.onGroupChanged),...
                addlistener(entity, 'LinkChanged', @obj.onLinkChanged),...
                addlistener(entity, 'FileChanged', @obj.onFileChanged),...
                addlistener(entity, 'NameChanged', @obj.onNameChanged)]);
        end

        function unbind(obj, entity)
            idx = find(obj.UUIDs == entity.UUID);
            % Remove the entity's listeners
            delete(obj.listeners(idx, :))
            % Remove the UUID from the UUID list
            obj.UUIDs(idx) = [];
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

        function onNameChanged(obj, src, evt)
            oldPath = src.hdfPath;
            parentPath = h5tools.util.getPathParent(src.hdfPath);
            newPath = h5tools.util.buildPath(parentPath, evt.Name);

            % Change the entity name
            h5tools.move(obj.hdfName, oldPath, newPath);
            
            % Ensure the change is reflected in EntityFactory
            evtData = aod.persistent.events.HdfPathEvent(...
                src, oldPath, newPath);
            notify(obj, 'HdfPathChanged', evtData);
        end

        function onLinkChanged(obj, src, evt)
            % Callback for changes to a softlink 
            %
            % Syntax:
            %   onLinkChanged(obj, src, evt)
            % ----------------------------------------------------------
            linkPath = h5tools.util.buildPath(src.hdfPath, evt.Name);
            fprintf('onLinkChanged: processing %s\n', linkPath);

            if isempty(evt.Value)
                % Link removed
                h5tools.deleteObject(obj.hdfName, h5tools.util.buildPath(... 
                    src.hdfPath, evt.Name));
            else
                try 
                    %! Use exists instead of try/catch
                    h5tools.writelink(obj.hdfName,...
                        src.hdfPath, evt.Name, evt.Value.hdfPath);
                catch
                    % As far as` I can find, there's no way to change an 
                    % existing softlink so pull metadata, delete, recreate
                    h5tools.deleteObject(obj.hdfName, linkPath);
                    % Recreate the link and add original attributes
                    h5tools.writelink(obj.hdfName,...
                        src.hdfPath, evt.Name, evt.Value.hdfPath);
                end
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
            parent = evt.Entity.Parent;

            % Make the change in the underlying HDF5 file
            if strcmp(evt.Action, 'Add')
                aod.h5.writeEntity(obj.hdfName, evt.Entity);
                % TODO: Reload?
            elseif strcmp(evt.Action, 'Remove')
                % Check for links to the group
                linkLocations = obj.checkGroupLinks(hdfPath);
                if ~isempty(linkLocations)
                    disp(linkLocations)
                    error("onGroupChanged:EntityIsALinkTarget",...
                    "Group to be removed is a target to %u links", numel(linkLocations));
                end

                % Remove if safe
                h5tools.deleteObject(obj.hdfName, hdfPath);
            elseif strcmp(evt.Action, 'Replace');
                newObj = evt.NewEntity;
                oldObj = evt.Entity;
                
                % Update atttribute properties
                if ~strcmp(newObj.label, oldObj.label)
                    h5writeatt(obj.hdfName, hdfPath, 'label', newObj.label);
                end
                if ~strmcp(newObj.description, oldObj.description)
                    h5writeatt(obj.hdfName, hdfPath, 'description', newObj.description);
                end
                if ~isa(newObj, oldObj.coreClassName);
                    h5writeatt(obj.hdfName, hdfPath, 'Class', class(newObj));
                end
                h5writeatt(obj.hdfName, hdfPath, 'dateCreated', newObj.dateCreated);

                % Update specifications
                if ~isequal(newObj.expectedDatasets, oldObj.expectedDatasets)
                    aod.h5.writeExpectedDatasets(obj.hdfName, hdfPath,... 
                        'expectedDatasets', newObj.expectedDatasets);
                end
                if ~isequal(newObj.expectedAttributes, oldObj.expectedAttributes)
                    aod.h5.writeExpectedAttributes(obj.hdfName, hdfPath,...
                        'expectedAttributes', newObj.expectedAttributes);
                end

                % Final steps below aren't needed
                return 
            end

            % Ensure the change is reflected in EntityFactory
            evtData = aod.persistent.events.EntityEvent(...
                evt.Action, evt.Entity);
            notify(obj, 'EntityChanged', evtData);

            % Refresh the associated EntityContainer
            parent.(containerName).refresh();

            % Warn user to close out of applications that do not update
            %if strcmp(evt.Action, 'Add')
            %    warning('onGroupChanged:AdditionWarning',...
            %        'Entity added - changes will not be reflected in existing AODataViewer apps');
            %end
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

    methods (Access = private)
        function linkLocations = checkGroupLinks(obj, hdfPath)
            T = aod.h5.collectExperimentLinks(obj.hdfName);
            if ismember(T.Target, hdfPath)
                linkLocations = T{T.Target == hdfPath, "Location"};
            else
                linkLocations = [];
            end
        end
    end
end