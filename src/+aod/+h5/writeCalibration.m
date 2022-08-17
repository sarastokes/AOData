function writeCalibration(hdfName, obj)

    arguments
        hdfName         char        {mustBeFile}
        obj                         {mustBeA(obj, 'aod.core.Calibration')}
    end

    import aod.h5.HDF5

    % Create group
    HDF5.createGroups(hdfName, '/Experiment/Calibrations', obj.label);
    hdfPath = ['/Experiment/Calibrations/', obj.label];

    % Write entity identifiers
    HDF5.writeatts(hdfName, hdfPath,...
        'UUID', obj.UUID,...
        'Class', class(obj));

    % Write description, if exists
    if ~isempty(obj.description)
        HDF5.writeatts(hdfName, hdfPath,...
            'Description', obj.description);
    end

    % Write parameters
    if ~isempty(obj.calibrationParameters)
        HDF5.writeParameters(hdfName, hdfPath, obj.calibrationParameters);
    end

    % Write wavelength
    HDF5.writeatts(hdfName, hdfPath, 'wavelength', obj.wavelength);

    % Write calibration date
    HDF5.makeDateDataset(hdfName, hdfPath, 'calibrationDate', obj.calibrationDate);

    % Write setting/value table
    calibrationTable = table(obj.Setting, obj.Value,...
        'VariableNames', {'Setting', 'Value'});
    HDF5.makeCompoundDataset(hdfName, hdfPath, 'Measurements', calibrationTable);
    HDF5.writeatts(hdfName, [hdfPath, '/Measurements'],...
        'settingUnit', obj.settingUnit, 'valueUnit', obj.valueUnit);
    
    % Link to Experiment
    HDF5.createLink(hdfName, '/Experiment', hdfPath, 'Parent');

    % TODO: Write notes