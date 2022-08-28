function writeEntity(hdfName, obj)
% WRITEENTITY
%
% Description:
%   Pipeline for writing aod entities to an HDF5 file
%
% Syntax:
%   writeEntity(hdfName, entity)
% -------------------------------------------------------------------------
    arguments
        hdfName             {mustBeFile}
        obj                 {mustBeA(obj, 'aod.core.Entity')}
    end

    import aod.h5.HDF5
    import aod.core.EntityTypes

    entityType = EntityTypes.get(obj);

    if entityType == EntityTypes.EXPERIMENT
        HDF5.createGroups(hdfName, '/', 'Experiment');
        HDF5.writeatts(hdfName, '/Experiment', 'Class', class(obj));
    end

    persistedProps = aod.h5.getPersistedProperties(obj);
    % Extract out independently set properties
    specialProps = ["Parent", "notes", "UUID", "files", "parameters"];
    persistedProps = setdiff(persistedProps, specialProps);
    % Extract out container properties
    containers = entityType.containers();
    if ~isempty(containers)
        persistedProps = setdiff(persistedProps, containers);
    end

    % Collect UUIDs of entities within the HDF5 file
    EM = aod.h5.EntityManager(hdfName);
    EM.collect();
    EMT = table(EM);

    % Determine class-specific location
    switch entityType 
        case EntityTypes.EXPERIMENT
            hdfPath = '/Experiment';
            parentPath = [];
        case EntityTypes.SOURCE
            if isempty(obj.Parent)
                parentPath = '/Experiment';
            else
                parentPath = getParentPath(EMT, obj.Parent.UUID);
            end
            hdfPath = [parentPath, '/Sources/', char(obj.Name)];
        case EntityTypes.SYSTEM
            hdfPath = ['/Experiment/Systems/', char(obj.Name)];
            parentPath = '/Experiment';
        case EntityTypes.CALIBRATION 
            hdfPath = ['/Experiment/Calibrations/', char(obj.label)];
            parentPath = '/Experiment';
        case EntityTypes.CHANNEL 
            parentPath = getParentPath(EMT, obj.Parent.UUID);
            hdfPath = [parentPath, '/Channels/', char(obj.Name)];
        case EntityTypes.DEVICE
            parentPath = getParentPath(EMT, obj.Parent.UUID);
            hdfPath = [parentPath, '/Devices/', char(obj.label)];
        case EntityTypes.REGION
            hdfPath = ['/Experiment/Regions/', char(obj.label)];
            parentPath = '/Experiment';
        case EntityTypes.EPOCH
            hdfPath = ['/Experiment/Epochs/', char(obj.shortLabel)];
            parentPath = '/Experiment';
        case EntityTypes.REGISTRATION
            parentPath = getParentPath(EMT, obj.Parent.UUID);
            hdfPath = [parentPath, '/Registrations/', char(obj.label)];
        case EntityTypes.STIMULUS
            parentPath = getParentPath(EMT, obj.Parent.UUID);
            hdfPath = [parentPath, '/Stimuli/', char(obj.label)];
        case EntityTypes.DATASET
            parentPath = getParentPath(EMT, obj.Parent.UUID);
            hdfPath = [parentPath, '/Datasets/', char(obj.Name)];
        case EntityTypes.RESPONSE
            parentPath = getParentPath(EMT, obj.Parent.UUID);
            hdfPath = [parentPath, '/Responses/', char(obj.label)];
        otherwise
            error("writeGeneric:UnrecognizedEntity",...
                "Unknown entity: %s", entityType);
    end
    fprintf('\tWriting: %s\n', hdfPath);

    % Create the new group
    HDF5.createGroup(hdfName, hdfPath);

    % Create default subgroups, if necessary
    if ~isempty(containers)
        HDF5.createGroups(hdfName, hdfPath, containers{:});
        for i = 1:numel(containers)
            HDF5.writeatts(hdfName, [hdfPath, '/', containers{i}],... 
                'Class', 'Container');
        end
    end

    % Write entity identifiers
    HDF5.writeatts(hdfName, hdfPath,...
        'UUID', obj.UUID, 'Class', class(obj), 'EntityType', char(entityType));

    % Write parent link, if necessary
    if ~isempty(parentPath)
        HDF5.createLink(hdfName, parentPath, hdfPath, 'Parent');
    end

    % Write description, if exists
    if ~isempty(obj.description)
        HDF5.writeatts(hdfName, hdfPath, 'Description', obj.description);
    end

    % Write parameters, if necessary
    if ~isempty(obj.parameters)
        aod.h5.writeParameters(hdfName, hdfPath, obj.parameters);
    end
    
    % Write file paths, if necessary
    if ~isempty(obj.files)
        fileText = sprintf('%u file paths', numel(obj.files));
        HDF5.makeTextDataset(hdfName, hdfPath, 'Files', fileText);
        aod.h5.writeParameters(hdfName, [hdfPath, '/Files'], obj.files);
    end
    
    % Write remaining properties as datasets
    for i = 1:numel(persistedProps)
        prop = obj.(persistedProps(i));
        if isempty(prop)
            % fprintf('Skipping empty property: %s\n', persistedProps(i));
            continue
        end
        % Write links to other entities
        if isSubclass(prop, 'aod.core.Entity')
            parentPath = getParentPath(EMT, prop.UUID);
            HDF5.createLink(hdfName, parentPath, hdfPath, persistedProps(i));
            continue
        end
        success = aod.h5.writeDatasetByType(hdfName, hdfPath, persistedProps(i), prop);

        if ~success
            error('Unrecognized property %s of type %s', persistedProps(i), class(prop));
        end
    end
end

function parentPath = getParentPath(EMT, parentUUID)
    isEntityInFile(EMT, parentUUID);
    parentPath = char(EMT{EMT.UUID == parentUUID, 'Path'});
end

function tf = doesEntityExist(entity)
    if isempty(entity)
        if nargout == 0
            error('Entity does not exist');
        else
            tf = false;
        end
    else
        tf = true;
    end
end

function tf = isEntityInFile(EMT, UUID)
    if isempty(find(EMT.UUID == UUID)) %#ok<EFIND> 
        if nargout == 0
            error('Entity does not exist in HDF5 file!');
        else
            tf = false;
        end
    else
        tf = true;
    end
end
