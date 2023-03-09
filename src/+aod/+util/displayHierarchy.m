function out = displayHierarchy(expt)

    arguments
        expt        {mustBeEntityType(expt, 'Experiment')}
    end

    out = "EXPERIMENT: " + expt.label + newline;
    nEpochs = numel(expt.Epochs);
    % out = out + indent(1) + sprintf("EPOCHS: %u", nEpochs) + newline;
    
    
    if ~isempty(expt.Calibrations)
        out = out + indent(1) + sprintf("- CALIBRATIONS (%u)",...
            numel(expt.Calibrations)) + newline;
        for i = 1:numel(expt.Calibrations)
            out = out + indent(2) + "* " + expt.Calibrations(i).label + newline;
        end
    end

    if ~isempty(expt.Systems)
        out = out + indent(1) + sprintf("- SYSTEMS (%u)",...
            numel(expt.Systems)) + newline;
        for i = 1:numel(expt.Systems)
            out = out + indent(2) + "* " + expt.Systems(i).label + newline;
            if ~isempty(expt.Systems(i).Channels)
                out = out + indent(3) + sprintf("- CHANNELS (%u)",...
                    numel(expt.Systems(i).Channels)) + newline;
                for j = 1:numel(expt.Systems(i).Channels)             
                    out = out + indent(4) + "* " ...
                        + expt.Systems(i).Channels(j).label + newline;
                    if ~isempty(expt.Systems(i).Channels(j).Devices)
                        out = out + indent(5) + sprintf("- DEVICES (%u)",...
                            numel(expt.Systems(i).Channels(j).Devices)) + newline;
                        for k = 1:numel(expt.Systems(i).Channels(j).Devices)
                            out = out + indent(6) + "* " + ...
                                expt.Systems(i).Channels(j).Devices(k).label + newline;
                        end
                    end
                end
            end
        end
    end

    out = out + indent(1) + sprintf("- EPOCHS (%u)",...
        numel(expt.Epochs)) + newline;
    for i = 1:nEpochs 
        out = out + indent(2) + "* " + expt.Epochs(i).label + newline;
        if ~isempty(expt.Epochs(i).EpochDatasets)
            out = out + indent(3) + sprintf("- EPOCHDATASETS (%u)",...
                numel(expt.Epochs(i).EpochDatasets)) + newline;
            for j = 1:numel(expt.Epochs(i).EpochDatasets)
                out = out + indent(4) + "* " ...
                    + expt.Epochs(i).EpochDatasets(j).label + newline;
            end
        end

        if ~isempty(expt.Epochs(i).Registrations)
            out = out + indent(3) + sprintf("- REGISTRATIONS (%u)", ...
                numel(expt.Epochs(i).Registrations)) + newline;
            for j = 1:numel(expt.Epochs(i).Registrations)
                out = out + indent(4) + "* " ...
                    + expt.Epochs(i).Registrations(j).label + newline;
            end
        end
        if ~isempty(expt.Epochs(i).Responses)
            out = out + indent(3) + sprintf("- RESPONSES (%u)",...
                numel(expt.Epochs(i).Responses)) + newline;
            for j = 1:numel(expt.Epochs(i).Responses)
                out = out + indent(4) + "* "...
                    + expt.Epochs(i).Responses(j).label + newline;
            end
        end
        if ~isempty(expt.Epochs(i).Stimuli)
            out = out + indent(3) + sprintf("- STIMULI (%u)",...
                numel(expt.Epochs(i).Stimuli)) + newline;
            for j = 1:numel(expt.Epochs(i).Stimuli)
                out = out + indent(4) + "* "...
                    + expt.Epochs(i).Stimuli(j).label + newline;
            end
        end
    end

    if ~isempty(expt.ExperimentDatasets)
        out = out + indent(1) + sprintf("- EXPERIMENTDATASETS (%u)",...
            numel(expt.ExperimentDatasets)) + newline;
        for i = 1:numel(expt.ExperimentDatasets)
            out = out + indent(2) + "* " + expt.ExperimentDatasets(i).label + newline;
        end
    end

    if ~isempty(expt.Annotations)
        out = out + indent(1) + sprintf("- ANNOTATIONS (%u)",...
            numel(expt.Annotations)) + newline;
        for i = 1:numel(expt.Annotations)
            out = out + indent(2) + "* " + expt.Annotations(i).label + newline;
        end
    end

    if ~isempty(expt.Analyses)
        out = out + indent(1) + sprintf("- ANALYSES (%u)",...
            numel(expt.Analyses)) + newline;
        for i = 1:numel(expt.Analyses)
            out = out + indent(2) + "* " + expt.Analyses(i).label + newline;
        end
    end
end

function out = indent(nTabs)
    if nargin < 1
        nTabs = 1;
    end
    out = repmat('    ', [1, nTabs]);
    out = string(sprintf(out));
end