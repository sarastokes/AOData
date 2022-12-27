classdef ParameterFilter < aod.api.FilterQuery 
% PARAMETERFILTER
%
% Description:
%   Filter entities based on the presence of a parameter or matching a 
%   specific parameter value
%
% Parent:
%   aod.api.FilterQuery
%
% Constructor:
%   obj = aod.api.ParameterFilter(hdfName, paramName)
%   obj = aod.api.ParameterFilter(hdfName, paramName, paramValue)
%
% Notes:
%   If paramValue isn't set, entities will be filtered by whether they have
%   the parameter "paramName" or not

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        paramName
        paramValue
    end

    methods
        function obj = ParameterFilter(hdfName, paramName, paramValue)
            if nargin < 3
                paramValue = [];
            end
            obj = obj@aod.api.FilterQuery(hdfName);
            obj.paramName = char(paramName);
            obj.paramValue = paramValue;

            obj.apply();
        end
    end

    % Implementation of FilterQuery abstract methods
    methods
        function apply(obj)
            % Filter by whether paramName is present
            for i = 1:numel(obj.allGroupNames)
                obj.filterIdx(i) = h5tools.hasAttribute(...
                    obj.hdfName, obj.allGroupNames(i), obj.paramName);
            end
            % Throw a warning if nothing matched the filter
            if nnz(obj.filterIdx) == 0
                warning('ParameterFilter_apply:NoMatches',...
                    'No matches were found for paramName %s', obj.paramName);
                return  % No need to check paramValue matches
            end

            % If necessary, filter by whether paramName matches paramValue
            if ~isempty(obj.paramValue)
                for i = 1:numel(obj.allGroupNames)
                    if obj.filterIdx(i)
                        attValue = h5readatt(obj.hdfName, obj.allGroupNames(i), obj.paramName);
                        obj.filterIdx(i) = isequal(attValue, obj.paramValue);
                    end
                end
                % Throw a warning if nothing matched the filter
                if nnz(obj.filterIdx) == 0
                    warning('ParameterFilter_apply:NoMatches',...
                        'No matches were found for %s =', obj.paramName);
                    disp(obj.paramValue);
                end
            end
        end
    end
end 