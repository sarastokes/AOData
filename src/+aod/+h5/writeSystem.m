function writeSystem(hdfName, obj)

    arguments
        hdfName         char        {mustBeFile}
        obj                         {mustBeA(obj, 'aod.core.System')}
    end

    import aod.h5.HDF5

    % Create group
    HDF5.createGroups(hdfName, '/Experiment/Systems', obj.Name);
    hdfPath = ['/Experiment/Systems/', obj.Name];

    % Create sub-groups
    HDF5.createGroups(hdfName, hdfPath, 'Channels');
    HDF5.writeatts(hdfName, [hdfPath, '/Channels'], 'Class', 'Container');

    % Write entity identifiers
    HDF5.writeatts(hdfName, hdfPath,...
        'UUID', obj.UUID,...
        'Class', class(obj));
    
    % Link to Parent
    HDF5.createLink(hdfName, '/Experiment', hdfPath, 'Parent');

    % Write description, if exists
    if ~isempty(obj.description)
        HDF5.writeatts(hdfName, hdfPath,...
            'Description', obj.description);
    end

    % Write parameters
    if ~isempty(obj.systemParameters)
        HDF5.writeParameters(hdfName, hdfPath, obj.systemParameters);
    end

