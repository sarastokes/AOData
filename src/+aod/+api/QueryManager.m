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
%   [matches, entityInfo] = filter(obj)
%   tag = describe(obj)
%   addFilter(obj, varargin)
%   removeFilter(obj, filterID)
%
% Notes:
% - QM.addFilter({'Name', 'Right'})

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        Filters             aod.api.FilterQuery
        Experiments         aod.persistent.Experiment
        filterIdx           logical
    end

    properties (SetAccess = private)
        % The HDF5 file name(s) being queried
        hdfName             string
        % Table of entities from experiment EntityManager
        entityTable 
    end

    properties (Dependent)
        % Number of AOData HDF5 files
        numFiles
        % Number of filters
        numFilters
        % Number of entities across files
        numEntities
    end

    methods
        function obj = QueryManager(hdfName)
            if nargin > 0 && ~isempty(hdfName)
                obj.addExperiment(hdfName);
            end
        end
    end

    % Dependent set/get methods
    methods 
        function out = get.numFiles(obj)
            if isempty(obj.Experiments)
                out = 0;
            else
                out = numel(obj.Experiments);
            end
        end

        function out = get.numFilters(obj)
            if isempty(obj.Filters)
                out = 0;
            else
                out = numel(obj.Filters);
            end
        end
        
        function value = get.numEntities(obj)
            if obj.numFiles == 0
                value = 0;
            else
                value = height(obj.entityTable);
            end
        end
    end

    methods 
        function [matches, entityInfo] = filter(obj)
            % Filter entities and return the matches
            %
            % Syntax:
            %   [matches, entityInfo] = filter(obj)
            % -------------------------------------------------------------

            if obj.numFiles == 0
                error("filter:NoExperiments", "Add experiments first");
            end

            if obj.numFilters == 0
                matches = [];  % TODO
                entityInfo = obj.entityTable;
                warning("go:NoFiltersSet", "Add filters first");
            end

            % Reset match indices
            obj.filterIdx = true(height(obj.entityTable), 1);
            
            for i = 1:obj.numFilters
                if ~obj.Filters(i).isEnabled
                    continue 
                end
                obj.Filters(i).apply();
                obj.filterIdx = obj.Filters(i).localIdx;
            end

            idx = find(obj.filterIdx);
            entityInfo = obj.entityTable(idx,:);
            matches = obj.row2entity(idx);
        end

        function tag = describe(obj)
            % Describe the filters in the QueryManager
            %
            % Syntax:
            %   tag = describe(obj)
            % -------------------------------------------------------------

            if isempty(obj.Filters)
                tag = "Empty QueryManager";
                return 
            end

            tag = string.empty();
            for i = 1:numel(obj.Filters)
                tag = tag + obj.Filters(i).describe();
                tag = tag + newline;
            end
        end
    end

    % Experiment methods
    methods
        function addExperiment(obj, expt)
            % Add one or more new experiments to the QueryManager
            %
            % Syntax:
            %   addExperiment(obj, expt)
            %
            % Inputs:
            %   expt        string array or aod.persistent.Experiment
            %       One or more experiments or HDF5 file names
            % -------------------------------------------------------------
            expt = convertCharsToStrings(expt);
            
            for i = 1:numel(expt)
                if isa(expt(i), 'aod.persistent.Experiment')
                    newName = expt(i).hdfFileName;
                    newExpt = expt;
                elseif istext(expt)
                    newName = getFullFile(expt(i));
                    newExpt = loadExperiment(newName);
                else
                    error('QueryManager:InvalidInput',...
                        'Input must be string of HDF file name(s) or array of aod.persistent.Experiment');
                end
                %! Make hdfName dependent?
                %if isempty(obj.hdfName)
                %    obj.hdfName = newName;
                %else
                    obj.hdfName = [obj.hdfName; newName];
                %end
                obj.Experiments = [obj.Experiments; newExpt];
            end
            
            obj.populateEntityTable();
        end

        function removeExperiment(obj, expt)
            if isnumeric(expt)
                ID = expt;
            elseif istext(expt)
                ID = find(obj.hdfName == string(expt));
            end
            % Remove the experiment
            obj.Experiments(ID) = [];
            obj.hdfName(ID) = [];
            % Update the entity table
            obj.populateEntityTable();
        end
    end

    % Filter methods
    methods 
        function addFilter(obj, varargin)
            % Add new filters to the QueryManager
            %
            % Syntax:
            %   addFilter(obj, varargin)
            % -------------------------------------------------------------

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
            % Remove a filter by index
            %
            % Syntax:
            %   removeFilter(obj, idx)
            % -------------------------------------------------------------
            arguments 
                obj 
                idx         {mustBeInteger}
            end

            mustBeInRange(idx, 1, numel(obj.Filters));
            obj.Filters(idx) = [];
        end

        function clearFilters(obj)
            % Clear all filters
            %
            % Syntax:
            %   clearFilters(obj)
            % -------------------------------------------------------------
            obj.Filters = aod.api.FilterQuery.empty();
            % All groups begin as true until determined otherwise
            obj.filterIdx = true(height(obj.entityTable), 1);
        end
    end

    methods (Access = private)
        function populateEntityTable(obj)
            obj.entityTable = [];

            if obj.numFiles == 0
                obj.filterIdx = logical.empty();
                return
            end
            
            for i = 1:obj.numFiles
                T = obj.Experiments(i).factory.entityManager.table;
                T.File = repmat(string(obj.Experiments(i).hdfName), [height(T), 1]);
                obj.entityTable = [obj.entityTable; T];
                obj.filterIdx = true(height(obj.entityTable), 1);
            end
        end

        function entity = row2entity(obj, rowIdx)
            % Get persistent entity correspondng to row in entityTable
            %
            % Syntax:
            %   rowIdx          integer
            %       Row in entityTable
            % ----------------------------------------------------------

            hdfPath = obj.entityTable.Path(rowIdx);
            exptName = obj.entityTable.File(rowIdx);
            expt = obj.Experiments(ismember(obj.hdfName, exptName));
            entity = expt.getByPath(hdfPath);
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
        function [matches, entityInfo] = go(expt, varargin)
            % Create the manager and run the filters in one step
            %
            % Syntax:
            %   [matches, idx] = aod.api.QueryManager(hdfName, varargin)
            % -------------------------------------------------------------

            QM = aod.api.QueryManager(expt);
            QM.addFilter(varargin{:});
            [matches, entityInfo] = QM.filter();
        end
    end
end 