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
%   applyFilter(obj)
%
% Public methods:
%   names = getMatches(obj)
%
% Protected methods:
%   idx = getQueryIdx(obj)
%   names = getAllGroupNames(obj)
%   hdfName = getFileNames(obj)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        % Filter parent (aod.api.QueryManager, aod.api.StackedFilterQuery)
        Parent
        % Whether query is nested (within another query)
        isNested    logical 
    end

    properties (SetAccess = protected)
        localIdx
    end

    properties (Dependent)
        didFilter
    end

    methods (Abstract)
        out = apply(obj)
    end

    methods
        function obj = FilterQuery(parent)
            arguments
                parent          {mustBeA(parent, ["aod.api.QueryManager", "aod.api.StackedFilterQuery"])}
            end

            obj.Parent = parent;

            obj.isNested = ~isSubclass(obj.Parent, 'aod.api.QueryManager');
        end
        
        function value = get.didFilter(obj)
            value = obj.checkIfFiltered();
        end
    end

    methods
        function groupNames = getMatchedGroups(obj)
            groupNames = obj.getAllGroupNames();
            if obj.didFilter
                groupNames = groupNames(obj.localIdx);
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

        function fileIdx = getFileIdx(obj)
            if obj.isNested
                fileIdx = obj.Parent.getFileIdx();
            else
                fileIdx = obj.Parent.fileIdx;
            end
        end

        function names = getAllGroupNames(obj)
            if obj.isNested
                names = obj.Parent.getAllGroupNames();
            else
                names = obj.Parent.allGroupNames;
            end
        end

        function out = getHdfName(obj, idx)
            out = obj.Parent.getHdfName(idx);
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
