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
%   addFilter(obj, varargin)
%   removeFilter(obj, filterID)
%
% Notes:
% - Create QueryManager with HDF5 file input
% - QM.addFilter({'Name', 'Right'})

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        Filters             % aod.api.FilterQuery
        Experiments
        filterIdx           logical
    end

    properties (SetAccess = private)
        % The HDF5 file name(s) being queried
        hdfName             string 
        % All entity group names in the HDF5 file(s)
        allGroupNames       string
        % Which file each group name came from
        fileIdx             double 
    end

    properties (Dependent)
        numFiles
        numFilters
    end

    properties (Hidden, Dependent)
        % allGroupNames with file name appended
        fullGroupNames
    end

    methods
        function obj = QueryManager(hdfName)
            if nargin < 1
                [hdfName, hdfPath] = uigetfile('*.h5',...
                    'Pick AOData HDF5 file(s)',...
                    'MultiSelect', 'on');
                if isequal(hdfName, 0)
                    return
                end
                hdfName = fileparts(hdfPath, hdfName);
            end

            if isa(hdfName, 'aod.persistent.Experiment')
                obj.hdfName = hdfName.hdfFileName;
                obj.Experiments = cat(1, obj.Experiments, hdfName);
            elseif istext(hdfName)
                obj.hdfName = getFullFile(hdfName);
            else
                error('QueryManager:InvalidInput',...
                    'Input must be HDF file name(s) or aod.persistent.Experiment');
            end

            obj.populateGroupNames();
        end
    end

    % Dependent set/get methods
    methods 
        function out = get.numFiles(obj)
            if isempty(obj.hdfName)
                out = 0;
            else
                out = numel(obj.hdfName);
            end
        end

        function out = get.numFilters(obj)
            if isempty(obj.Filters)
                out = 0;
            else
                out = numel(obj.Filters);
            end
        end

        function out = get.fullGroupNames(obj)
            if isempty(obj.allGroupNames)
                out = string.empty();
                return
            end

            fileNames = arrayfun(@(x) fileparts(x), obj.hdfName);
            out = repmat("", [numel(obj.allGroupNames), 1]);
            for i = 1:numel(obj.allGroupNames)
                out(i) = fileNames(obj.fileIdx(i)) + "/" + obj.allGroupNames(i);
            end
        end
    end

    methods 
        function [matches, idx] = filter(obj)
            if isempty(obj.Filters)
                error("go:NoFiltersSet", "Add filters first");
            end

            obj.filterIdx = true(numel(obj.allGroupNames), 1);
            
            for i = 1:obj.numFilters
                obj.Filters(i).apply();
                obj.filterIdx = obj.Filters(i).localIdx;
            end

            idx = find(obj.filterIdx);

            matches = table(...
                obj.hdfName(obj.fileIdx(idx)),...
                obj.allGroupNames(idx),...
                'VariableNames', {'FileName', 'GroupName'});
        end
    end

    % Filter methods
    methods 
        function addFilter(obj, varargin)
            for i = 1:numel(varargin)
                if isSubclass(varargin{i}, 'aod.api.FilterQuery')
                    obj.Filters = cat(1, obj.Filters, varargin{i});
                elseif iscell(varargin{i})
                    input = varargin{i};
                    newFilter = aod.api.FilterTypes.makeNewFilter(obj, input);
                    obj.Filters = cat(1, obj.Filters, newFilter);
                else 
                    error('addFilter:InvalidInput',...
                        'New filter must be a cell or aod.api.FilterQuery');
                end 
            end
        end

        function removeFilter(obj, idx)
            arguments 
                obj 
                idx         {mustBeInteger}
            end

            mustBeInRange(idx, 1, numel(obj.Filters));
            obj.Filters(idx) = [];
        end

        function clearFilters(obj)
            obj.Filters = [];
            % All groups begin as true until determined otherwise
            obj.filterIdx = true(numel(obj.allGroupNames), 1);
        end
    end

    % Utility functions for FilterQuery classes
    methods
        function out = getHdfName(obj, idx)
            mustBeInRange(idx, 1, numel(obj.allGroupNames));
            out = obj.hdfName(obj.fileIdx(idx));
        end
    end

    methods (Access = private)
        function populateGroupNames(obj)
            % Creates a string array of all groups in the HDF5 file(s)
            %
            % Syntax:
            %   populateGroupNames(obj)
            %
            % Assigns:
            %   allGroupNames - HDF5 path names of all non-container groups
            %   filterIdx - all false, size of allGroupNames
            %   fileIdx - integer array indicating which file each group 
            %       name belongs to.
            % -------------------------------------------------------------

            containerNames = aod.core.EntityTypes.allContainerNames();

            obj.allGroupNames = string.empty();
            for i = 1:numel(obj.hdfName)
                names = h5tools.collectGroups(obj.hdfName(i));
                for j = 1:numel(containerNames)
                    names = names(~endsWith(names, containerNames(j)));
                end
                obj.allGroupNames = cat(1, obj.allGroupNames, names);
                obj.fileIdx = cat(1, obj.fileIdx, repmat(i, [numel(names), 1]));
            end
            % All groups begin as true until determined otherwise
            obj.filterIdx = true(numel(obj.allGroupNames), 1);
        end
    end

    % Utility functions
    methods (Static, Access = private)
        function out = extractFileName(fileName)
            % Extracts file name and leaves path/extension
            %
            % Notes:
            %   For use with arrayfun 
            % -------------------------------------------------------------

            [~, out, ~] = fileparts(fileName);
        end
    end

    % Instantiate and run in one line
    methods (Static)
        function [matches, idx] = go(hdfName, varargin)
            QM = aod.api.QueryManager(hdfName);
            QM.addFilter(varargin{:});
            [matches, idx] = QM.filter();
        end
    end
end 