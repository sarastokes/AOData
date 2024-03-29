classdef DatasetFilter < aod.api.FilterQuery 
% Filter entities by datasets/properties
%
% Description:
%   Filter queries on the presence of a dataset or of a dataset matching a
%   specified value
%
% Parent:
%   aod.api.FilterQuery
%
% Constructor:
%   obj = aod.api.DatasetFilter(parent, name)
%   obj = aod.api.DatasetFilter(parent, name, value)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        Name            string
        Value
    end

    methods
        function obj = DatasetFilter(parent, name, value)
            obj@aod.api.FilterQuery(parent);
            
            obj.Name = name;
            if nargin > 2 && ~aod.util.isempty(value)
                obj.Value = value;
            end
        end
    end

    methods
        function tag = describe(obj)
            tag = sprintf("DatasetFilter: Name=%s, Value=%s",... 
                value2string(obj.Name), value2string(obj.Value));
        end

        function out = apply(obj)
            % Update local match indices to match those in Query Manager
            obj.localIdx = obj.getQueryIdx();
            
            entities = obj.getEntityTable();

            % First filter by whether the entities have the dataset
            for i = 1:height(entities)
                if ~obj.localIdx(i)
                    continue
                end
                groupDsets = obj.getGroupDatasets(entities.Path(i));
                if ismember(obj.Name, groupDsets)
                    obj.localIdx(i) = true;
                else
                    obj.localIdx(i) = false;
                end
            end  
            out = obj.localIdx;
            
            % Determine whether 2nd round of filtering is necessary
            if nnz(obj.localIdx) == 0
                warning('apply:NoMatches',...
                    'No groups matched dataset name %s', obj.Name);
                return
            elseif isempty(obj.Value)
                return
            end

            % Filter by the dataset value
            for i = 1:height(entities)
                if ~obj.localIdx(i)
                    continue
                end
                out = aod.h5.read(entities.File(i),...
                    entities.Path(i), obj.Name);

                if isa(obj.Value, 'function_handle')
                    obj.localIdx(i) = obj.Value(out);
                else
                    obj.localIdx(i) = isequal(out, obj.Value);
                end
            end

            if nnz(obj.localIdx) == 0
                warning('apply:NoMatches',...
                    'No datasets named %s matched provided value', obj.Name);
            end
            out = obj.localIdx;
        end

        function txt = code(obj, input, output)
            arguments 
                obj 
                input           string  = "QM"
                output          string  = []
            end

            if isempty(obj.Value)
                txt = sprintf("aod.api.DatasetFilter(%s, %s)",... 
                    input, value2string(obj.Name));
            else
                txt = sprintf("aod.api.DatasetFilter(%s, %s, %s)",...
                    input, value2string(obj.Name), value2string(obj.Value));
            end 
            if ~isempty(output)
                txt = sprintf("%s = %s;", output, txt);
            end
        end
    end
    
    methods (Access = protected)
        function groupDsets = getGroupDatasets(obj, groupName)
            gOrder = h5tools.util.getPathOrder(groupName);
            groupDsets = string.empty();
            idx = find(startsWith(obj.Root.allDatasetNames, groupName) ...
                & h5tools.util.getPathOrder(obj.Root.allDatasetNames) == gOrder+1);
            
            if isempty(idx)
                return 
            end

            % Extract just the dataset name from the full HDF5 paths
            for i = 1:numel(idx)
                iName = h5tools.util.getPathEnd(obj.Root.allDatasetNames(idx(i)));
                groupDsets = cat(1, groupDsets, iName);
            end
        end
    end
end 