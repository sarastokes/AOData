classdef PhysiologyExperiment < sara.Experiment

    properties (SetAccess = protected)
        location
        stimLog
        stimTable
    end

    % Dependent properties, for convenience
    properties (Hidden, Dependent)
        visualStimuli
        spectralStimuli
        spatialStimuli

        spectralTable
        spatialTable
    end

    methods
        function obj = PhysiologyExperiment(homeDirectory, expDate, location)
            obj = obj@sara.Experiment(homeDirectory, expDate);
            if nargin < 3
                obj.location = 'Unknown';
            else
                obj.location = capitalize(location);
            end
        end

        function value = get.visualStimuli(obj)
            value = obj.stimTable.Stimulus;
        end

        function value = get.spatialStimuli(obj)
            value = obj.stimTable{obj.stimTable.Type == "Spatial", "Stimulus"};
        end

        function value = get.spectralStimuli(obj)
            value = obj.stimTable{obj.stimTable.Type == "Spectral", "Stimulus"};
        end

        function value = get.spectralTable(obj)
            value = obj.stimTable(obj.stimTable.Type == "Spectral", :);
        end

        function value = get.spatialTable(obj)
            value = obj.stimTable(obj.stimTable.Type == "Spatial", :);
        end
    end

    methods
        function F = getFluorescence(obj, epochID)
            ep = obj.id2epoch(epochID);
            F = ep.getFluorescence();
        end

        function R = getDff(obj, epochID, varargin)
            ep = obj.id2epoch(epochID);
            R = ep.getDff(varargin{:});
        end

        function epochs = stim2epochs(obj, stimName)
            if ischar(stimName)
                stimName = string(stimName);
            end
            % Check the stimulus name first
            idx = find(obj.stimTable.Stimulus == stimName);
            % Then try protocol name, if necessary
            % if isempty(idx)
            %     idx = find(obj.stimTable.Protocol == stimName);
            % end
            if ~isempty(idx)
                ID = cell2mat(obj.stimTable.ID(idx));
                epochs = obj.Epochs(ID);
            else
                warning('No epochs found matching %s', stimName);
                epochs = [];
            end
        end

        function populateStimSummaries(obj)
            % POPULATESTIMSUMMARIES
            % -------------------------------------------------------------
            obj.populateStimLog();
            obj.populateStimTable();
        end
    end

    methods (Access = private)
        function populateStimLog(obj)
            % POPULATESTIMLOG
            % 
            % Syntax:
            %   obj.populateStimLog()
            %
            % TODO: Revisit to decide who/when calls this fcn
            % -------------------------------------------------------------
            protocols = string.empty();
            stimNames = string.empty();
            stimTypes = string.empty();

            for i = 1:obj.numEpochs
                ep = obj.id2epoch(obj.epochIDs(i));
                stim = ep.getStimulus('aod.builtin.stimuli.VisualStimulus');
                stimNames = cat(1, stimNames, string(stim.label));
                stimTypes = cat(1, stimTypes, string(ep.epochType));
                protocols = cat(1, protocols, string(stim.protocolName));
            end

            obj.stimLog = table(obj.epochIDs', stimNames, stimTypes, protocols,...
                'VariableNames', {'Epoch', 'Stimulus', 'Type', 'Protocol'});
        end

        function populateStimTable(obj)
            epochIdx = cell.empty();
            epochIDs = cell.empty();
            nSpatial = numel(unique(obj.stimLog.Stimulus(obj.stimLog.Type == "Spatial")));
            stimNames = [...
                unique(obj.stimLog.Stimulus(obj.stimLog.Type == "Spatial"));...
                unique(obj.stimLog.Stimulus(obj.stimLog.Type == "Spectral"))];
            N = zeros(numel(stimNames), 1);
            stimTypes = string.empty();

            for i = 1:numel(stimNames)
                IDs = find(obj.stimLog.Stimulus == stimNames(i))';
                epochIdx = cat(1, epochIdx, IDs);
                epochIDs = cat(1, epochIDs, obj.epochIDs(IDs));
                N(i) = numel(IDs);
                if i > nSpatial 
                    stimTypes = cat(1, stimTypes, "Spectral");
                else
                    stimTypes = cat(1, stimTypes, "Spatial");
                end
            end

            obj.stimTable = table(stimNames, stimTypes, N, epochIDs, epochIdx,...
                'VariableNames', {'Stimulus', 'Type', 'N', 'Epoch', 'ID'});
        end
    end

    methods (Access = protected)
        function value = getLabel(obj)
            value = ['MC', int2fixedwidthstr(num2str(obj.Sources.getParentID()), 5),...
                '_', obj.Sources(1).whichEye,...
                obj.location(1), '_', char(obj.experimentDate)];
        end

        function value = getShortName(obj)
            value = [num2str(obj.Sources(1).getParentID), '_', ...
                obj.Sources(1).Parent.whichEye,...
                obj.location(1), '_', char(obj.experimentDate)];
        end
    end
end