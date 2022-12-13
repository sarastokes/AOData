classdef NameFilter < aod.api.FilterQuery
% NAMEFILTER
%
% Description:
%   Filters entities based on group name with partial matching
%
% Parent:
%   aod.api.FilterQuery
%
% Constructor:
%   obj = NameFilter(hdfName, name)
%   obj = NameFilter(hdfName, name, partialMatchFlag)
%
% Inputs:
%   hdfName             char/string
%       Names of HDF file(s)
%   name                char/string
%       Name to search for
% Optional inputs:
%   partialMatchFlag    logical (default = false)
%       Whether to return groups that partially match name
% -------------------------------------------------------------------------

    properties %(SetAccess = private)
        Name
        partialMatchFlag        logical
        allNames
    end

    methods
        function obj = NameFilter(hdfName, name, partialMatchFlag)
            arguments
                hdfName 
                name                string
                partialMatchFlag    logical = true
            end
            obj = obj@aod.api.FilterQuery(hdfName);

            obj.Name = name;
            obj.partialMatchFlag = partialMatchFlag;
            
            obj.collectNames();
            obj.apply();
        end
    end

    % Implementation of FilterQuery abstract methods
    methods
        function apply(obj)
            obj.resetFilterIdx();
            if obj.partialMatchFlag
                for i = 1:numel(obj.allNames)
                    obj.filterIdx(i) = contains(obj.allNames(i), obj.Name);
                end
            else
                for i = 1:numel(obj.allNames)
                    obj.filterIdx(i) = strcmpi(obj.allNames(i), obj.Name);
                end
            end
        end
    end

    methods (Access = private)
        function collectNames(obj)
            obj.allNames = repmat("", [numel(obj.allGroupNames), 1]);
            for i = 1:numel(obj.allNames)
                obj.allNames(i) = h5tools.util.getPathEnd(obj.allGroupNames(i));
            end
        end
    end
end