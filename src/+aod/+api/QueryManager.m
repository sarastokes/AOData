classdef QueryManager < handle
% Handles execution of one or more AOQuery filters
%
% Description:
%   Handles multiple filters and queries
%
% Constructor:
%   obj = aod.api.QueryManager(hdfName)
%
% Public methods:
%   groupNames = getMatches(obj)
%   addFilter(obj, filter)
%   removeFilter(obj, filterID)
%   clearFilters(obj)
%
% Properties:
%   Filters
%   hdfName
%   filterIdx

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        hdfName 
        filterIdx       logical
    end

    properties (SetAccess = protected)
        Filters             = aod.api.FilterQuery.empty()
    end

    methods
        function obj = QueryManager(hdfName)
            obj.hdfName = hdfName;
        end

        function groupNames = getMatches(obj)
            % GETMATCHES
            %
            % Syntax:
            %   groupNames = getMatches(obj)
            %
            % TODO: Specify output type: path, entity, etc
            % -------------------------------------------------------------
            if isempty(obj.Filters)
                groupNames = [];
                return
            end
            groupNames = obj.Filters(1).allGroupNames;
            groupNames = groupNames(obj.filterIdx);
        end

        function addFilter(obj, filterObj)
            % ADDFILTER
            %
            % Syntax:
            %   addFilter(obj, filterObj)
            % -------------------------------------------------------------
            arguments
                obj
                filterObj   {mustBeA(filterObj, 'aod.api.FilterQuery')}
            end

            obj.Filters = cat(1, obj.Filters, filterObj);
            addlistener(filterObj, 'FilterResetIndex', @(h,d)obj.onFilterResetIndex);
            obj.applyFilters();
        end

        function addFilter2(obj, filterType, varargin)
            % ADDFILTER2
            %
            % Description:
            %   Testing a better syntax for filter addition
            %
            % Syntax:
            %   addFilter2(obj, filterType, varargin)
            % -------------------------------------------------------------

            switch lower(filterType)
                case 'parameter'
                    filterObj = aod.api.ParameterFilter(varargin{:});
                case 'entity'
                    filterObj = aod.api.EntityFitler(varargin{:});
                case 'class'
                    filterObj = aod.api.ClassFilter(varargin{:});
                otherwise
                    error('addFilter2:InvalidFilterType',...
                        'Filter type must be parameter, entity or class');
            end
            obj.addFilter(filterObj);
        end

        function removeFilter(obj, ID)
            % REMOVEFILTERS
            %
            % Description:
            %   Remove a specific filter by index
            %
            % Syntax:
            %   removeFilter(obj, ID)
            % -------------------------------------------------------------
            if isempty(obj.Filters)
                error("QueryManager:NoFilters",...
                    "No filters are set, cannot remove Filter %u", ID);
            end

            if ID > numel(obj.Filters) || ID < 1
                error("QueryManager:InvalidFilterID",...
                    "Filter ID %u is outside number of filters: %u",...
                    ID, numel(obj.Filters));
            end

            obj.Filters(ID) = [];
            obj.applyFilters();
        end

        function clearFilters(obj)
            % CLEARFILTERS
            %
            % Syntax:
            %   clearFilters(obj)
            % -------------------------------------------------------------
            obj.Filters = aod.api.Filters.empty();
            obj.filterIdx = [];
        end
    end

    methods (Access = protected)
        function applyFilters(obj)
            % APPLYFILTERS
            %
            % Syntax:
            %   applyFilters(obj)
            % -------------------------------------------------------------
            if isempty(obj.Filters)
                return
            end
            groupNames = obj.Filters(1).allGroupNames;
            obj.filterIdx = true(size(groupNames));
            for i = 1:numel(obj.Filters)
                obj.filterIdx = obj.filterIdx & obj.Filters(i).filterIdx;
            end
        end
    end

    % Callbacks
    methods (Access = private)
        function onFilterResetIndex(obj, src, ~)
            % ONFILTERRESETINDEX
            % -------------------------------------------------------------
            assignin('base', 'src', src);
        end
    end
end