classdef UuidFilter < aod.api.FilterQuery
% Filter entities based on UUID
%
% Description:
%   Filter entities in AOData HDF5 file(s) based on UUID
%
% Parent:
%   aod.api.FilterQuery
%
% Constructor:
%   obj = aod.api.UuidFilter(parent, UUID)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        UUID        string
    end

    properties (SetAccess = private)
        allUUIDs    string
    end

    methods
        function obj = UuidFilter(parent, UUID)
            obj@aod.api.FilterQuery(parent);

            obj.UUID = aod.infra.UUID.validate(UUID);

            obj.collectAllUuids();
        end
    end

    % Implementation of FilterQuery abstract methods
    methods
        function tag = describe(obj)
            tag = sprintf("UuidFilter: UUID=%s", value2string(obj.UUID));
        end

        function out = apply(obj)

            % Update local match indices to match those in Query Manager
            obj.localIdx = obj.getQueryIdx();

            idx = strcmpi(obj.allUUIDs, obj.UUID) & obj.localIdx;
            obj.localIdx = idx;

            % Throw a warning if nothing matched the filter
            if nnz(obj.localIdx) == 0
                warning('apply:NoMatches',...
                    'UuidFilter for %s returned no matches', obj.UUID);
            end

            out = obj.localIdx;
        end

        function txt = code(obj, input, output)
            arguments
                obj
                input           string  = "QM"
                output          string  = []
            end

            txt = sprintf("aod.api.UuidFilter(%s, %s)",...
                input, value2string(obj.UUID));
            if ~isempty(output)
                txt = sprintf("%s = %s;", output, txt);
            end
        end
    end

    methods (Access = private)
        function collectAllUuids(obj)
            entities = obj.getEntityTable();
            obj.allUUIDs = entities.UUID;
        end
    end
end