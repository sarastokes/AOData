classdef ClassFilter < aod.api.FilterQuery 
% CLASSFILTER
%
% Description:
%   Filter entities in an AOData HDF5 file based on MATLAB class name
%
% Parent:
%   aod.api.FilterQuery
%
% Constructor:
%   obj = aod.api.ClassFilter(hdfName, className)

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = protected)
        Class
    end
    
    properties (SetAccess = private)
        allClassNames
    end

    methods
        function obj = ClassFilter(parent, className)
            obj = obj@aod.api.FilterQuery(parent);
            obj.Class = className;

            obj.collectClassNames();
        end
    end

    % Implementation of FilterQuery abstract methods
    methods
        function out = apply(obj)
            % Update local match indices to match those in Query Manager
            obj.localIdx = obj.Parent.filterIdx;
            
            for i = 1:numel(obj.allClassNames)
                if obj.localIdx(i)
                    if isa(obj.Class, 'function_handle')
                        obj.localIdx(i) = obj.Class(obj.allClassNames(i));
                    else
                        obj.localIdx(i) = strcmpi(obj.Class, obj.allClassNames(i));
                    end
                end
            end

            % Throw a warning if nothing matched the filter
            if nnz(obj.localIdx) == 0
                warning('apply:NoMatches',...
                    'ClassFilter for %s returned no matches',... 
                        value2string(obj.Class)); 
            end

            out = obj.localIdx;
        end
    end

    methods (Access = protected)
        function collectClassNames(obj)
            classNames = repmat("", [numel(obj.Parent.allGroupNames), 1]);
            for i = 1:numel(obj.Parent.allGroupNames)
                hdfFile = obj.Parent.getHdfName(i);
                classNames(i) = string(h5readatt(hdfFile,...
                    obj.Parent.allGroupNames(i), 'Class'));
            end
            obj.allClassNames = classNames;
        end
    end
end 