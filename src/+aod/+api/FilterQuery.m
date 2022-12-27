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
%   obj = aod.api.FilterQuery(hdfName)
%
% Abstract methods:
%   applyFilter(obj)
%
% Public methods:
%   names = getMatches(obj)
%
% Protected methods:
%   resetFilterIdx(obj)
%
% TODO: Multiple HDF5 files

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        hdfName
        allGroupNames
    end

    properties (SetAccess = protected)
        filterIdx 
    end

    events
        FilterResetIndex
    end

    methods (Abstract)
        apply(obj)
    end

    methods 
        function obj = FilterQuery(hdfName)
            % FILTERQUERY
            %
            % Constructor:
            %   obj = FilterQuery(hdfName)
            %
            % Inputs:
            %   hdfName             HDF5 file name and path
            % -------------------------------------------------------------
            if nargin == 0
                return
            end

            hdfName = string(hdfName);
            if numel(hdfName) > 1
                warning('FilterQuery:NotYetImplemented',...
                    'Multiple HDF5 file queries not yet implemented');
            end
            obj.hdfName = hdfName;
            obj.populateGroupNames();
            obj.filterIdx = false(size(obj.allGroupNames));
        end

        function names = getMatches(obj)
            % GETMATCHES
            %
            % Description:
            %   Applies filter and returns matching hdf paths
            %
            % Syntax:
            %   names = getMatches(obj)
            % -------------------------------------------------------------
            names = obj.allGroupNames(obj.filterIdx);
        end
    end

    methods (Access = protected)
        function resetFilterIdx(obj)
            % RESETFILTERIDX
            %
            % Description:
            %   Resets index representing filter matches
            %
            % Syntax:
            %   resetFilterIdx(i)
            % -------------------------------------------------------------
            obj.filterIdx = true(size(obj.allGroupNames));
            notify(obj, 'FilterResetIndex');
        end
    end

    methods (Access = ?aod.api.QueryManager)
        function setFilterIdx(obj, idx)
            % SETFILTERIDX
            %
            % Description:
            %   Allows QueryManager to supply filterIdx obtained from 
            %   filters ahead of current FilterQuery obj in queue to 
            %   reduce computational load
            %
            % Syntax:
            %   setFilterIdx(obj, idx) 
            % -------------------------------------------------------------
            assert(numel(idx) == obj.filterIdx,...
                'The provided filter is the wrong size!');
            obj.filterIdx = idx;
        end
    end

    methods (Access = private)
        function populateGroupNames(obj)
            % POPULATEGROUPNAMES
            %
            % Description:
            %   Creates a string array of all groups in the HDF5 file(s)
            %
            % Syntax:
            %   populateGroupNames(obj)
            % -------------------------------------------------------------
            names = h5tools.collectGroups(obj.hdfName);
            containerNames = aod.core.EntityTypes.allContainerNames();
            for i = 1:numel(containerNames)
                names = names(~endsWith(names, containerNames(i)));
            end
            obj.allGroupNames = names;
        end
    end
end