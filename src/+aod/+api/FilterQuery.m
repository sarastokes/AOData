classdef FilterQuery < handle & matlab.mixin.Heterogeneous

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
    end

    methods (Access = private)
        function populateGroupNames(obj)
            names = aod.h5.HDF5.collectGroups(obj.Experiment.hdfName);
            containerNames = aod.core.EntityTypes.allContainerNames();
            for i = 1:numel(containerNames)
                names = names(~endsWith(names, containerNames(i)));
            end
            obj.allGroupNames = names;
        end
    end
end