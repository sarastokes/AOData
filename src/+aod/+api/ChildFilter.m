classdef ChildFilter < aod.api.StackedFilterQuery
% Filter entities by child entity 
%
% Parent:
%   aod.api.StackedFilterQuery
%
% Constructor:
%   obj = ChildFilter(parent, childType, varargin)
%
% See also:
%   aod.api.EntityFilter, aod.api.ParentFilter

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties
        % Child entity type
        childType 
        % Array containing parent idx of relevant child entities
        childGroupings
    end 

    methods 
        function obj = ChildFilter(parent, childType, varargin)
            obj@aod.api.StackedFilterQuery(parent, varargin{:});

            obj.childType = aod.core.EntityTypes.get(childType);
        end
    end

    methods
        function tag = describe(obj)
            childTags = describe@aod.api.StackedFilterQuery(obj);
            tag = sprintf("ChildFilter: Type=%s", char(obj.childType));
            tag = tag + newline + childTags;
        end

        function out = apply(obj)
            obj.localIdx = obj.getQueryIdx();
            obj.filterIdx = true(size(obj.localIdx));
            
            entities = obj.getEntityTable();
            groupNames = entities.Path;
            containerName = obj.childType.parentContainer();

            obj.childGroupings = zeros(size(obj.localIdx));

            % If there are filters, run first to find matched entities
            if ~isempty(obj.Filters)
                for i = 1:obj.numFilters
                    out = obj.Filters(i).apply();
                    obj.filterIdx = out;
                end
            end

            for i = 1:numel(obj.localIdx)
                if ~obj.localIdx(i)
                    continue
                end

                % Determine whether entity has child of specified type
                childGroups = groupNames(startsWith(groupNames, ...
                    h5tools.util.buildPath(groupNames(i), containerName)));
                if isempty(childGroups)
                    obj.localIdx(i) = false;
                    continue
                end

                % Only continue if there are extra Filters
                if isempty(obj.Filters)
                    continue 
                end

                % Trim list to only immediate children (pathOrder - 2)
                pathOrder = h5tools.util.getPathOrder(groupNames(i));
                childGroups(h5tools.util.getPathOrder(childGroups) ~= pathOrder + 2) = [];

                % Locate the child groups within the same file
                idx = find(entities.File == entities.File(i) & ismember(groupNames, childGroups));
                obj.childGroupings(idx) = i;

                % Determine if any matched the Filters
                obj.localIdx(i) = any(obj.filterIdx(idx));
            end

            if nnz(obj.localIdx) == 0
                warning('apply:NoMatches',...
                    "No matches for ChildFilter on %s", obj.childType);
            end
            
            out = obj.localIdx;
        end
    end
end 