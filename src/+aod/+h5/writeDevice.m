function hdfPath = writeDevice(hdfName, obj)
    
    arguments
        hdfName         char        {mustBeAFile}
        obj                         {mustBeA(obj, 'aod.core.Channel')}
    end

    import aod.h5.HDF5
    
    % Create group
    channelPath = HDF5.createGroups(hdfName, parentPath, obj.Name);
    hdfPath = [channelPath, '/Devices/', obj.Name];

    % Create subgroups
    calibrationPath = HDF5.createGroups(hdfName, hdfPath, 'Calibrations');
    % TODO: Write calibration links

    % Write entity identifiers
    HDF5.writeatts(hdfName, hdfPath,...
        'UUID', obj.UUID, 'Class', class(obj));
    
    % Link to Parent
    HDF5.createLink(hdfName, channelPath, hdfPath, 'Parent');

    % Write description, if exists
    if ~isempty(obj.description)
        HDF5.writeatts(hdfName, hdfPath, 'description', obj.description);
    end

    % Write parameters
    if ~isempty(obj.deviceParameters)
        HDF5.writeParameters(hdfName, hdfPath, obj.deviceParameters);
    end

    % Write model and manufacturer
    HDF5.writeatts(hdfName, hdfPath,...
        'Model', obj.model, 'Manufacturer', obj.manufacturer);
