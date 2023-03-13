classdef (Abstract) StackedFilterQuery < aod.api.FilterQuery
% A FilterQuery targeting related entities which can be filtered (abstract)
%
% Parent:
%   aod.api.FilterQuery
%
% Constructor:
%   obj = aod.api.StackedFilterQuery(parent, varargin)
% 
% See also:
%   aod.api.ParentFilter

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        Filters             
        filterIdx           logical  
    end

    properties (Dependent)
        % Does the filter have sub-filters
        isStacked
        % Number of sub-filters
        numFilters
    end

    methods
        function obj = StackedFilterQuery(parent, varargin)
            obj@aod.api.FilterQuery(parent);

            if nargin > 1
                obj.addFilter(varargin{:});
            end
        end

        function value = get.isStacked(obj)
            value = ~isempty(obj.Filters);
        end

        function value = get.numFilters(obj)
            if isempty(obj.Filters)
                value = 0;
            else
                value = numel(obj.Filters);
            end
        end

        function addFilter(obj, varargin)
            for i = 1:numel(varargin)
                if isSubclass(varargin{i}, 'aod.api.FilterQuery')
                    newFilter = varargin{i};
                elseif iscell(varargin{i})
                    newFilter = aod.api.FilterTypes.makeNewFilter(obj, varargin{i});
                else 
                    error('addFilter:InvalidInput',...
                        'New filter must be a cell or aod.api.FilterQuery');
                end 
                % Catch multi-level stacking
                if isSubclass(newFilter, 'aod.api.StackedFilterQuery')
                    if newFilter.isStacked 
                        error('addFilter:DoubleStackedFilter',...
                            'StackedFilters cannot contain other StackedFilters');
                    end
                end
                obj.Filters = cat(1, obj.Filters, newFilter);
            end
        end
    end
end 