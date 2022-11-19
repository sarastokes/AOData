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

    % Determine which properties will be persisted
    persistedProps = aod.h5.getPersistedProperties(obj);
    % Extract out independently set properties
    specialProps = aod.h5.getSpecialProps();
    persistedProps = setdiff(persistedProps, specialProps);
    % Extract out container properties
    containers = entityType.childContainers();
    if ~isempty(containers)
        persistedProps = setdiff(persistedProps, containers);
    end

    % Collect UUIDs of entities within the HDF5 file to locate "Parent"
    if entityType ~= EntityTypes.EXPERIMENT
        EM = aod.h5.EntityManager(hdfName);
        EM.collect();
        parentPath = entityType.parentPath(obj, EM);
        hdfPath = entityType.getPath(obj, EM, parentPath);
    else
        parentPath = [];
        hdfPath = '/Experiment';
    end

    fprintf('Writing %s\n', hdfPath);

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

    % Handle timing
    if isprop(obj, 'Timing') 
        if ~isempty(obj.Timing)
            aod.h5.writeDatasetByType(hdfName, hdfPath, 'Timing', obj.Timing);
        else  % If Timing is empty, check for Parent timing to inherit
            if isprop(obj.Parent, 'Timing') && ~isempty(obj.Parent.Timing)
                HDF5.createLink(hdfName, EM.uuid2path(obj.Timing.UUID), hdfPath, 'Timing');
            end
        end
    end 

    % Write names, if exist
    HDF5.writeatts(hdfName, hdfPath, 'label', obj.label);
    if ~isempty(obj.Name)
        aod.h5.writeDatasetByType(hdfName, hdfPath, 'Name', obj.Name);
    end

    % Write description, if exists
    if ~isempty(obj.description)
        aod.h5.writeDatasetByType(hdfName, hdfPath, 'description', obj.description);
    end

    % Write note(s), if necessary
    if ~isempty(obj.notes)
       aod.h5.writeDatasetByType(hdfName, hdfPath, 'notes', obj.notes);
    end

    % Write parameters, if necessary
    if ~isempty(obj.parameters)
        aod.h5.writeParameters(hdfName, hdfPath, obj.parameters);
    end
    
    % Write file paths, if necessary
    if ~isempty(obj.files)
        h = ancestor(obj, 'aod.core.Experiment');
        HDF5.makeTextDataset(hdfName, hdfPath, 'files', h.homeDirectory);
        aod.h5.writeParameters(hdfName, [hdfPath, '/files'], obj.files);
    end

    % Handle git repository links
    if isprop(obj, 'Code') && ~isempty(obj.Code)
        HDF5.makeTextDataset(hdfName, hdfPath, 'Code',... 
            'Attributes contain git hashes of all registered repositories');
        aod.h5.writeParameters(hdfName, [hdfPath, '/Code'], obj.Code);
    end
    
    % Write remaining properties as datasets
    for i = 1:numel(persistedProps)
        try
            prop = obj.(persistedProps(i));
        catch ME
            if strcmp(ME.identifier, 'MATLAB:class:GetProhibited')
                warning('writeEntityToFile:NoGetAccess',...
                    'Property %s could not be written, get access was not public', prop);
            else
                rethrow(ME);
            end
        end
        if isempty(prop)
            continue
        end
        % Write links to other entities
        if isSubclass(prop, 'aod.core.Entity')
            parentPath = getParentPath(EM.Table, prop.UUID);
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
