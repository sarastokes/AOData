function out = displayHierarchy(expt)

    arguments
        expt        {mustBeEntityType(expt, 'Experiment')}
    end

    out = "EXPERIMENT: " + expt.label + newline;
    nEpochs = numel(expt.Epochs);
    % out = out + indent(1) + sprintf("EPOCHS: %u", nEpochs) + newline;
    
    
    if ~isempty(expt.Calibrations)
        out = out + indent(1) + sprintf("CALIBRATIONS (%u)",...
            numel(expt.Calibrations)) + newline;
        for i = 1:numel(expt.Calibrations)
            out = out + indent(1) + "- CALIBRATIONS: " + expt.Calibrations(i).label + newline;
        end
    end

    for i = 1:nEpochs 
        out = out + indent(1) + sprintf("EPOCHS (%u)",...
            numel(expt.Epochs)) + newline;
        out = out + indent(2) + "- " + expt.Epochs(i).label + newline;
        for j = 1:numel(expt.Epochs(i).Registrations)
            out = out + indent(3) + "- " ...
                + expt.Epochs(i).Registrations(j).label + newline;
        end
        for j = 1:numel(expt.Epochs(i).Responses)
            out = out + indent(3) + "- "...
                + expt.Epochs(i).Responses(j).label + newline;
        end
        for j = 1:numel(expt.Epochs(i).Stimuli)
            out = out + indent(3) + "- "...
                + expt.Epochs(i).Stimuli(j).label + newline;
        end
    end

    if ~isempty(expt.Analyses)
        out = out + indent(1) + sprintf("ANALYSES (%u)",...
            numel(expt.Analyses)) + newline;
        for i = 1:numel(expt.Analyses)
            out = out + indent(1) + "- " + expt.Analyses(i).label + newline;
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