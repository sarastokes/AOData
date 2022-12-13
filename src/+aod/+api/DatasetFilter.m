classdef DatasetFilter < aod.api.FilterQuery
% DATASETFILTER
%
% Description:
%   Filter queries on the presence of a dataset or of a dataset matching a
%   specified value
%
% Parent:
%   aod.api.FilterQuery
%
% Constructor:
%   obj = DatasetFilter(hdfName, dsetName)
%   obj = DatasetFilter(hdfName, dsetName, dsetValue)
% -------------------------------------------------------------------------
    properties
        dsetName
        dsetValue

        allDatasetNames
    end

    methods
        function obj = DatasetFilter(hdfName, dsetName, dsetValue)
            obj = obj@aod.api.FilterQuery(hdfName);

            obj.dsetName = dsetName;
            if nargin > 2
                obj.dsetValue = dsetValue;
            end
            obj.collectDatasets();
            obj.apply();
        end
    end

    % Instantiation of abstract methods from FilterQuery
    methods
        function apply(obj)
            obj.resetFilterIdx();
            for i = 1:numel(obj.allGroupNames)
                groupDsets = obj.getGroupDatasets(obj.allGroupNames(i));
                if ismember(obj.dsetName, groupDsets)
                    obj.filterIdx(i) = true;
                else
                    obj.filterIdx(i) = false;
                end
            end
            if nnz(obj.filterIdx) == 0
                warning('DatasetFilter_apply:NoMatches',...
                    'No groups matched dataset name %s', obj.dsetName);
                return
            end

            if ~isempty(obj.dsetValue)
                for i = 1:numel(obj.allGroupNames)
                    if obj.filterIdx(i)
                        out = aod.h5.read(obj.hdfName, obj.allGroupNames(i), obj.dsetName);
                        if out ~= obj.dsetValue
                            obj.filterIdx(i) = false;
                        end
                    end
                end
            end
            if nnz(obj.filterIdx) == 0
                warning('DatasetFilter_apply:NoMatches',...
                    'No datasets named %s matched provided dsetValue', obj.dsetName);
            end
        end
    end

    methods %(Access = private)
        function groupDsets = getGroupDatasets(obj, groupName)
            gOrder = h5tools.util.getPathOrder(groupName);
            groupDsets = string.empty();
            idx = find(startsWith(obj.allDatasetNames, groupName) ...
                & h5tools.util.getPathOrder(obj.allDatasetNames) == gOrder+1);

            if isempty(idx)
                return
            end
            % Extract just the dataset name from the full HDF5 path
            for i = 1:numel(idx)
                iName = h5tools.util.getPathEnd(obj.allDatasetNames(idx(i)));
                groupDsets = cat(1, groupDsets, iName);
            end
        end

        function collectDatasets(obj)
            obj.allDatasetNames = h5tools.collectDatasets(obj.hdfName);
        end
    end
end