classdef ClassFilter < aod.api.FilterQuery 
% Filter entities based on original MATLAB class
%
% Description:
%   Filter entities in an AOData HDF5 file based on MATLAB class name
%
% Parent:
%   aod.api.FilterQuery
%
% Constructor:
%   obj = aod.api.ClassFilter(parent, className)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        % Name of target class
        Name
    end
    
    properties (SetAccess = private)
        allClassNames
    end

    methods
        function obj = ClassFilter(parent, className)
            obj = obj@aod.api.FilterQuery(parent);

            obj.Name = className;

            obj.collectClassNames();
        end
    end

    % Implementation of FilterQuery abstract methods
    methods
        function tag = describe(obj)
            tag = sprintf("ClassFilter: Name=%s", value2string(obj.Name));
        end

        function out = apply(obj)
            % Update local match indices to match those in Query Manager
            obj.localIdx = obj.getQueryIdx();
            
            for i = 1:numel(obj.allClassNames)
                if obj.localIdx(i)
                    if isa(obj.Name, 'function_handle')
                        obj.localIdx(i) = obj.Name(obj.allClassNames(i));
                    else
                        obj.localIdx(i) = strcmpi(obj.Name, obj.allClassNames(i));
                    end
                end
            end

            % Throw a warning if nothing matched the filter
            if nnz(obj.localIdx) == 0
                warning('apply:NoMatches',...
                    'ClassFilter for %s returned no matches',... 
                        value2string(obj.Name)); 
            end

            out = obj.localIdx;
        end
    end

    methods (Access = protected)
        function collectClassNames(obj)
            entities = obj.getEntityTable();
            obj.allClassNames = entities.Class;
        end
    end
end 