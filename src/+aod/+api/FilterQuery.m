classdef FilterQuery < handle & matlab.mixin.Heterogeneous
% FILTERQUERY
%
% Description:
%   Parent class for filtering entities in an AOData HDF5 file
%
% Parent:
%   handle, matlab.mixin.Heterogeneous
%
% Constructor:
%   obj = FilterQuery(hdfName)
%
% Abstract methods:
%   applyFilter(obj)
%
% Public methods:
%   names = getMatches(obj)
% -------------------------------------------------------------------------

    properties (SetAccess = private)
        hdfName
        allGroupNames
    end

    properties (SetAccess = protected)
        filterIdx 
    end

    methods (Abstract)
        applyFilter(obj)
    end

    methods 
        function obj = FilterQuery(hdfName)
            if nargin > 0
                obj.hdfName = hdfName;
                obj.populateGroupNames();
                obj.filterIdx = true(size(obj.allGroupNames));
            end
        end

        function names = getMatches(obj)
            % GETMATCHES
            %
            % Description:
            %   Applies filter and returns matching hdf paths
            %
            % Syntax:
            %   names = getMatches(obj)
            % -------------------------------------------------------------

            names = obj.allGroupNames(obj.filterIdx);
        end
    end

    methods (Access = private)
        function populateGroupNames(obj)
            names = aod.h5.HDF5.collectGroups(obj.hdfName);
            containerNames = aod.core.EntityTypes.allContainerNames();
            for i = 1:numel(containerNames)
                names = names(~endsWith(names, containerNames(i)));
            end
            obj.allGroupNames = names;
        end
    end
end