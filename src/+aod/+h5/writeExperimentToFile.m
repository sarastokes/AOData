function writeExperimentToFile(hdfName, obj, overwriteFlag)
% Writes a full experiment to an HDF5 file
%
% Description:
%   Handles persists an experiment to an HDF5 file
%
% Syntax:
%   aod.h5.writeExperimentToFile(hdfName, obj, overwriteFlag)
%
% Inputs:
%   hdfName             char
%       Name of the HDF5 file to be written. If path is not specified, the 
%       file will be written to the current directory
%   obj                 aod.core.Experiment
%       Experiment to write
%   overwriteFlag       logical (default = false)
%       Whether to overwrite existing HDF5 file with same name/location
%
% Outputs:
%   N/A
%
% See Also:
%   loadExperiment, aod.h5.writeEntity

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------
    arguments
        hdfName                  
        obj                     {mustBeA(obj, 'aod.core.Experiment')}
        overwriteFlag           logical = false
    end

    if isfile(hdfName) && ~overwriteFlag
        error('writeExperimentToFile:FileExists',...
            'File %s exists, set overwriteFlag to true to rewrite', hdfName);
    end
    
    % Create the file
    h5tools.createFile(hdfName, overwriteFlag);

    % Add info about the environment in which the AOData file was created
    h5tools.writeatt(hdfName, '/', aod.infra.getAODataEnv());
    h5tools.writeatt(hdfName, '/', 'FileCreated', string(datetime('now')),...
        'LastModified', string(datetime('now')));
    
    % Write the experiment first
    aod.h5.writeEntity(hdfName, obj);
    
    % Add the Systems and children Channels and Devices
    if ~isempty(obj.Systems)
        for i = 1:numel(obj.Systems)
            aod.h5.writeEntity(hdfName, obj.Systems(i));
            if ~isempty(obj.Systems(i).Channels)
                for j = 1:numel(obj.Systems(i).Channels)
                    aod.h5.writeEntity(hdfName, obj.Systems(i).Channels(j));
                    if ~isempty(obj.Systems(i).Channels(j))
                        for k = 1:numel(obj.Systems(i).Channels(j).Devices)
                            aod.h5.writeEntity(hdfName, obj.Systems(i).Channels(j).Devices(k));
                        end
                    end
                end
            end
        end
    end
    
    % TODO: There must be some sorting algorithm for this
    if ~isempty(obj.Sources)
        for i = 1:numel(obj.Sources)
            aod.h5.writeEntity(hdfName, obj.Sources(i));
            if ~isempty(obj.Sources(i).Sources)
                for j = 1:numel(obj.Sources(i).Sources)
                    aod.h5.writeEntity(hdfName, obj.Sources(i).Sources(j));
                    if ~isempty(obj.Sources(i).Sources(j))
                        for k = 1:numel(obj.Sources(i).Sources(j).Sources)
                            aod.h5.writeEntity(hdfName, obj.Sources(i).Sources(j).Sources(k));
                        end
                    end
                end
            end
        end
    end
    
    % Write annotations
    if ~isempty(obj.Annotations)
        for i = 1:numel(obj.Annotations)
            aod.h5.writeEntity(hdfName, obj.Annotations(i));
        end
    end
    
    % Write the calibrations
    if ~isempty(obj.Calibrations)
        for i = 1:numel(obj.Calibrations)
            aod.h5.writeEntity(hdfName, obj.Calibrations(i));
        end
    end

    % Write the experiment datasets
    if ~isempty(obj.ExperimentDatasets)
        for i = 1:numel(obj.ExperimentDatasets)
            aod.h5.writeEntity(hdfName, obj.ExperimentDatasets(i));
        end
    end
    
    % Write the epochs and their stimuli, registrations, responses, datasets
    for i = 1:numel(obj.Epochs)
        aod.h5.writeEntity(hdfName, obj.Epochs(i));

        if ~isempty(obj.Epochs(i).Registrations)
            for j = 1:numel(obj.Epochs(i).Registrations)
                aod.h5.writeEntity(hdfName, obj.Epochs(i).Registrations(j));
            end
        end
        if ~isempty(obj.Epochs(i).Stimuli)
            for j = 1:numel(obj.Epochs(i).Stimuli)
                aod.h5.writeEntity(hdfName, obj.Epochs(i).Stimuli(j));
            end
        end
    
        if ~isempty(obj.Epochs(i).Responses)
            for j = 1:numel(obj.Epochs(i).Responses)
                aod.h5.writeEntity(hdfName, obj.Epochs(i).Responses(j));
            end
        end
    
        if ~isempty(obj.Epochs(i).EpochDatasets)
            for j = 1:numel(obj.Epochs(i).EpochDatasets)
                aod.h5.writeEntity(hdfName, obj.Epochs(i).EpochDatasets(j));
            end
        end
    end
    
    % Write analysis
    if ~isempty(obj.Analyses)
        for i = 1:numel(obj.Analyses)
            aod.h5.writeEntity(hdfName, obj.Analyses(i));
        end
    end
    