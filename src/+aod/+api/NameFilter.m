classdef NameFilter < aod.api.FilterQuery
% Filter entities by name
%
% Description:
%   Filters entities based on group name with partial matching
%
% Parent:
%   aod.api.FilterQuery
%
% Constructor:
%   obj = aod.api.NameFilter(hdfName, name)
%   obj = aod.api.NameFilter(hdfName, name, customFcn)
%
% Inputs:
%   hdfName             char/string
%       Names of HDF file(s)
%   name                char/string/function_handle
%       Name to search for or a function handle defining a custom filter
%       for entity group names
%
% Examples:
%   % Returns entities with a group name of "MyGroupName"
%   NF = aod.api.NameFilter(parent, "MyGroupName")
%   % Specifying "MyGroupName" is equivalent to:
%   NF = aod.api.NameFilter(parent, @(x) strcmpi(x, "MyGroupName"));
%   % For partial-matching (i.e. to get "MyGroupName1" and "MyGroupName2"):
%   NF = aod.api.NameFilter(parent, @(x) contains(x, "MyGroupName"));

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        Name
    end

    properties (SetAccess = protected)
        allNames
    end

    methods 
        function obj = NameFilter(parent, name)
            obj@aod.api.FilterQuery(parent);
            
            if ~istext(name) && ~isa(name, 'function_handle')
                error('NameFilter:InvalidInput',...
                    'Name must be text or a function handle!');
            end
            obj.Name = name;

            obj.collectNames();
        end
    end

    methods
        function tag = describe(obj)
            tag = sprintf("NameFilter: Name=%s", value2string(obj.Name));
        end

        function out = apply(obj)
            % Update local match indices to match those in Query Manager
            obj.localIdx = obj.getQueryIdx();

            if isa(obj.Name, 'function_handle')
                for i = 1:numel(obj.allNames)
                    if obj.localIdx(i)
                        obj.localIdx(i) = obj.Name(obj.allNames(i));
                    end
                end
            else
                for i = 1:numel(obj.allNames)
                    if obj.localIdx(i)
                        obj.localIdx(i) = strcmpi(obj.allNames(i), obj.Name);
                    end
                end
            end

            out = obj.localIdx;

            if nnz(obj.localIdx) == 0
                warning("apply:NoMatches",...
                    "No matches for Name %s", char(obj.Name));
            end
        end

        function txt = code(obj, input, output)
            arguments 
                obj 
                input           string  = "QM"
                output          string  = []
            end

            txt = sprintf("aod.api.NameFilter(%s, %s)",... 
                input, value2string(obj.Name));
            if ~isempty(output)
                txt = sprintf("%s = %s;", output, txt);
            end
        end
    end

    methods (Access = private)
        function collectNames(obj)
            entities = obj.getEntityTable();
            obj.allNames = repmat("", [height(entities), 1]);
            for i = 1:numel(obj.allNames)
                obj.allNames(i) = h5tools.util.getPathEnd(entities.Path(i));
            end
        end
    end
end 