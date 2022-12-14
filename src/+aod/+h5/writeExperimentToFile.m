function writeExperimentToFile(hdfName, obj, overwriteFlag)
% WRITEEXPERIMENTTOFILE
%
% Syntax:
%   writeExperimentToFile(hdfName, overwriteFlag)
%
% History:
%   26Aug2022 - SSP
% -------------------------------------------------------------------------
    arguments
        hdfName                 char 
        obj                     {mustBeA(obj, 'aod.core.Experiment')}
        overwriteFlag           logical = false
    end

    if isfile(hdfName) && ~overwriteFlag
        error('writeExperimentToFile:FileExists',...
            'File %s exists, set overwriteFlag to true to rewrite', hdfName);
    end
    
    % Create the file
    h5tools.createFile(hdfName, overwriteFlag);
    
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
    
        if ~isempty(obj.Epochs(i).Datasets)
            for j = 1:numel(obj.Epochs(i).Datasets)
                aod.h5.writeEntity(hdfName, obj.Epochs(i).Datasets(j));
            end
        end
    end
    
    % Write analysis
    if ~isempty(obj.Analyses)
        for i = 1:numel(obj.Analyses)
            aod.h5.writeEntity(hdfName, obj.Analyses(i));
        end
    end
    