classdef SchemaCollection < aod.schema.Collection
% SCHEMACOLLECTION
%
% Description:
%   Tracks the schemas associated with a given experiment
%
% Constructor:
%   obj = aod.schema.collections.SchemaCollection(experiment)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------
    properties
        Experiment          % aod.core.Experiment, aod.persistent.Experiment
        Schemas             % aod.core.Schema
        entityTypes         % aod.common.EntityTypes % TODO: Needed?
        classUUIDs          string
        classNames          string
    end

    properties (Hidden, SetAccess = protected)
        SCHEMA_OBJECT_TYPE          = aod.schema.SchemaObjectTypes.SCHEMA_COLLECTION
    end

    methods
        function obj = SchemaCollection(expt)
            if nargin > 1 && ~isempty(expt)
                obj.setExperiment(expt);
            end

            obj.populate();
        end
    end

    methods (Access = private)
        function populate(obj)
            obj.Schemas = obj.Experiment.Schema;
            obj.classUUIDs = obj.Experiment.classUUID;
            obj.classNames = string(class(obj.Experiment));
            obj.entityTypes = aod.common.EntityTypes.EXPERIMENT;

            eTypes = getEnumMembers('aod.common.EntityTypes');
            eTypes(eTypes == aod.common.EntityTypes.EXPERIMENT) = [];

            for i = 1:numel(eTypes)
                entities = obj.Experiment.get(eTypes(i));
                if isempty(entities)
                    continue
                end
                UUIDs = arrayfun(@(x) x.classUUID, entities);
                names = arrayfun(@(x) string(class(x)), entities);
                [~, idx] = unique(UUIDs);
                % TODO: Check if others are equal
                for j = 1:numel(idx)
                    obj.Schemas = cat(1, obj.Schemas, entities(idx(j)).Schema);
                    obj.classNames = cat(1, obj.classNames, names(idx(j)));
                    obj.classUUIDs = cat(1, obj.classUUIDs, UUIDs(idx(j)));
                end
                obj.entityTypes = cat(1, obj.entityTypes,...
                    repmat(eTypes(i), [numel(idx), 1]));
            end
        end
    end

    methods (Access = private)
        function setExperiment(obj, expt)
            arguments
                obj
                expt        {aod.util.mustBeEntityType(expt, "EXPERIMENT")}
            end
            obj.Experiment = expt;
        end
    end

    % MATLAB builtin methods
    methods
        function T = table(obj)
            % TABLE  Create a table to search for indices in Schemas
            T = table(obj.classNames, obj.classUUIDs, obj.entityTypes,...
                'VariableNames', {'ClassName', 'ClassUUID', 'EntityType'});
        end
    end
end