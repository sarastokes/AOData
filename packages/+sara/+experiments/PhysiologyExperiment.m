classdef PhysiologyExperiment < sara.Experiment

    properties (Transient, SetAccess = protected)
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
        function obj = PhysiologyExperiment(name, homeDirectory, expDate, varargin)
            obj = obj@sara.Experiment(name, homeDirectory, expDate, varargin{:});
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

        function [data, t] = getStimulusDff(obj, stimName, varargin)
            
            % Search for average input
            idx = find(cellfun(@(x) strcmp(x, 'Average'), varargin));
            args = varargin;
            if isempty(idx)
                averageFlag = false;
            else
                averageFlag = cell2mat(args(idx+1));
                args([idx,idx+1]) = [];
            end

            ep = obj.stim2epochs(stimName);
            if isempty(ep)
                data = []; t = [];
                return
            end
            data = [];
            for i = 1:numel(ep)
                R = ep(i).getDff(args{:});
                data = cat(3, data, R.Data);
            end
            if numel(ep) > 1 && averageFlag
                data = mean(data, 3);
            end
            t = R.Timing.Time;
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
                stim = ep.get('Stimulus', {'Subclass', 'aod.builtin.stimuli.VisualStimulus'});
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
            nSpatial = numel(unique(obj.stimLog.Stimulus(obj.stimLog.Type == "SPATIAL")));
            stimNames = [...
                unique(obj.stimLog.Stimulus(obj.stimLog.Type == "SPATIAL"));...
                unique(obj.stimLog.Stimulus(obj.stimLog.Type == "SPECTRAL"))];
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
            value = [obj.Sources.label, '_', char(obj.experimentDate)];
        end
    end
end