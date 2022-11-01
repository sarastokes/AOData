classdef ParameterFilter < aod.api.FilterQuery 
% PARAMETERFILTER
%
% Description:
%   Filter entities based on the presence of a parameter or having a 
%   specific parameter value
%
% Parent:
%   aod.api.FilterQuery
%
% Constructor:
%   obj = ParameterFilter(hdfName, paramName)
%   obj = ParameterFilter(hdfName, paramName, paramValue)
%
% Notes:
%   If paramValue isn't set, entities will be filtered by whether they have
%   the parameter paramName or not
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

            obj.applyFilter();
        end

        function applyFilter(obj)
            % Filter by whether paramName is present
            for i = 1:numel(obj.allGroupNames)
                obj.filterIdx(i) = aod.h5.HDF5.hasAttribute(...
                    obj.hdfName, obj.allGroupNames(i), obj.paramName);
            end
            % If necessary, filter by whether paramName matches paramValue
            if ~isempty(obj.paramValue)
                for i = 1:numel(obj.allGroupNames)
                    if obj.filterIdx(i)
                        attValue = h5readatt(obj.hdfName, obj.allGroupNames(i), obj.paramName);
                        obj.filterIdx(i) = isequal(attValue, obj.paramValue);
                    end
                end
            end
        end
    end
end 