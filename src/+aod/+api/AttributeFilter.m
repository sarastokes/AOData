classdef AttributeFilter < aod.api.FilterQuery
% Filter entities by their attributes
%
% Description:
%   Filter entities based on the presence of a attribute or matching a 
%   specific attribute value
%
% Parent:
%   aod.api.FilterQuery
%
% Constructor:
%   obj = aod.api.AttributeFilter(parent, name)
%   obj = aod.api.AttributeFilter(parent, name, value)
%
% Inputs:
%   parent          aod.api.QueryManager
%   name            char/string
%       Name of the attribute
%   value           
%       A value for the attribute or a function handle for custom filtering
%
% Notes:
%   If paramValue isn't set, entities will be filtered by whether they have
%   the attribute "paramName" or not
%
% Examples:
%   QM = aod.api.QueryManager("MyFile.h5");
%   % Filter by whether entities have "MyParam"
%   PF = aod.api.AttributeFilter(QM, "MyParam")
%   % Get a specific attribute value
%   PF = aod.api.AttributeFilter(QM, "MyParam", 2)
%   % Use an anonymous function to find values less than 3
%   PF = aod.api.AttributeFilter(QM, "MyParam", @(x) x < 3)
%   % Specifying a value of 2 is equivalent to:
%   PF = aod.api.AttributeFilter(QM, "MyParam", @(x) isequal(x, 2))

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        Name            string
        Value
    end

    methods
        function obj = AttributeFilter(parent, name, value)
            obj@aod.api.FilterQuery(parent);

            obj.Name = name;

            if nargin > 2
                obj.Value = value;
            end
        end
    end

    methods
        function tag = describe(obj)
            tag = sprintf("AttributeFilter: Name=%s",... 
                value2string(obj.Name));
            if ~isempty(obj.Value)
                tag = tag + sprintf(", Value=%s", value2string(obj.Value));
            end
        end

        function out = apply(obj)
            % Update local match indices to match those in Query Manager
            obj.localIdx = obj.getQueryIdx();
            entities = obj.getEntityTable();

            % First filter by whether the entities have the attribute
            for i = 1:height(entities)
                if ~obj.localIdx(i)
                    continue
                end
                obj.localIdx(i) = h5tools.hasAttribute(...
                    entities.File(i), entities.Path(i), obj.Name);
            end
            out = obj.localIdx;

            % Exit if additional processing is no longer needed
            if nnz(obj.localIdx) == 0
                warning('apply:NoMatches',...
                    'No matches were found for attribute %s', obj.Name);
                return  % No need to check paramValue matches
            elseif isempty(obj.Value)
                return
            end

            % Second, filter by the attribute values
            for i = 1:height(entities)
                if ~obj.localIdx(i)
                    continue
                end
                attValue = h5readatt(entities.File(i),...
                    entities.Path(i), obj.Name);
                if isa(obj.Value, 'function_handle')
                    obj.localIdx(i) = obj.Value(attValue);
                else
                    obj.localIdx(i) = isequal(attValue, obj.Value);
                end
            end
            out = obj.localIdx;
        
            % Throw a warning if nothing matched the filter
            if nnz(obj.localIdx) == 0
                warning('apply:NoMatches',...
                    'No matches were found for %s = %s',... 
                    obj.Name, value2string(obj.Value));
            end
        end
                
        function txt = code(obj, input, output)
            
            arguments 
                obj 
                input           string  = "QM"
                output          string  = []
            end

            if isempty(obj.Value)
                txt = sprintf("aod.api.AttributeFilter(%s, %s)",... 
                    input, value2string(obj.Name));
            else
                txt = sprintf("aod.api.AttributeFilter(%s, %s, %s)",...
                    input, value2string(obj.Name), value2string(obj.Value));
            end

            if ~isempty(output)
                txt = sprintf("%s = %s;", output, txt);
            end
        end

    end
end 