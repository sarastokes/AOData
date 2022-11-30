classdef EntityGroupSearch < handle
% ENTITYGROUPQUERY
%
% Description:
%   Simulation of AOQuery for core interface
%
% Queries:
%   Parameter, Dataset, File, Name, Class, Subclass
%
% Constructor:
%   obj = EntityGroupSearch(entityGroup, queryType, varargin)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        Group
        queryType
        filterIdx
    end

    properties (Hidden, Constant)
        QUERY_TYPES = ["Class", "Subclass", "Name", "Dataset", "Parameter", "File"];
    end

    methods
        function obj = EntityGroupSearch(entityGroup, queryType, varargin)
            assert(isSubclass(entityGroup, 'aod.core.Entity'),...
                'entityGroup must be a subclass of aod.core.Entity');
            obj.Group = entityGroup;

            % TODO: Repeating queries

            queryType = capitalize(string(queryType));
            assert(ismember(lower(queryType), lower(obj.QUERY_TYPES)),...
                'queryType must be: Class, Subclass, Name, Dataset, Parameter');
            obj.queryType = queryType;

            % Index for specifying groups that match query
            obj.filterIdx = false(size(obj.Group));

            % Perform query
            obj.queryByType(varargin{:});
        end

        function out = getMatches(obj)
            out = obj.Group(obj.filterIdx);
        end
    end
    
    methods (Access = private)
        function classQuery(obj, className)
            arguments
                obj
                className       char
            end

            fprintf('Performing class query for %s\n', className);  
            for i = 1:numel(obj.Group)
                obj.filterIdx(i) = strcmp(class(obj.Group(i)), className);
            end
        end

        function datasetQuery(obj, dsetName, dsetSpec)
            % DATASETQUERY
            arguments
                obj
                dsetName        char
                dsetSpec        = []
            end

            fprintf('Performing dataset query for %s\n', dsetName);
            for i = 1:numel(obj.Group)
                obj.filterIdx(i) = isprop(obj.Group(i), dsetName);
            end
            
            % Determine whether to continue and test for a specific value
            if isempty(dsetSpec)
                return
            else 
                if ~any(obj.filterIdx)
                    warning('datasetQuery:NoDsetNameMatch',...
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
                    obj.filterIdx(i) = dsetSpec(obj.Group(i).dsetName);
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
            arguments
                obj
                fileName        char
                fileSpec        = []
            end

            fprintf('Performing file query for %s\n', fileName);

            % Find the entities with fileName
            for i = 1:numel(obj.Group)
                obj.filterIdx(i) = hasFile(obj.Group(i), fileName);
            end

            % Determine whether to continue and test for a specific value
            if isempty(paramSpec)
                return
            else
                if ~any(obj.filterIdx)
                    warning('fileQuery:NoFileNameMatches',...
                        'No entities were found with the file %s', paramName);
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
                    obj.filterIdx(i) = isequal(obj.Group(i).getFile(fileNane), fileSpec);
                end
            end
        end

        function parameterQuery(obj, paramName, paramSpec)
            arguments
                obj
                paramName       char
                paramSpec       = []
            end

            fprintf('Performing parameter query for %s\n', paramName);

            % Find the entities with paramName
            obj.filterIdx = hasParam(obj.Group, paramName);

            % Determine whether to continue and test for a specific value
            if isempty(paramSpec)
                return
            else
                if ~any(obj.filterIdx)
                    warning('parameterQuery:NoParamNameMatches',...
                        'No entities were found with the parameter %s', paramName);
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
                        obj.filterIdx(i) = paramSpec(obj.Group(i).getParam(paramName));
                    catch
                        warning('parameterQuery:InvalidParamFcn',...
                            'Parameter function for %s was invalid', paramName);
                    end
                end
            else
                for i = 1:numel(obj.Group)
                    if ~obj.filterIdx(i)
                        continue
                    end
                    obj.filterIdx(i) = isequal(obj.Group(i).getParam(paramName), paramSpec);
                end
            end
        end
    end

    % Derivative queries
    methods
        function subclassQuery(obj, className)
            % SUBCLASSQUERY
            arguments
                obj
                className
            end
            fprintf('Performing subclass query for %s\n', className);            
            for i = 1:numel(obj.Group)
                obj.filterIdx(i) = isSubclass(obj.Group(i), className);
            end
        end
    end

    methods (Access = protected)
        function out = queryByType(obj, varargin)
            % QUERYBYTYPE
            switch lower(obj.queryType)
                case 'class'
                    obj.classQuery(varargin{1});
                case 'subclass'
                    obj.subclassQuery(varargin{1});
                case 'name'
                    obj.nameQuery(varargin{:});
                case {'dataset', 'dset'}
                    obj.datasetQuery(varargin{:});
                case {'parameter', 'param'}
                    obj.parameterQuery(varargin{:})
            end

            fprintf('\tQuery returned %u of %u entities\n',... 
                nnz(obj.filterIdx), numel(obj.Group));

            if nnz(obj.filterIdx) == 0
                out = [];
            else
                out = obj.Group(obj.filterIdx);
            end
        end
    end 

    methods (Static)
        function out = go(entityGroup, queryType, varargin)
            obj = aod.api.EntityGroupSearch(entityGroup, queryType, varargin{:});
            out = obj.getMatches();
        end
    end
end