classdef PathFilter < aod.api.FilterQuery 
% Filter entities based on original MATLAB class
%
% Description:
%   Filter entities in an AOData HDF5 file based on MATLAB class name
%
% Parent:
%   aod.api.FilterQuery
%
% Constructor:
%   obj = aod.api.PathFilter(parent, pathName)

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        PathName         
    end

    properties (SetAccess = private)
        allPathNames    string 
    end

    methods 
        function obj = PathFilter(parent, pathName)
            obj@aod.api.FilterQuery(parent);

            obj.PathName = pathName;

            obj.collectPathNames();
        end
    end

    % Implementation of FilterQuery abstract methods
    methods 
        function tag = describe(obj)
            tag = sprintf("PathFilter: Path=%s", value2string(obj.PathName));
        end

        function out = apply(obj)
            
            % Update local match indices to match those in Query Manager
            obj.localIdx = obj.getQueryIdx();

            if isa(obj.PathName, 'function_handle')
                for i = 1:numel(obj.allPathNames)
                    if obj.localIdx(i)
                        obj.localIdx(i) = obj.PathName(obj.allPathNames(i));
                    end
                end
            else
                idx = strcmpi(obj.allPathNames, obj.PathName) & obj.localIdx;
                obj.localIdx = idx;
            end

            % Throw a warning if nothing matched the filter
            if nnz(obj.localIdx) == 0
                warning('apply:NoMatches',...
                    'PathFilter for %s returned no matches', value2string(obj.PathName));
            end

            out = obj.localIdx;
        end
        
        function txt = code(obj, input, output)
            arguments 
                obj 
                input           string  = "QM"
                output          string  = []
            end

            txt = sprintf("aod.api.PathFilter(%s, %s)",... 
                input, value2string(obj.PathName));
            if ~isempty(output)
                txt = sprintf("%s = %s;", output, txt);
            end
        end
    end

    methods (Access = private)
        function collectPathNames(obj)
            entities = obj.getEntityTable();
            obj.allPathNames = entities.Path;
        end
    end
end 