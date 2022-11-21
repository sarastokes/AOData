classdef EntityGroupSearch < handle
% ENTITYGROUPQUERY
%
% Description:
%   Simulation of AOQuery for core interface
%
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

            queryType = capitalize(string(queryType));
            assert(ismember(queryType, obj.QUERY_TYPES),...
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

        function subclassQuery(obj, className)
            arguments
                obj
                className
            end
            fprintf('Performing subclass query for %s\n', className);            
            for i = 1:numel(obj.Group)
                obj.filterIdx(i) = isSubclass(obj.Group(i), className);
            end
        end

        function datasetQuery(obj, dsetName, dsetSpec)
            fprintf('Performing dataset query for %s\n', dsetName);
            for i = 1:numel(obj.Group)
                obj.filterIdx(i) = isprop(obj.Group(i), dsetName);
            end
            
            if nargin < 3
                return
            end
            if ishandle(dsetSpec)
            else
                for i = 1:numel(obj.Group)
                    if ~obj.filterIdx(i)
                        continue
                    end
                    obj.filterIdx(i) = isequal(obj.Group(i).(dsetName), dsetSpec);
                end
            end
        end

        function parameterQuery(obj, paramName, paramSpec)
            fprintf('Performing parameter query for %s\n', paramName);
            for i = 1:numel(obj.Group)
                obj.filterIdx(i) = obj.Group(i).hasParam(paramName);
            end
            if nargin < 3
                return
            end
            if ishandle(paramSpec)
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

    methods %(Access = protected)
        function out = queryByType(obj, varargin)
            switch obj.queryType
                case 'Class'
                    obj.classQuery(varargin{1});
                case 'Subclass'
                    obj.subclassQuery(varargin{1});
                case 'Name'
                    obj.nameQuery(varargin{:});
                case 'Dataset'
                    obj.datasetQuery(varargin{:});
                case 'Parameter'
                    obj.parameterQuery(varargin{:})
            end

            if nnz(obj.filterIdx) == 0
                out = [];
            else
                out = obj.Group(obj.filterIdx);
            end
        end
    end 
end