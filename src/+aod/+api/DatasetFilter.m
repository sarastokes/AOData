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
        Name 
        Value
    end

    properties (SetAccess = private)
        allDatasetNames
    end

    methods
        function obj = DatasetFilter(parent, name, value)
            obj@aod.api.FilterQuery(parent);
            
            obj.Name = name;
            if nargin > 2
                obj.Value = value;
            end

            obj.collectDatasets();
        end

        function out = apply(obj)
            % Update local match indices to match those in Query Manager
            obj.localIdx = obj.Parent.filterIdx;

            % First filter by whether the entities have the dataset
            for i = 1:numel(obj.Parent.allGroupNames)
                groupDsets = obj.getGroupDatasets(obj.Parent.allGroupNames(i));
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
            for i = 1:numel(obj.allGroupNames)
                if obj.localIdx(i)
                    out = aod.h5.read(obj.hdfName, obj.Parent.allGroupNames(i), obj.Name);

                    if isa(obj.Value, 'function_handle')
                        obj.localIdx = obj.Value(out);
                    else
                        obj.localIdx = isequal(out, obj.Value);
                    end
                end
            end

            if nnz(obj.filterIdx) == 0
                warning('apply:NoMatches',...
                    'No datasets named %s matched provided value', obj.dsetName);
            end
            out = obj.localIdx;
        end
    end
    
    methods (Access = protected)
        function collectDatasets(obj)
            obj.allDatasetNames = string.empty();
            for i = 1:numel(obj.Parent.hdfName)
                obj.allDatasetNames = cat(1, obj.allDatasetNames,...
                    h5tools.collectDatasets(obj.Parent.hdfName(i)));
            end
        end

        function groupDsets = getGroupDatasets(obj, groupName)
            gOrder = h5tools.util.getPathOrder(groupName);
            groupDsets = string.empty();
            idx = find(startsWith(obj.allDatasetNames, groupName) ...
                & h5tools.util.getPathOrder(obj.allDatasetNames) == gOrder+1);
            
            if isempty(idx)
                return 
            end

            % Extract just the dataset name from the full HDF5 paths
            for i = 1:numel(idx)
                iName = h5tools.util.getPathEnd(obj.allDatasetNames(idx(i)));
                groupDsets = cat(1, groupDsets, iName);
            end
        end
    end
end 