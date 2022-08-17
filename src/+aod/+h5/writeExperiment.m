function writeExperiment(hdfName, obj)

    arguments
        hdfName         char        {mustBeFile}
        obj                         {mustBeA(obj, 'aod.core.Experiment')}
    end

    import aod.h5.HDF5

    % Write entity identifiers
    HDF5.writeatts(hdfName, '/Experiment',...
        'HomeDirectory', obj.homeDirectory,...
        'UUID', obj.UUID,...
        'Class', class(obj));

    % Write description, if exists
    if ~isempty(obj.description)
        HDF5.writeatts(hdfName, '/Experiment',...
            'Description', obj.description);
    end

    % Write experiment parameters
    if ~isempty(obj.experimentParameters)
        aod.h5.writeParameters(hdfName, '/Experiment',...
            obj.experimentParameters);
    end
    
    % Write experiment date
    HDF5.makeDateDataset(hdfName, '/Experiment', 'experimentDate', obj.experimentDate);
    
    % Write epochIDs
    HDF5.makeMatrixDataset(hdfName, '/Experiment', 'epochIDs', obj.epochIDs);

    %% TODO: Write notes