function hdfPath = writeChannel(hdfName, obj)

    arguments
        hdfName         char        {mustBeFile}
        obj                         {mustBeA(obj, 'aod.core.Channel')}
    end

    import aod.h5.HDF5

    % Create group
    systemPath = ['/Experiment/Systems/', obj.Parent.Name];
    channelPath = [systemPath, '/Channels'];
    HDF5.createGroups(hdfName, channelPath, obj.Name);
    hdfPath = [channelPath, '/', obj.Name];

    % Create sub-groups
    HDF5.createGroups(hdfName, hdfPath, 'Devices');
    HDF5.writeatts(hdfName, [hdfPath, '/Devices'], 'Class', 'Container');

    % Write entity identifiers
    HDF5.writeatts(hdfName, hdfPath,...
        'UUID', obj.UUID, 'Class', class(obj));
    
    % Link to Parent
    HDF5.createLink(hdfName, systemPath, hdfPath, 'Parent');

    % Write description, if exists
    if ~isempty(obj.description)
        HDF5.writeatts(hdfName, hdfPath, 'description', obj.description);
    end

    % Write parameters
    if ~isempty(obj.channelParameters)
        aod.h5.writeParameters(hdfName, hdfPath, obj.channelParameters);
    end