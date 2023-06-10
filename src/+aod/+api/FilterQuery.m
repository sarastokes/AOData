classdef (Abstract) FilterQuery < handle & matlab.mixin.Heterogeneous
% A filter for identifying entities (Abstract)
%
% Description:
%   Parent class for filtering entities in an AOData HDF5 file
%
% Parent:
%   handle, matlab.mixin.Heterogeneous
%
% Constructor:
%   obj = aod.api.FilterQuery(queryManager)
%
% Abstract methods:
%   out = apply(obj)
%   tag = describe(obj)
%
% Public methods:
%   names = getMatches(obj)
%
% Protected methods:
%   idx = getQueryIdx(obj)
%   hdfName = getFileNames(obj)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        % Filter parent (aod.api.QueryManager, aod.api.StackedFilterQuery)
        Parent
        % Whether query is nested (within another query)
        isNested        logical 
        % Whether to run the filter
        isEnabled       logical 
    end

    properties (SetAccess = protected)
        localIdx        logical
    end

    properties (SetAccess = protected)
        % Unlike Parent, this is always the QueryManager
        Root
    end

    properties (Dependent)
        didFilter
    end

    methods (Abstract)
        out = apply(obj)
        tag = describe(obj)
        out = code(obj, input, output)
    end

    methods
        function obj = FilterQuery(parent)
            arguments
                parent          {mustBeA(parent, ["aod.api.QueryManager", "aod.api.StackedFilterQuery"])}
            end

            obj.Parent = parent;

            obj.isNested = ~isSubclass(obj.Parent, 'aod.api.QueryManager');
            if obj.isNested 
                obj.Root = obj.Parent.Parent;
            else
                obj.Root = obj.Parent;
            end
            obj.isEnabled = true;
        end
        
        function value = get.didFilter(obj)
            value = obj.checkIfFiltered();
        end
    end

    methods
        function enableFilter(obj)
            obj.isEnabled = true;
        end

        function disableFilter(obj)
            obj.isEnabled = false;
        end
        
        function groupNames = getMatchedGroups(obj)
            entities = obj.getEntityTable();
            if obj.didFilter
                groupNames = entities.Path(obj.localIdx);
            end
        end
    end

    methods (Access = protected)
        function idx = getQueryIdx(obj)
            idx = obj.Parent.filterIdx;
        end

        function hdfNames = getFileNames(obj)
            if obj.isNested
                hdfNames = obj.Parent.getFileNames();
            else
                hdfNames = obj.Parent.hdfName;
            end
        end

        function out = getEntityTable(obj)
            if obj.isNested 
                out = obj.Parent.getEntityTable();
            else
                out = obj.Parent.entityTable;
            end
        end
    end

    methods (Access = protected)
        function tf = checkIfFiltered(obj)
            if isempty(obj.localIdx)
                tf = false;
            elseif nnz(obj.localIdx) == numel(obj.localIdx)
                tf = false;
            else 
                tf = true;
            end
        end
    end
end
