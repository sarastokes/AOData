classdef Physiology < patterson.Dataset

    properties (SetAccess = protected)
        location

        stimTable
    end

    methods
        function obj = Physiology(homeDirectory, expDate, location)
            obj = obj@patterson.Dataset(homeDirectory, expDate);
            if nargin < 3
                obj.location = 'Unknown';
            else
                obj.location = capitalize(location);
            end
        end
    end

    methods
        function epochs = stim2epochs(obj, stimName)
            if ischar(stimName)
                stimName = string(stimName);
            end
            % Check the stimulus name first
            idx = obj.stimTable.Stimulus == stimName;
            % Then try protocol name, if necessary
            if isempty(idx)
                idx = obj.stimTable.Protocol == stimName;
            end
            if ~isempty(idx)
                epochs = obj.Epochs(idx);
            else
                epochs = [];
            end
        end

        function setStimTable(obj)
            % SETSTIMTABLE
            % 
            % Syntax:
            %   obj.setStimTable()
            %
            % Todo: Revisit to decide who/when calls this fcn
            % -------------------------------------------------------------
            protocols = "";
            stimNames = "";
            for i = 1:obj.numEpochs
                ep = obj.id2epoch(obj.epochIDs(i));
                if ep.epochType == patterson.EpochTypes.Spatial
                    stim = ep.getStimulus('aod.builtin.stimuli.SpatialStimulus');
                end
                protocols = cat(1, protocols, string(stim.protocolName));
                stimNames = cat(1, stimNames, string(stim.displayName));
            end

            obj.stimTable = table(obj.epochIDs', stimNames(2:end), protocols(2:end),...
                'VariableNames', {'ID', 'Stimulus', 'Protocol'});

        end
    end

    methods (Access = protected)
        function value = getDisplayName(obj)
            value = ['MC', int2fixedwidthstr(num2str(obj.Source.ID), 5),...
                '_', obj.Source.whichEye,...
                obj.location(1), '_', char(obj.experimentDate)];
        end

        function value = getShortName(obj)
            value = [num2str(obj.Source.ID), '_', obj.Source.whichEye,...
                obj.location(1), '_', char(obj.experimentDate)];
        end
    end
end