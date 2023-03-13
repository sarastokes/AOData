classdef ParentFilter < aod.api.StackedFilterQuery 
% Query entities by parent
%
% Parent:
%   aod.api.StackedFilterQuery
%
% Syntax:
%   obj = aod.api.ParentFilter(parent, targetEntityType,... 
%       parentEntityType, varargin)
%
% Example:
%   % Get responses with parent Epoch with epoch ID less than 10
%   PF = aod.api.ParentFilter(QM, 'Response', 'Epoch',... 
%       {'Dataset', 'epochID', @(x) x < 10})

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        targetEntityType
        parentEntityType 
    end

    methods 
        function obj = ParentFilter(parent, targetType, parentType, varargin)
            obj@aod.api.StackedFilterQuery(parent, varargin{:});

            obj.targetEntityType = aod.core.EntityTypes(targetType);
            obj.parentEntityType = aod.core.EntityTypes(parentType);

            if ~ismember(obj.parentEntityType, obj.targetEntityType.validParentTypes())
                error('ParentFilter:InvalidParentType',... 
                    '%s is not a valid parent for %s',...
                    obj.parentEntityType, obj.targetEntityType);
            end
        end
    end

    methods
        function out = apply(obj)
            obj.localIdx = obj.getQueryIdx();
            obj.filterIdx = true(size(obj.localIdx));
            groupNames = obj.getAllGroupNames();

            % Get the entities matching the query
            for i = 1:obj.numFilters
                out = obj.Filters(i).apply();
                obj.filterIdx = out;
            end

            % Run an entity filter 
            EF = aod.api.EntityFilter(obj.Parent, obj.targetEntityType);
            obj.localIdx = EF.apply();

            % Now find the parent group names
            for i = 1:numel(groupNames)
                if ~obj.localIdx(i)
                    continue
                end

                % Get the parent path by stripping off the group name and 
                % the container name
                parentPath = h5tools.util.getPathParent(...
                    h5tools.util.getPathParent(groupNames(i)));
                idx = find(groupNames == parentPath);
                % Set to the value in filterIdx
                obj.localIdx(i) = obj.filterIdx(idx);
            end

            out = obj.localIdx;
        end
    end
end