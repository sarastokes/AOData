classdef EntitySearch < handle
% Search entities in an experiment (core interface)
%
% Description:
%   Simulation of AOQuery for core interface. Enables searching entities 
%   of a specifc type with the queries listed below.
%
% Queries:
%   Attribute, Dataset, File, Name, Class, Subclass
%
% Constructor:
%   obj = aod.common.EntitySearch(entityGroup, varargin)
%
% Single line execution:
%   [matches, idx] = aod.common.EntitySearch.go(entityGroup, varargin)
%
% Examples:
%   A comprehensive list of examples is provided in AOQuery's documentation 

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        % Group of entities of the same type to be searched
        Group
        % Index for specifying groups that match query
        filterIdx
    end

    methods
        function obj = EntitySearch(entityGroup, queries)
            arguments 
                entityGroup         {aod.util.mustBeEntity(entityGroup)}
            end

            arguments (Repeating)
                queries             cell
            end

            obj.Group = entityGroup;
            obj.filterIdx = true(size(obj.Group));
            for i = 1:numel(queries)
                obj.queryByType(queries{i});
            end
        end

        function [out, ID] = getMatches(obj)
            % Return group members matching query criteria
            %
            % Syntax:
            %   [out, ID] = getMatches(obj)
            %
            % Outputs:
            %   out                 array of entities
            %       The entities from entityGroup matching query criteria
            %   ID                  integers
            %       The indices of the matching entities in entityGroup 
            % -------------------------------------------------------------
            out = obj.Group(obj.filterIdx);
            ID = find(obj.filterIdx);
        end
    end

    methods (Static)
        function [out, ID] = go(entityGroup, varargin)
            % Create EntitySearch object and return query matches
            %
            % Description:
            %   A shortcut method for skipping the instantiation of the
            %   EntitySearch object and directly returning the matches
            %
            % Syntax:
            %   [out, ID] = aod.common.EntitySearch.go(entityGroup, varargin)
            %
            % Inputs:
            %   entityGroup         array of core entities
            %       A group of entities of one type from the core interface
            %   varargin            one or more queries
            %       Queries within cells (TODO)
            %
            % Outputs:
            %   out                 array of entities
            %       The entities from entityGroup matching query criteria
            %   ID                  integers
            %       The indices of the matching entities in entityGroup 
            % -------------------------------------------------------------

            if isempty(entityGroup)
                out = [];
                return
            end

            if nargin < 2
                warning('go:NoQueries',... 
                    'EntitySearch was not provided a query, returning full group');
                out = entityGroup;
                return
            end
            obj = aod.common.EntitySearch(entityGroup, varargin{:});
            [out, ID] = obj.getMatches();
        end
    end

    methods (Access = protected)
        function queryByType(obj, query)
            % Determine the query to perform 

            queryType = query{1};

            switch char(lower(queryType))
                case 'class'
                    obj.classQuery(query{2:end});
                case 'subclass'
                    obj.subclassQuery(query{2:end});
                case 'name'
                    obj.nameQuery(query{2:end});
                case {'dataset', 'property'}
                    obj.datasetQuery(query{2:end});
                case {'attribute', 'attr'}
                    obj.attributeQuery(query{2:end})
                case {'file'}
                    obj.fileQuery(query{2:end});
            end

            % fprintf('\t%s query returned %u of %u entities\n',... 
            %     queryType, nnz(obj.filterIdx), numel(obj.Group));
        end
    end 

    % Query methods
    methods (Access = protected)
        function classQuery(obj, className)
            % Find entities that are members of specified class
            for i = 1:numel(obj.Group)
                if obj.filterIdx(i)
                    obj.filterIdx(i) = strcmpi(obj.getEntityClass(obj.Group(i)), className);
                end
            end
        end
        
        function subclassQuery(obj, className)
            % Find entities that are members/subclasses of specified class
            for i = 1:numel(obj.Group)
                if obj.filterIdx(i)
                    obj.filterIdx(i) = isSubclass(obj.getEntityClass(obj.Group(i)), className);
                end
            end
        end

        function nameQuery(obj, nameSpec)
            % Find entities by name
            if isa(nameSpec, 'function_handle')
                for i = 1:numel(obj.Group)
                    if obj.filterIdx(i) 
                        obj.filterIdx(i) = nameSpec(obj.Group(i).Name);
                    end
                end
            else
                nameSpec = convertStringsToChars(nameSpec);
                for i = 1:numel(obj.Group)
                    if obj.filterIdx(i) 
                        obj.filterIdx(i) = strcmpi(obj.Group(i).Name, nameSpec);
                    end
                end
            end
        end

        function datasetQuery(obj, dsetName, dsetSpec)
            % Find entities by dataset name and value
            % TODO: datetime comparison
            
            if nargin < 3
                dsetSpec = [];
            end

            for i = 1:numel(obj.Group)
                obj.filterIdx(i) = isprop(obj.Group(i), dsetName);
            end
            
            % Determine whether to continue and test for a specific value
            if isempty(dsetSpec)
                return
            else 
                if ~any(obj.filterIdx)
                    warning('datasetQuery:NoDsetNameMatches',...
                        'No entities were found with datasets named %s', dsetName);
                    return
                end
            end

            % Filter by the value of dsetName
            if isa(dsetSpec, 'function_handle')
                for i = 1:numel(obj.Group)
                    if ~obj.filterIdx(i)
                        continue
                    end
                    obj.filterIdx(i) = dsetSpec(obj.Group(i).(dsetName));
                end
            else
                for i = 1:numel(obj.Group)
                    if ~obj.filterIdx(i)
                        continue
                    end
                    obj.filterIdx(i) = isequal(obj.Group(i).(dsetName), dsetSpec);
                end
            end
        end

        function fileQuery(obj, fileName, fileSpec)
            % Find entities by file name/value
            if nargin < 3
                fileSpec = [];
            end

            % Find the entities with fileName
            for i = 1:numel(obj.Group)
                if obj.filterIdx(i)
                    obj.filterIdx(i) = hasFile(obj.Group(i), fileName);
                end
            end

            % Determine whether to continue and test for a specific value
            if isempty(fileSpec)
                return
            else
                if ~any(obj.filterIdx)
                    warning('fileQuery:NoFileNameMatches',...
                        'No entities were found with the file %s', fileName);
                    return
                end
            end

            % Filter entities with fileName by their values
            if isa(fileSpec, 'function_handle')
                for i = 1:numel(obj.Group)
                    if ~obj.filterIdx(i)
                        continue
                    end

                    try
                        obj.filterIdx(i) = fileSpec(obj.Group(i).getFile(fileName));
                    catch
                        warning('fileQuery:InvalidFileFcn',...
                            'File function for %s was invalid', fileName);
                    end
                end
            else
                for i = 1:numel(obj.Group)
                    if ~obj.filterIdx(i)
                        continue
                    end
                    obj.filterIdx(i) = isequal(obj.Group(i).getFile(fileName), fileSpec);
                end
            end
        end

        function attributeQuery(obj, paramName, paramSpec)
            % Find entities by attribute name/value
            if nargin < 3
                paramSpec = [];
            end

            % Find the entities with paramName
            obj.filterIdx = hasAttr(obj.Group, paramName);

            % Determine whether to continue and test for a specific value
            if isempty(paramSpec)
                return
            else
                if ~any(obj.filterIdx)
                    warning('attributeQuery:NoParamNameMatches',...
                        'No entities were found with the attribute %s', paramName);
                    return
                end
            end

            % Filter by the value of paramName
            if isa(paramSpec, 'function_handle')
                for i = 1:numel(obj.Group)
                    if ~obj.filterIdx(i)
                        continue
                    end
                    try
                        obj.filterIdx(i) = paramSpec(obj.Group(i).getAttr(paramName));
                    catch
                        warning('attributeQuery:InvalidParamFcn',...
                            'attribute function for %s was invalid', paramName);
                    end
                end
            else
                for i = 1:numel(obj.Group)
                    if ~obj.filterIdx(i)
                        continue
                    end
                    obj.filterIdx(i) = isequal(obj.Group(i).getAttr(paramName), paramSpec);
                end
            end
        end
    end

    methods (Static)
        function className = getEntityClass(entity)
            if isSubclass(entity, 'aod.core.Entity')
                className = class(entity);
            elseif isSubclass(entity, 'aod.persistent.Entity')
                className = entity.coreClassName;
            end
        end
    end
end